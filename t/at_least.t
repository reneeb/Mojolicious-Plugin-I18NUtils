#!/usr/bin/env perl

use Mojolicious::Lite;

use utf8;
use Test::More;
use Test::Mojo;

use_ok 'Mojolicious::Plugin::I18NUtils';

## Webapp START

plugin('I18NUtils');

any '/'      => sub {
    my $self = shift;

    my $lang   = $self->param('lang');
    my $number = '2000';

    $self->render( text => $self->at_least( $number, $lang ) );
};

## Webapp END

my $t = Test::Mojo->new;

my %tests = (
    de    => '2.000+',
    en_CA => '2,000+',
    en_GB => '2,000+',
    en    => '2,000+',
    es    => "M\x{e1}s de 2\x{a0}000",
    es_CO => "M\x{e1}s de 2.000",
    zh_CN => '2,000+',
    bn    => "\x{09e8}," . ( "\x{09e6}" x 3 ) . "+",
    ar    => "+\x{0662}" . "\x{066c}" . ( "\x{0660}" x 3 ),
);

for my $lang ( sort keys %tests ) {
    $t->get_ok( "/?lang=$lang" )->status_is( 200 )->content_is( $tests{$lang}, "test language $lang" );
}

done_testing();

