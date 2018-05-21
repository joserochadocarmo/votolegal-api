#!/usr/bin/env perl
use common::sense;
use open q(:locale);
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Furl;
use JSON;
use Time::HiRes;
use File::Temp qw(tempdir);
use Digest::MD5 qw(md5_hex);
use VotoLegal::SchemaConnected;
use Business::BR::CPF qw(test_cpf);
use Business::BR::CNPJ qw(test_cnpj);

my $schema = get_schema();

my $ua = Furl->new( timeout => 30 );

my @candidates = $schema->resultset('Candidate')->search(
    {
        status         => "activated",
        payment_status => "paid",
        crawlable      => "true",
    }
)->all;

CANDIDATE: for my $candidate (@candidates) {
    printf "Processando o candidato '%s' (id #%d).\n", $candidate->name, $candidate->id;

    # Estado.
    printf "Buscando o código do estado do candidato '%d'\n", $candidate->id;
    my $state = $schema->resultset('State')->search( { name => $candidate->address_state } )->next->code
      or die "Não foi possível encontrar o estado de nome '" . $candidate->address_state . "'";

    # Município.
    printf "Buscando id do município do candidato '%d'.\n", $candidate->id;
    my $reqCity = get("http://divulgacandcontas.tse.jus.br/divulga/rest/v1/eleicao/buscar/${state}/2/municipios");

    my $cities = decode_json $reqCity;

    my $cityCode;
    for ( @{ $cities->{municipios} } ) {
        if ( $_->{nome} eq uc( $candidate->address_city ) ) {
            $cityCode = $_->{codigo};
            last;
        }
    }
    defined $cityCode or die "Não foi possível encontrar o município '" . $candidate->address_city . "'";

    # Buscando o código do cargo.
    printf "Buscando os cargos do município do candidato '%d'.\n", $candidate->id;
    my $officeReq =
      get("http://divulgacandcontas.tse.jus.br/divulga/rest/v1/eleicao/listar/municipios/2/${cityCode}/cargos");
    my $offices = decode_json $officeReq;

    my $officeCode;
    for ( @{ $offices->{cargos} } ) {
        if ( $_->{nome} eq $candidate->office->name ) {
            $officeCode = $_->{codigo};
            last;
        }
    }

    # Listando os candidatos que concorrem ao mesmo cargo.
    my $candidatesReq = get(
        "http://divulgacandcontas.tse.jus.br/divulga/rest/v1/candidatura/listar/2016/$cityCode/2/$officeCode/candidatos"
    );
    my $candidates = decode_json $candidatesReq;

    # O campo 'cnpjcampanha' não vem populado nesta ultima request. Sempre vem null. Sendo assim é necessário
    # a entrar na página de cada candidato para confrontar o CNPJ.
    for ( @{ $candidates->{candidatos} } ) {

        # Ao menos temos uma informação interessante: o partido. Se o candidato não for do mesmo partido o qual estou
        # buscando, já nem procuro o CNPJ dele.
        next unless $candidate->party->acronym eq $_->{partido}->{sigla};

        my $candidateId = $_->{id};

        my $candidateReq = get(
"http://divulgacandcontas.tse.jus.br/divulga/rest/v1/candidatura/buscar/2016/$cityCode/2/candidato/$candidateId"
        );

        my $candidateData = decode_json $candidateReq;

        my $cnpj = $candidate->cnpj;
        $cnpj =~ s/\D//g;

        # Se o CNPJ bater, legal, encontrei o candidato! Vamos buscar as doações recebidas pelo mesmo.
        if ( $cnpj eq $candidateData->{cnpjcampanha} ) {
            printf "Legal, o candidato id '%d' de cnpj '%s' bateu com o cnpj '%s'!\n",
              $candidate->id,
              $candidate->cnpj,
              $candidateData->{cnpjcampanha};

            # Para obter as receitas eu preciso do numero do partido e do número do candidato.
            my $numPartido   = $candidateData->{partido}->{numero};
            my $numCandidato = $candidateData->{numero};
            my $nrCargo      = $candidateData->{cargo}->{codigo};

            # Obtendo numero do prestador.
            my $prestadorReq = get(
"http://divulgacandcontas.tse.jus.br/divulga/rest/v1/prestador/consulta/2/2016/$cityCode/$nrCargo/$numPartido/$numCandidato/$candidateId"
            );

            my $prestador = decode_json $prestadorReq;

            # Obtendo as receitas.
            # Eu não faço ideia a que se refere esses números, mas descobri que preciso deles.
            my $sqEntregaPrestacao = $prestador->{dadosConsolidados}->{sqEntregaPrestacao};
            my $sqPrestadorConta   = $prestador->{dadosConsolidados}->{sqPrestadorConta};

            if ( !defined($sqEntregaPrestacao) || !defined($sqPrestadorConta) ) {
                printf "O candidato '%s' (id %d) não prestou contas das declarações.\n", $candidate->name,
                  $candidate->id;
                next CANDIDATE;
            }

            my $receitasReq = get(
"http://divulgacandcontas.tse.jus.br/divulga/rest/v1/prestador/consulta/receitas/2/$sqPrestadorConta/$sqEntregaPrestacao"
            );

            my $receitas = decode_json $receitasReq;

            # Fix: o TSE editou a espécie de uma doação de "Em espécie" para "Transferência eletrônica", o que
            # confundiu o crawler. Como não são tantos dados assim, vou dar um delete em tudo e depois reinserir.
            my $guard = $schema->txn_scope_guard;

            $candidate->donations->search(
                {
                    by_votolegal => "false",
                }
              )->delete
              if @$receitas;

            for my $receita ( @{$receitas} ) {
                my $fonteOrigem      = $receita->{fonteOrigem};
                my $cpfCnpjDoador    = $receita->{cpfCnpjDoador};
                my $donation_type_id = $fonteOrigem eq "Fundo Partidário" ? 2 : 1;

                next if !test_cpf($cpfCnpjDoador) && !test_cnpj($cpfCnpjDoador);

                # A única maneira segura do crawler não duplicar as doações é checar a duplicidade pelo cpf do
                # doador e o valor da doação.
                if ( $receita->{especieRecurso} eq "Cartão de crédito" ) {
                    my $repeatedDonation = $candidate->donations->search(
                        {
                            cpf          => $receita->{cpfCnpjDoador},
                            amount       => $receita->{valorReceita} * 100,
                            species      => $receita->{especieRecurso},
                            status       => "captured",
                            by_votolegal => "true",
                        }
                    )->next;

                    if ( defined($repeatedDonation) ) {
                        printf
"A doação para o candidato %d do cpf %s no valor de R\$ %s foi realizada através do VotoLegal.\n",
                          $candidate->id,
                          $receita->{cpfCnpjDoador},
                          $receita->{valorReceita},
                          ;
                        next;
                    }
                }

                printf
                  "Armazenando doação para o candidato %d do cpf/cnpj %s no valor de R\$ %s.\n",
                  $candidate->id,
                  $receita->{cpfCnpjDoador},
                  $receita->{valorReceita},
                  ;

                $candidate->donations->create(
                    {
                        id               => md5_hex( Time::HiRes::time() ),
                        name             => $receita->{nomeDoador},
                        cpf              => $receita->{cpfCnpjDoador},
                        amount           => $receita->{valorReceita} * 100,
                        species          => $receita->{especieRecurso},
                        ip_address       => "127.0.0.1",
                        by_votolegal     => "false",
                        status           => "captured",
                        captured_at      => $receita->{dtReceita},
                        donation_type_id => $donation_type_id,
                    }
                );
            }
            $guard->commit;
            last;
        }
        else {
            printf "O cnpj '%s' do candidato id '%d' não bateu com '%s'.\n",
              $candidate->cnpj,
              $candidate->id,
              $candidateData->{cnpjcampanha};
        }
    }
}

printf "Fim da execução.\n";

sub get {
    my $url = shift;

    for ( 1 .. 5 ) {
        my $req = $ua->get($url);

        if ( $req->is_success() ) {
            return $req->decoded_content;
        }
    }

    die "Não foi possível obter a url '$url' após 5 tentativas.";
}
