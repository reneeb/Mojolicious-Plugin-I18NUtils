package Mojolicious::Plugin::I18NUtils;

# ABSTRACT: provide some helper functions for I18N
use Mojo::Base 'Mojolicious::Plugin';
use Time::Piece;
use CLDR::Number;

our $VERSION = '0.06';

sub register {
    my ($self, $app, $config) = @_;

    $config //= {};
    my $parse_format = $config->{format} // '%Y-%m-%d %H:%M:%S';

    my %objects;

    $app->helper( datetime_loc => sub {
        my $c = shift;
        my ($date, $lang) = @_;

        my $output_format  = $self->_date_long( $lang );
        my $formatted_date = $self->_translate( $date, $parse_format, $output_format );

        return $formatted_date;
    } );

    $app->helper( date_loc => sub {
        my $c = shift;
        my ($date, $lang) = @_;

        my $output_format  = $self->_date_short( $lang );
        my $formatted_date = $self->_translate( $date, $parse_format, $output_format );

        return $formatted_date;
    } );

    $app->helper( currency => sub {
        my ($c, $number, $locale, $currency) = @_;

        $objects{cldr}->{$locale} ||= CLDR::Number->new( locale => $locale );
        $objects{cur}->{$locale}  ||= $objects{cldr}->{$locale}->currency_formatter( currency_code => $currency );

        my $formatted = $objects{cur}->{$locale}->format( $number );
        return $formatted;
    } );

    $app->helper( decimal => sub {
        my ($c, $number, $locale) = @_;

        $objects{cldr}->{$locale} ||= CLDR::Number->new( locale => $locale );
        $objects{dec}->{$locale}  ||= $objects{cldr}->{$locale}->decimal_formatter;

        my $formatted = $objects{dec}->{$locale}->format( $number );
        return $formatted;
    } );
}

sub _translate {
    my ($self, $date, $in, $out) = @_;

    if ( length $date < 11 ) {
        $date .= ' 00:00:00';
    }

    my $date_obj = Time::Piece->strptime( $date, $in );
    my $out_date = $date_obj->strftime( $out );

    return $out_date;
}

sub _date_long {
    my ($self, $lang) = @_;

    return "%Y.%m.%d %H:%M:%S" if !$lang;

    state $formats = {
        ar_SA   => '%d.%m.%Y %H:%M:%S',
        bg      => '%d.%m.%Y %H:%M:%S',
        ca      => '%d.%m.%Y %H:%M:%S',
        cs      => '%d/%m/%Y %H:%M:%S',
        da      => '%d.%m.%Y %H:%M:%S',
        de      => '%d.%m.%Y %H:%M:%S',
        el      => '%d.%m.%Y %H:%M:%S',
        en_CA   => '%Y-%m-%d %H:%M:%S',
        en_GB   => '%d/%m/%Y %H:%M:%S',
        en      => '%m/%d/%Y %H:%M:%S',
        es_CO   => '%d/%m/%Y - %H:%M:%S',
        es_MX   => '%d/%m/%Y - %H:%M:%S',
        es      => '%d/%m/%Y - %H:%M:%S',
        et      => '%d.%m.%Y %H:%M:%S',
        fa      => '%d.%m.%Y %H:%M:%S',
        fi      => '%d.%m.%Y %H:%M:%S',
        fr_CA   => '%d.%m.%Y %H:%M:%S',
        fr      => '%d.%m.%Y %H:%M:%S',
        he      => '%d/%m/%Y %H:%M:%S',
        hi      => '%d/%m/%Y - %H:%M:%S',
        hr      => '%d.%m.%Y %H:%M:%S',
        hu      => '%Y.%m.%d %H:%M:%S',
        it      => '%d/%m/%Y %H:%M:%S',
        ja      => '%Y/%m/%d %H:%M:%S',
        lt      => '%Y-%m-%d %H:%M:%S',
        lv      => '%d.%m.%Y %H:%M:%S',
        ms      => '%d.%m.%Y %H:%M:%S',
        nb_NO   => '%d/%m %Y %H:%M:%S',
        nl      => '%d-%m-%Y %H:%M:%S',
        pl      => '%Y-%m-%d %H:%M:%S',
        pt_BR   => '%d/%m/%Y %H:%M:%S',
        pt      => '%Y-%m-%d %H:%M:%S',
        ru      => '%d.%m.%Y %H:%M:%S',
        sk_SK   => '%d.%m.%Y %H:%M:%S',
        sl      => '%d.%m.%Y %H:%M:%S',
        sr_Cyrl => '%d.%m.%Y %H:%M:%S',
        sr_Latn => '%d.%m.%Y %H:%M:%S',
        sv      => '%d/%m %Y %H:%M:%S',
        sw      => '%m/%d/%Y %H:%M:%S',
        tr      => '%d.%m.%Y %H:%M:%S',
        uk      => '%m/%d/%Y %H:%M:%S',
        vi_VN   => '%d.%m.%Y %H:%M:%S',
        zh_CN   => '%Y.%m.%d %H:%M:%S',
        zh_TW   => '%Y.%m.%d %H:%M:%S',
    };

    return $formats->{$lang} // '%Y.%m.%d %H:%M:%S';
}

