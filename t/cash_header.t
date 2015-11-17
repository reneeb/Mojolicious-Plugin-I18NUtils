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

    my $price    = '9.99';
    my $currency = 'CHF';

    $self->render( text => $self->currency( $price, undef, $currency, { cash => 1 } ) );
};

## Webapp END

my $t = Test::Mojo->new;

my %headers = (
    de    => { 'Accept-Language' => 'de-DE' },
    en    => { 'Accept-Language' => 'en' },
    en_CA => { 'Accept-Language' => 'en-CA' },
    es    => { 'Accept-Language' => 'es' },
    ar    => { 'Accept-Language' => 'ar' },
    es_MX => { 'Accept-Language' => 'es-MX' },
);

my %tests = (
    de    => "10,00\x{a0}CHF",
    en_CA => "CHF\x{a0}10.00",
    en_GB => "CHF\x{a0}10.00",
    en    => "CHF\x{a0}10.00",
    es    => "10,00\x{a0}CHF",
    es_MX => "CHF\x{a0}10.00",
    zh_CN => "CHF 10.00",
    de_CH => "CHF\x{a0}10.00",
);

for my $lang ( sort keys %tests ) {
    $t->get_ok( "/" => ( $headers{$lang} || $headers{en} ) )->status_is( 200 )->content_is( $tests{$lang}, "test language $lang" );
}

done_testing();

