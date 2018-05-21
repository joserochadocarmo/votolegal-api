package VotoLegal::Controller::API::Admin;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

=head1 NAME

VotoLegal::Controller::API::Admin - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub root : Chained('/api/logged') : PathPart('admin') : CaptureArgs(0) {
    my ( $self, $c ) = @_;

    if ( !$c->check_user_roles(qw(admin)) ) {
        $self->status_forbidden( $c, message => "access denied" );
        $c->detach();
    }
}

=encoding utf8

=head1 AUTHOR

Junior Moraes,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