sub _date_short {
    my ($self, $lang) = @_;

    return "%Y.%m.%d" if !$lang;

    state $formats = {
        ar_SA   => '%d.%m.%Y',
        bg      => '%d.%m.%Y',
        ca      => '%d.%m.%Y',
        cs      => '%d/%m/%Y',
        da      => '%d.%m.%Y',
        de      => '%d.%m.%Y',
        el      => '%d.%m.%Y',
        en_CA   => '%Y-%m-%d',
        en_GB   => '%d/%m/%Y',
        en      => '%m/%d/%Y',
        es_CO   => '%d/%m/%Y',
        es_MX   => '%d/%m/%Y',
        es      => '%d/%m/%Y',
        et      => '%d.%m.%Y',
        fa      => '%d.%m.%Y',
        fi      => '%d.%m.%Y',
        fr_CA   => '%d.%m.%Y',
        fr      => '%d.%m.%Y',
        he      => '%d/%m/%Y',
        hi      => '%d/%m/%Y',
        hr      => '%d.%m.%Y',
        hu      => '%Y.%m.%d',
        it      => '%d/%m/%Y',
        ja      => '%Y/%m/%d',
        lt      => '%Y-%m-%d',
        lv      => '%d.%m.%Y',
        ms      => '%d.%m.%Y',
        nb_NO   => '%d.%m.%Y',
        nl      => '%d-%m-%Y',
        pl      => '%Y-%m-%d',
        pt_BR   => '%d/%m/%Y',
        pt      => '%Y-%m-%d',
        ru      => '%d.%m.%Y',
        sk_SK   => '%d.%m.%Y',
        sl      => '%d.%m.%Y',
        sr_Cyrl => '%d.%m.%Y',
        sr_Latn => '%d.%m.%Y',
        sv      => '%Y.%m.%d',
        sw      => '%m/%d/%Y',
        tr      => '%d.%m.%Y',
        uk      => '%m/%d/%Y',
        vi_VN   => '%d.%m.%Y',
        zh_CN   => '%Y.%m.%d',
        zh_TW   => '%Y.%m.%d',
    };

    return $formats->{$lang} // '%Y.%m.%d';
}

1;

=head1 SYNOPSIS

In your C<startup>:

    sub startup {
        my $self = shift;
  
        # do some Mojolicious stuff
        $self->plugin( 'I18NUtils' );

        # more Mojolicious stuff
    }

In your template:

    <%= datetime_loc('2014-12-10', 'de') %>

=head1 CONFIGURE

If you use a default format other than I<%Y-%m-%d %H:%M:%S> for dates in your
application, you can set a format for the parser. E.g. if your dates look like

  10.12.2014 12:34:56

You can add the plugin this way

  $self->plugin( I18NUtils => { format => '%d.%m.%Y %H:%M:%S' } );

=head1 HELPERS

This plugin adds two helper methods to your web application:

=head2 datetime_loc

This helper returns the givent date and time in the localized format.

 <%= datetime_loc('2014-12-10 11:12:13', 'de') %>

will return

 10.12.2014 11:12:13

=head2 date_loc

Same as C<datetime_loc>, but omits the time

 <%= date_loc('2014-12-10 11:12:13', 'de') %>

will return

 10.12.2014

=head1 METHODS

=head2 register

Called when registering the plugin.

    # load plugin, alerts are dismissable by default
    $self->plugin( 'I18NUtils' );

