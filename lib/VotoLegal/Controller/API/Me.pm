package VotoLegal::Controller::API::Me;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

=head1 NAME

VotoLegal::Controller::API::Candidate::Me - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub root : Chained('/api/logged') : PathPart('') : CaptureArgs(0) {
    my ($self, $c) = @_;

    if (!$c->check_user_roles(qw(user))) {
        $self->status_forbidden($c, message => "access denied");
        $c->detach();
    }

    $c->stash->{collection} = $c->user->candidates;
    $c->stash->{candidate}  = $c->stash->{collection}->next;
}

sub base : Chained('root') : PathPart('me') : CaptureArgs(0) { }

sub me : Chained('base') : PathPart('') : ActionClass('REST') { }

sub me_GET {
    my ($self, $c) = @_;

    my $me = $c->stash->{collection}->search(
        undef,
        {
            prefetch => [
                'party',
                { 'candidate_issue_priorities' => 'issue_priority' },
            ],
            result_class => 'DBIx::Class::ResultClass::HashRefInflator'
        }
    )->next;

    return $self->status_ok($c, entity => {
        me => $me,
    });
}

sub me_PUT {
    my ($self, $c) = @_;

    my $picture = $self->_upload_picture($c->req->upload('file'));

    my $candidate = $c->stash->{candidate}->execute(
        $c,
        for => 'update',
        with => {
            %{ $c->req->params },
            picture => $picture,
            roles   => [ $c->user->roles ],
        }
    );

    return $self->status_accepted($c, entity => { id => $candidate->id });
}

sub _upload_picture {
    my ($self, $upload) = @_;

    return unless $upload;

    die \['file', 'empty file']    unless $upload->size > 0;
    die \['file', 'invalid image'] unless $upload->type =~ m{^image\/};

    # TODO Implementar o upload na Amazon S3.
    return "https://avatars0.githubusercontent.com/u/711681?v=3&s=460";
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
