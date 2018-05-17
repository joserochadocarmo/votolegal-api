use utf8;
package VotoLegal::Schema::Result::VotolegalDonation;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

VotoLegal::Schema::Result::VotolegalDonation

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::TimeStamp>

=item * L<DBIx::Class::PassphraseColumn>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "PassphraseColumn");

=head1 TABLE: C<votolegal_donation>

=cut

__PACKAGE__->table("votolegal_donation");

=head1 ACCESSORS

=head2 id

  data_type: 'uuid'
  default_value: uuid_generate_v4()
  is_nullable: 0
  size: 16

=head2 candidate_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 state

  data_type: 'text'
  default_value: 'created'
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 created_at

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 captured_at

  data_type: 'timestamp'
  is_nullable: 1

=head2 refunded_at

  data_type: 'timestamp'
  is_nullable: 1

=head2 compensated_at

  data_type: 'timestamp'
  is_nullable: 1

=head2 transferred_at

  data_type: 'timestamp'
  is_nullable: 1

=head2 is_boleto

  data_type: 'boolean'
  is_nullable: 0

=head2 is_pre_campaign

  data_type: 'boolean'
  is_nullable: 0

=head2 payment_info

  data_type: 'json'
  is_nullable: 1

=head2 gateway_tid

  data_type: 'text'
  is_nullable: 1

=head2 gateway_data

  data_type: 'json'
  is_nullable: 1

=head2 callback_id

  data_type: 'uuid'
  default_value: uuid_generate_v4()
  is_nullable: 0
  size: 16

=head2 payment_gateway_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 device_authorization_token_id

  data_type: 'uuid'
  is_foreign_key: 1
  is_nullable: 0
  size: 16

=head2 stash

  data_type: 'json'
  is_nullable: 1

=head2 decred_capture_registered_at

  data_type: 'timestamp'
  is_nullable: 1

=head2 decred_capture_hash

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 decred_refund_registered_at

  data_type: 'timestamp'
  is_nullable: 1

=head2 decred_refund_hash

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "uuid",
    default_value => \"uuid_generate_v4()",
    is_nullable => 0,
    size => 16,
  },
  "candidate_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "state",
  {
    data_type     => "text",
    default_value => "created",
    is_nullable   => 0,
    original      => { data_type => "varchar" },
  },
  "created_at",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "captured_at",
  { data_type => "timestamp", is_nullable => 1 },
  "refunded_at",
  { data_type => "timestamp", is_nullable => 1 },
  "compensated_at",
  { data_type => "timestamp", is_nullable => 1 },
  "transferred_at",
  { data_type => "timestamp", is_nullable => 1 },
  "is_boleto",
  { data_type => "boolean", is_nullable => 0 },
  "is_pre_campaign",
  { data_type => "boolean", is_nullable => 0 },
  "payment_info",
  { data_type => "json", is_nullable => 1 },
  "gateway_tid",
  { data_type => "text", is_nullable => 1 },
  "gateway_data",
  { data_type => "json", is_nullable => 1 },
  "callback_id",
  {
    data_type => "uuid",
    default_value => \"uuid_generate_v4()",
    is_nullable => 0,
    size => 16,
  },
  "payment_gateway_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "device_authorization_token_id",
  { data_type => "uuid", is_foreign_key => 1, is_nullable => 0, size => 16 },
  "stash",
  { data_type => "json", is_nullable => 1 },
  "decred_capture_registered_at",
  { data_type => "timestamp", is_nullable => 1 },
  "decred_capture_hash",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "decred_refund_registered_at",
  { data_type => "timestamp", is_nullable => 1 },
  "decred_refund_hash",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 candidate

Type: belongs_to

Related object: L<VotoLegal::Schema::Result::Candidate>

=cut

