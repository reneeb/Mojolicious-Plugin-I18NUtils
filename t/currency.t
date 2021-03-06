#!/usr/bin/env perl

use Mojolicious::Lite;

use utf8;
use open qw( :encoding(UTF-8) :std );
use Test::More;
use Test::Mojo;

use_ok 'Mojolicious::Plugin::I18NUtils';

## Webapp START

plugin('I18NUtils');

any '/'      => sub {
    my $self = shift;

    my $lang     = $self->param('lang');
    my $price    = '9.99';
    my $currency = 'EUR';

    $self->render( text => $self->currency( $price, $lang, $currency ) );
};

## Webapp END

my $t = Test::Mojo->new;

my %tests = (
    de    => "9,99\x{a0}€",
    en_CA => '€9.99',
    en_GB => '€9.99',
    en    => '€9.99',
    es    => "9,99\x{a0}€",
    es_MX => "EUR\x{a0}9.99",
    zh_CN => '€9.99',
);

for my $lang ( sort keys %tests ) {
    $t->get_ok( "/?lang=$lang" )->status_is( 200 )->content_is( $tests{$lang}, "test language $lang" );
}

done_testing();

