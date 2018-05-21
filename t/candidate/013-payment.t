use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

plan skip_all => "can't generate sender hash to use pagseguro sandbox.";

my $schema = VotoLegal->model('DB');

db_transaction {
    create_candidate;
    api_auth_as candidate_id => stash 'candidate.id';

    my $id_candidate = stash 'candidate.id';
    ok( my $candidate = $schema->resultset('Candidate')->find($id_candidate) );

    # Não pode gerar session de um candidato não aprovado.
    rest_get "/api/candidate/$id_candidate/payment/session",
      name    => "can't get session when not activated",
      is_fail => 1,
      code    => 400,
      ;

    $candidate->update(
        {
            status           => "activated",
            cnpj             => random_cnpj(),
            phone            => "11982012016",
            address_district => "Centro",
        }
    );

    # Gerando uma session.
    rest_get "/api/candidate/$id_candidate/payment/session",
      name  => "get session",
      stash => "s1",
      ;

    stash_test 's1' => sub {
        my $res = shift;

        is( length $res->{id}, 32, 'session id has 32 chars' );
    };

    # Gerando o boleto.
    my $senderHash = "a93d10e8417cf5cd9dde245a0de6c48f2505d532ed893f16f32f33abe33ab99e";

    rest_post "/api/candidate/$id_candidate/payment",
      name   => "get boleto",
      stash  => "b1",
      code   => 200,
      params => { senderHash => $senderHash, };

    my $boletoUrl;
    stash_test 'b1' => sub {
        my $res = shift;

        ok( $boletoUrl = $res->{url}, 'boleto url' );
    };

    # Chamando o callback como se o boleto tivesse sido pago.
    ok( my $payment = $schema->resultset('Payment')->search( { boleto_url => $boletoUrl } )->next, 'payment' );
    is( $payment->candidate_id, $id_candidate, 'candidate id' );

    api_auth_as 'nobody';
    rest_post "/api/candidate/$id_candidate/payment/callback",
      name   => "callback",
      stash  => 'c1',
      code   => 200,
      params => {
        notificationCode => "35F7C2-C6D3F0D3F088-7664F32FBBA4-5F32FE",
        notificationType => "transaction",
      },
      ;
};

done_testing();

