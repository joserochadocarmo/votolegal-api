use utf8;
package VotoLegal::Schema::Result::CertifaceReturnUrl;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

VotoLegal::Schema::Result::CertifaceReturnUrl

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

=head1 TABLE: C<certiface_return_url>

=cut

__PACKAGE__->table("certiface_return_url");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_nullable: 0

=head2 url

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_nullable => 0 },
  "url",
  {
    data_type   => "text",
    is_nullable => 0,
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

=head2 candidates

Type: has_many

Related object: L<VotoLegal::Schema::Result::Candidate>

=cut

__PACKAGE__->has_many(
  "candidates",
  "VotoLegal::Schema::Result::Candidate",
  { "foreign.use_certiface_return_url_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 certiface_tokens

Type: has_many

Related object: L<VotoLegal::Schema::Result::CertifaceToken>

=cut

__PACKAGE__->has_many(
  "certiface_tokens",
  "VotoLegal::Schema::Result::CertifaceToken",
  { "foreign.certiface_return_url_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2018-05-18 17:05:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:+3WX5V9iCRxEIQpk01y6xA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