__PACKAGE__->belongs_to(
  "candidate",
  "VotoLegal::Schema::Result::Candidate",
  { id => "candidate_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 certiface_tokens

Type: has_many

Related object: L<VotoLegal::Schema::Result::CertifaceToken>

=cut

__PACKAGE__->has_many(
  "certiface_tokens",
  "VotoLegal::Schema::Result::CertifaceToken",
  { "foreign.votolegal_donation_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 device_authorization_token

Type: belongs_to

Related object: L<VotoLegal::Schema::Result::DeviceAuthorizationToken>

=cut

__PACKAGE__->belongs_to(
  "device_authorization_token",
  "VotoLegal::Schema::Result::DeviceAuthorizationToken",
  { id => "device_authorization_token_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 payment_gateway

Type: belongs_to

Related object: L<VotoLegal::Schema::Result::PaymentGateway>

=cut

__PACKAGE__->belongs_to(
  "payment_gateway",
  "VotoLegal::Schema::Result::PaymentGateway",
  { id => "payment_gateway_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 votolegal_donation_immutable

Type: might_have

Related object: L<VotoLegal::Schema::Result::VotolegalDonationImmutable>

=cut

__PACKAGE__->might_have(
  "votolegal_donation_immutable",
  "VotoLegal::Schema::Result::VotolegalDonationImmutable",
  { "foreign.votolegal_donation_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2018-05-17 01:56:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:FkoUR4l/7NboVSLAL3QKlg

use Carp;
use JSON::XS;
use JSON qw/to_json from_json/;
use WebService::Certiface;

sub resultset { shift->result_source->resultset }

sub as_row {
    my ($self) = @_;

    my $donation = $self->resultset('VotolegalDonation')->search(
        {
            id => $self->id
        },
        {
            prefetch => 'votolegal_donation_immutable'
        }
    )->next;

    my $immu = $donation->votolegal_donation_immutable;
    my $ret  = {
        ( map { $_ => $donation->$_ } qw/id/ ),
        donor => {
            name => $immu->donor_name,
            cpf  => $immu->get_column('donor_cpf'),
        },
        captured_at => $donation->captured_at ? $donation->captured_at->datetime : undef,
        amount => $immu->amount,
    };

    return $ret;

}

sub obtain_lock {
    my ($self) = @_;

    my ($lock_myself) =
      $self->result_source->schema->resultset('VotolegalDonation')
      ->search( { 'me.id' => $self->id }, { for => \'UPDATE' } )->next;

    return $lock_myself;
}

sub stash_parsed {
    my ($self) = @_;

    return $self->stash ? from_json( $self->stash ) : {};
}

sub set_new_state {
    my ( $self, $new_state, $new_stash ) = @_;
    $self->update(
        {
            state => $new_state,
            stash => $new_stash ? to_json($new_stash) : undef,
        }
    );

    return 1;
}

sub payment_info_parsed {
    my ($self) = @_;
    return $self->payment_info ? from_json( $self->payment_info ) : {};
}

sub _create_invoice {
    my ($self) = @_;

    my $stash = $self->stash_parsed;

    my $gateway = $self->payment_gateway;
    my $immu    = $self->votolegal_donation_immutable;

    my $invoice = $gateway->create_invoice(
        credit_card_token => $stash->{credit_card_token},
        is_boleto         => $self->is_boleto,

        amount       => $immu->amount,
        candidate_id => $self->candidate_id,

        donation_id => $self->id(),

        payer => {
            cpf_cnpj => $immu->get_column('donor_cpf'),
            name     => $immu->donor_name,
            address  => {
                state    => $immu->billing_address_state,
                city     => $immu->billing_address_city,
                district => $immu->billing_address_district,
                zip_code => $immu->billing_address_zipcode,
                street   => $immu->billing_address_street,
                number   => $immu->billing_address_house_number,
            }
          }

    );

    my $payment_info = $self->payment_info_parsed;
    $payment_info = { %$payment_info, %{ $invoice->{payment_info} } };

    $self->update(
        {
            gateway_tid  => $invoice->{gateway_tid},
            payment_info => to_json($payment_info),
        }
    );

}

sub _generate_payment_credit_card {

    my ($self) = @_;

    my $gateway = $self->payment_gateway;

    my $invoice = $gateway->data_for_credit_card_generation();

    my $payment_info = $self->payment_info_parsed;
    $payment_info = { %$payment_info, %{ $invoice->{payment_info} } };

    $self->update(
        {
            payment_info => to_json($payment_info),
        }
    );
}

sub capture_cc {
    my ($self) = @_;

    my $gateway = $self->payment_gateway;

    my $invoice = $gateway->capture_invoice( donation_id => $self->id, id => $self->gateway_tid );

    my $payment_info = $self->payment_info_parsed;
    $payment_info = { %$payment_info, %{ $invoice->{payment_info} } };

    $self->update(
        {
            payment_info => to_json($payment_info),
            captured_at  => $payment_info->{paid_at},
        }
    );
}

sub sync_gateway_status {
    my ($self) = @_;
    my $gateway = $self->payment_gateway;

    my $invoice = $gateway->get_invoice( donation_id => $self->id, id => $self->gateway_tid );

    my $payment_info = $self->payment_info_parsed;
    $payment_info = { %$payment_info, %{ $invoice->{payment_info} } };

    $self->update(
        {
            payment_info => to_json($payment_info),
        }
    );

    return $self;
}

sub set_boleto_paid {
    my ($self) = @_;

    die 'cannot set_boleto_paid' unless $self->is_boleto;
    die 'cannot set_boleto_paid' unless !$self->captured_at;

    my $payment_info = $self->payment_info_parsed;
    $self->update(
        {
            captured_at => $payment_info->{paid_at},
        }
    );
}

sub generate_certiface_link {
    my ($self) = @_;

    die 'cannot generate_certiface_link after boleto_authentication' unless $self->state eq 'boleto_authentication';

    my $payment_info = $self->payment_info_parsed;

    my $ws = WebService::Certiface->instance;

    my $immu = $self->votolegal_donation_immutable;

    my $certiface = $ws->generate_token(
        {
            cpf        => $immu->donor_cpf,
            telefone   => $immu->donor_phone,
            nome       => $immu->donor_name,
            nascimento => $immu->donor_birthdate->dmy('/'),
        }
    );

    $payment_info->{certiface_id} = $certiface->{id};

    $self->certiface_tokens->create(
        {
            id               => $certiface->{id},
            verification_url => $certiface->{url},
        }
    );

    $self->update(
        {
            payment_info => to_json($payment_info),
        }
    );
}

sub current_certiface {
    my ($self) = @_;

    my $payment_info = $self->payment_info_parsed;

    $payment_info->{certiface_id} or croak 'no certiface_id found';

    return $self->certiface_tokens->search( { id => $payment_info->{certiface_id} } )->next;

}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
