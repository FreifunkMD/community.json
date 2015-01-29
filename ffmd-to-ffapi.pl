#!/usr/bin/perl -w

# on debian install packages:
# libjson-perl, libwww-perl, perl-modules, perl-base

use strict;
use warnings;

use Carp;
#use Data::Dumper;
use English qw( -no_match_vars );
use JSON;
use LWP::Simple;

# init variables
my $online_nodes = 0;

# get json
my $content = get('http://map.md.freifunk.net/nodes.json');
croak 'Could not get nodes.json!' unless defined $content;

my $nodes_ref = decode_json($content);

# iterate over nodes
foreach my $node ( @{ $nodes_ref->{'nodes'} } ) {
    if ( !( $node->{'flags'}->{'gateway'}
            || $node->{'flags'}->{'client'} ) )
    {
        if ( $node->{'flags'}->{'online'} ) { $online_nodes++ }
    }
}

# open API template
my $template_file = 'ffmd.json';
my $fh;
my $json_text;
open $fh, '<', $template_file
    or croak "Can't open '$template_file': $OS_ERROR";
{
    undef $INPUT_RECORD_SEPARATOR;
    $json_text = <$fh>;
}
close $fh
    or croak "Can't close '$template_file' after reading: $OS_ERROR";
my $api_ref = decode_json($json_text);

# update and print json
$api_ref->{'state'}->{'nodes'} = $online_nodes;
$api_ref->{'state'}->{'lastchange'} = $nodes_ref->{'meta'}->{'timestamp'};
print encode_json($api_ref);

# vim: set ft=perl et sts=0 ts=4 sw=4 sr:
