package VotoLegal::Model::DB;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

use VotoLegal::SchemaConnected qw(get_connection_info);

__PACKAGE__->config(
    schema_class => 'VotoLegal::Schema',
    connect_info => get_connection_info(),
);

=head1 NAME

VotoLegal::Model::DB - Catalyst DBIC Schema Model

=head1 SYNOPSIS

See L<VotoLegal>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema L<VotoLegal::Schema>

=head1 GENERATED BY

Catalyst::Helper::Model::DBIC::Schema - 0.65

=head1 AUTHOR

Junior Moraes

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
