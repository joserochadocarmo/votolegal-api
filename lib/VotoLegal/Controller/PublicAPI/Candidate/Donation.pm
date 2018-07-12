package VotoLegal::Controller::PublicAPI::Candidate::Donation;
use common::sense;
use Moose;
use namespace::autoclean;

use WebService::Dcrtime;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

sub root : Chained('/publicapi/candidate/object') : PathPart('') : CaptureArgs(0) {
    my ( $self, $c ) = @_;

    $c->stash->{collection} = $c->model('DB::VotolegalDonation')->search(
        { 'me.refunded_at' => undef },
        {
            prefetch   => [ 'votolegal_donation_immutable', { candidate => 'party' } ],
            '+columns' => [
                { captured_at_human => \"TIMEZONE('America/Sao_Paulo', TIMEZONE('UTC', me.captured_at))" },
                { payment_method_human => \"CASE WHEN me.is_boleto THEN 'Boleto' ELSE 'Cartão de crédito' END" },
                { decred_transaction_url => \"CASE WHEN me.decred_capture_txid IS NOT NULL THEN CONCAT('https://explorer.dcrdata.org/tx/', me.decred_capture_txid) END" },
            ],
        }
    );
}

sub base : Chained('root') : PathPart('donation') : CaptureArgs(0) { }

sub digest : Chained('base') : PathPart('digest') : CaptureArgs(1) {
    my ( $self, $c, $digest ) = @_;

    my $donation = $c->stash->{collection}->search( { 'me.decred_data_digest' => $digest } )->next();

    if ( !ref($donation) ) {
        $self->status_not_found( $c, message => 'Donation not found' );
        $c->detach();
    }

    $c->stash->{donation} = $donation;
}

sub result : Chained('digest') : PathPart('') : Args(0) : ActionClass('REST') { }

sub result_GET {
    my ( $self, $c ) = @_;

    my $donation = $c->stash->{donation};
    my $donation_immutable = $donation->votolegal_donation_immutable;

    # TODO  Data da doação; forma de pagamento; dados do candidato (nome, partido, cpf e cnpj);
    return $self->status_ok(
        $c,
        entity => {
            donation => {
                (
                    map { $_ => $donation->get_column($_) }
                    qw/ id candidate_id decred_capture_txid decred_data_raw decred_data_digest captured_at_human
                    payment_method_human decred_transaction_url /
                ),
                (
                    map { $_ => $donation_immutable->get_column($_) }
                    qw/ donor_name donor_cpf git_hash amount /
                ),

                git_url => 'https://github.com/AppCivico/votolegal-api/tree/' . $donation_immutable->get_column('git_hash'),

                candidate => {
                    (
                        map { $_ => $donation->candidate->get_column($_) }
                        qw/ id popular_name party_id cpf cnpj /
                    ),
                    party => {
                        map { $_ => $donation->candidate->party->get_column($_) }
                        qw/ id name acronym /
                    },
                },
            },
        }
    );
}

__PACKAGE__->meta->make_immutable;

1;
