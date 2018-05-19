package VotoLegal;
use Moose;
use utf8;
use namespace::autoclean;
use VotoLegal::Utils qw/remote_notify/;
use Catalyst::Runtime 5.80;
use Data::Dumper qw/Dumper/;

BEGIN {
    $ENV{POSTGRESQL_HOST}     ||= '127.0.0.1';
    $ENV{POSTGRESQL_PORT}     ||= '5432';
    $ENV{POSTGRESQL_DBNAME}   ||= 'votolegal_dev';
    $ENV{POSTGRESQL_USER}     ||= 'postgres';
    $ENV{POSTGRESQL_PASSWORD} ||= 'trust';
}

use Catalyst qw/
  ConfigLoader
  Authentication
  Authorization::Roles
  I18N
  /;
extends 'Catalyst';

our $VERSION = '0.01';

__PACKAGE__->config(
    name           => 'VotoLegal',
    encoding       => 'UTF-8',
    'Plugin::I18N' => {
        maketext_options => {
            Path   => __PACKAGE__->path_to('lib/VotoLegal/I18N'),
            Decode => 1,
        }
    },

    using_frontend_proxy => 1,

    disable_component_resolution_regex_fallback => 1,
    enable_catalyst_header                      => 0,
);

after setup_finalize => sub {
    my $app = shift;

    for ( $app->registered_plugins ) {
        if ( $_->can('initialize_after_setup') ) {
            $_->initialize_after_setup($app);
        }
    }
    $app->model('DB')->schema->load_envs();
};

# Start the application
__PACKAGE__->setup();

sub build_api_error {
    my ( $app, %args ) = @_;
    my $msg_id = $args{msg_id};

    $msg_id =~ s/[ -]/_/go;

    my $loc_msg = $app->loc($msg_id);

    if ( $loc_msg eq $msg_id && $msg_id =~ /_missing$/ ) {
        $msg_id =~ s/_missing/_invalid/;
        $loc_msg = $app->loc($msg_id);
    }

    if ( $loc_msg eq $msg_id ) {

        remote_notify(
            sprintf( "[Voto Legal] Faltando traducao para msg_id=$msg_id [hostname=%s] [%s]",
                    $app->req->uri->as_string
                  . ( $app->req->data   ? Dumper( $app->req->data )   : '' ) . " - "
                  . ( $app->req->params ? Dumper( $app->req->params ) : '' ) ),
            channel => '#api-error'
        );

    }

    if ( $loc_msg =~ /invalid/ ) {
        $loc_msg =~ s/_invalid/ com valor inválido/;
    }
    my %err = (
        msg_id  => $msg_id,
        message => $loc_msg
    );

    $err{form_field} = $args{form_field} if $args{form_field};
    $err{extra}      = $args{extra}      if exists $args{extra};
    $err{reason}     = $args{reason}     if exists $args{reason};

    return \%err;
}

1;
