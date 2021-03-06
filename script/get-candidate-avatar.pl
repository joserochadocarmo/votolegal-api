#!/usr/bin/env perl

use common::sense;
use FindBin qw($RealBin $Script);
use lib "$RealBin/../lib";
use Moose;
use namespace::autoclean;

use File::MimeInfo;
use LWP::Simple;

use VotoLegal::SchemaConnected;
use VotoLegal::Uploader;

my $schema   = get_schema;
my $uploader = VotoLegal::Uploader->new();

my $candidate_rs = $schema->resultset("Candidate")->search(
    {
        avatar  => \'IS NULL',
        picture => \'IS NOT NULL'
    }
);

while ( my $candidate = $candidate_rs->next() ) {
    my $picture = $candidate->picture;
    my $tmp_pic = '/tmp/' . $candidate->id . '_avatar.jpg';

    getstore($picture, $tmp_pic);

    resize_image($tmp_pic);

    my $avatar = upload_picture($uploader, $tmp_pic);

    printf "UPDATE candidate SET avatar = '%s' WHERE id = %d;\n", $avatar, $candidate->id;
}

sub resize_image {
    my ($image) = @_;

	my $conv = `convert $image -resize 180x180 $image`;

    return $image;
}

sub upload_picture {
    my ($uploader, $picture) = @_;

    my $mimetype = mimetype( $picture );
	die \[ 'picture', 'invalid image' ] unless $mimetype =~ m{^image\/};

	my $avatar_url = $uploader->upload(
		{
			path => $picture,
			file => $picture,
			type => $mimetype,
		}
	);

    return $avatar_url->as_string;
}