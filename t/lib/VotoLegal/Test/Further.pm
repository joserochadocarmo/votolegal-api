package VotoLegal::Test::Further;
use common::sense;
use Carp;

use Test::More;
use Catalyst::Test q(VotoLegal);
use CatalystX::Eta::Test::REST;

use Data::Faker;
use Data::Printer;
use JSON::MaybeXS;
use Business::BR::CPF qw(random_cpf);

# ugly hack
sub import {
    strict->import;
    warnings->import;

    no strict 'refs';

    my $caller = caller;

    while ( my ( $name, $symbol ) = each %{ __PACKAGE__ . '::' } ) {
        next if $name eq 'BEGIN';     # don't export BEGIN blocks
        next if $name eq 'import';    # don't export this sub
        next unless *{$symbol}{CODE}; # export subs only

        my $imported = $caller . '::' . $name;
        *{$imported} = \*{$symbol};
    }
}

my $obj = CatalystX::Eta::Test::REST->new(
    do_request => sub {
        my $req = shift;

        eval 'do{my $x = $req->as_string; p $x}' if exists $ENV{TRACE} && $ENV{TRACE};
        my ($res, $c) = ctx_request($req);
        eval 'do{my $x = $res->as_string; p $x}' if exists $ENV{TRACE} && $ENV{TRACE};
        return $res;
    },
    decode_response => sub {
        my $res = shift;
        return decode_json($res->content);
    }
);

for (qw/rest_get rest_put rest_head rest_delete rest_post rest_reload rest_reload_list/) {
    eval( 'sub ' . $_ . ' { return $obj->' . $_ . '(@_) }' );
}

sub stash_test ($&) {
    $obj->stash_ctx(@_);
}

sub stash ($) {
    $obj->stash->{ $_[0] };
}

sub test_instance { $obj }

sub db_transaction (&) {
    my ( $subref, $modelname ) = @_;

    my $schema = VotoLegal->model( $modelname || 'DB' );

    eval {
        $schema->txn_do(
            sub {
                $subref->($schema);
                die 'rollback';
            }
        );
    };
    die $@ unless $@ =~ /rollback/;
}

my $auth_user = {};

sub api_auth_as {
    my (%conf) = @_;

    if (!defined($conf{user_id}) && !defined($conf{candidate_id})) {
        croak "api_auth_as: missing 'user_id' or 'candidate_id'.";
    }

    my $user_id      = $conf{user_id};
    my $candidate_id = $conf{candidate_id};

    my $schema = VotoLegal->model(defined($conf{model}) ? $conf{model} : 'DB');

    if (defined($candidate_id)) {
        $user_id = $schema->resultset('Candidate')->find($candidate_id)->user_id;
    }

    if ($auth_user->{id} != $user_id) {
        my $user = $schema->resultset('User')->find($user_id);

        croak 'api_auth_as: user not found' unless $user;

        my $session = $user->new_session(ip => "127.0.0.1");

        $auth_user = {
            id      => $user_id,
            api_key => $session->{api_key},
        };
    }

    $obj->fixed_headers([ 'x-api-key' => $auth_user->{api_key} ]);
}

sub create_candidate {
    my (%opts) = @_;

    my $fake = Data::Faker->new();
    my $username = lc $fake->name;
    $username =~ s/\s+/_/g;

    return $obj->rest_post(
        '/api/register',
        name  => 'add candidate',
        stash => 'candidate',
        [
            username             => $username,
            password             => "foobarquux1",
            name                 => $fake->first_name,
            popular_name         => $fake->last_name,
            email                => $fake->email,
            cpf                  => random_cpf(),
            address_state        => 'São Paulo',
            address_city         => 'Iguape',
            address_zipcode      => '11920-000',
            address_street       => $fake->street_address,
            address_house_number => 1 + int(rand(2000)),
            office_id            => 2,
            party_id             => 5,
            reelection           => 1,
            %opts,
        ],
    );
}

1;