use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use VotoLegal::Test::Further;

my $schema = VotoLegal->model('DB');

db_transaction {
    my $name                 = fake_name()->();
    my $popular_name         = fake_name()->();
    my $email                = fake_email()->();
    my $cpf                  = random_cpf();
    my $address_state        = 'SP';
    my $address_city         = 'São Paulo';
    my $address_zipcode      = '01310-100';
    my $address_street       = 'Av. Paulista';
    my $address_district     = 'Paraíso',
    my $address_house_number = 1 + int(rand(2000));
    my $phone                = '(42)23423-4234';

    create_candidate(
        password             => 'foo',
        name                 => $name,
        popular_name         => $popular_name,
        email                => $email,
        cpf                  => $cpf,
        address_state        => $address_state,
        address_city         => $address_city,
        address_zipcode      => $address_zipcode,
        address_street       => $address_street,
        address_house_number => $address_house_number,
    );
    my $candidate_id = stash "candidate.id";
    my $candidate    = $schema->resultset("Candidate")->find($candidate_id);

    api_auth_as candidate_id => $candidate_id;

    rest_post "/api/candidate/$candidate_id/payment",
        name    => 'Payment without contract signature',
        is_fail => 1,
        code    => 400,
    ;

    create_candidate_contract_signature($candidate_id);

    # rest_get "/api/candidate/$candidate_id/payment/session",
    #     name    => "get session when not activated",
    #     stash   => 's1'
    # ;

    my $fake_sender_hash       = '52578d5d3336ec7a43ff1dae4794d0c5625feddcc8fbc0e80bcb0cb46c9947d4';
    my $fake_credit_card_token = '1e358d39e26448dc8a28d0f1815f08c5';

    rest_post "/api/candidate/$candidate_id/payment",
        name    => 'payment without method',
        is_fail => 1,
        code    => 400,
        [
            sender_hash          => $fake_sender_hash,
            credit_card_token    => $fake_credit_card_token,
            cpf                  => $cpf,
            address_state        => $address_state,
            address_city         => $address_city,
            address_zipcode      => $address_zipcode,
            address_street       => $address_street,
            address_district     => $address_district,
            address_house_number => $address_house_number,
            phone                => $phone
        ]
    ;

    rest_post "/api/candidate/$candidate_id/payment",
        name    => 'payment without sender_hash',
        is_fail => 1,
        code    => 400,
        [
            method               => 'creditCard',
            credit_card_token    => $fake_credit_card_token,
            credit_card_token    => $fake_credit_card_token,
            cpf                  => $cpf,
            address_state        => $address_state,
            address_city         => $address_city,
            address_zipcode      => $address_zipcode,
            address_street       => $address_street,
            address_district     => $address_district,
            address_house_number => $address_house_number,
            phone                => $phone
        ]
    ;

    rest_post "/api/candidate/$candidate_id/payment",
        name    => 'payment with invalid method',
        is_fail => 1,
        code    => 400,
        [
            method               => 'foobar',
            sender_hash          => $fake_sender_hash,
            credit_card_token    => $fake_credit_card_token,
            cpf                  => $cpf,
            address_state        => $address_state,
            address_city         => $address_city,
            address_zipcode      => $address_zipcode,
            address_street       => $address_street,
            address_district     => $address_district,
            address_house_number => $address_house_number,
            phone                => $phone
        ]
    ;

    rest_post "/api/candidate/$candidate_id/payment",
        name    => 'payment with boleto method but with credit_card_token',
        is_fail => 1,
        code    => 400,
        [
            method               => 'boleto',
            sender_hash          => $fake_sender_hash,
            credit_card_token    => $fake_credit_card_token,
            cpf                  => $cpf,
            address_state        => $address_state,
            address_city         => $address_city,
            address_zipcode      => $address_zipcode,
            address_street       => $address_street,
            address_district     => $address_district,
            address_house_number => $address_house_number,
            phone                => $phone
        ]
    ;

    rest_post "/api/candidate/$candidate_id/payment",
        name    => 'payment with creditCard method but without credit_card_token',
        is_fail => 1,
        code    => 400,
        [
            method               => 'creditCard',
            sender_hash          => $fake_sender_hash,
            cpf                  => $cpf,
            address_state        => $address_state,
            address_city         => $address_city,
            address_zipcode      => $address_zipcode,
            address_street       => $address_street,
            address_district     => $address_district,
            address_house_number => $address_house_number,
            phone                => $phone
        ]
    ;

    rest_post "/api/candidate/$candidate_id/payment",
        name    => 'payment with creditCard method but without credit_card_token',
        is_fail => 1,
        code    => 400,
        [
            method               => 'boleto',
            sender_hash          => 'c1ec88b704a7275e28bd86199cb44ee186375b603f21c118756811f39eeb2560',
            cpf                  => $cpf,
            address_state        => $address_state,
            address_city         => $address_city,
            address_zipcode      => $address_zipcode,
            address_street       => $address_street,
            address_district     => $address_district,
            address_house_number => $address_house_number,
            phone                => $phone,
            name                 => $name,
            email                => $email
        ]
    ;

    # Não tem como gerar uma sender hash pelo backend apenas no front.
    # logo não conseguimos testar a resposta da API do pagseguro para
    # transactions e notifications

    # is ($candidate->payment_status, 'unpaid', 'candidate status is unpaid');

    # api_auth_as 'nobody';
    # rest_post "/api/candidate/$candidate_id/payment/callback",
    #     name   => "callback",
    #     stash  => 'c1',
    #     code   => 200,
    #     params => {
    #         notificationCode => "35F7C2-C6D3F0D3F088-7664F32FBBA4-5F32FE",
    #         notificationType => "transaction",
    #     },
    # ;

    # is ($candidate->discard_changes->payment_status, 'paid', 'candidate status is paid');

    # rest_post "/api/login",
    #     name  => 'login to check booleans',
    #     stash => 'l1',
    #     code  => 200,
    #     [
    #         email    => $email,
    #         password => 'foo'
    #     ]
    # ;

    # stash_test "l1" => sub {
    #     my $res = shift;

    #     is ($res->{signed_contract}, 1, 'candidate has signed contract');
    #     is ($res->{paid},            1, 'candidate has paid');
    # }

};

done_testing();