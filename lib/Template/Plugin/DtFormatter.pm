package Template::Plugin::DtFormatter;

use strict;

use base qw/Template::Plugin/;

use Template::Plugin;
use Template::Exception;
use DateTime;
use DateTime::Format::Strptime;

our $VERSION = "1.10";

# Default formatters
our $formatters = {
    sql         => DateTime::Format::Strptime->new(pattern => '%Y-%m-%d %H:%M:%S'),
    sql_date    => DateTime::Format::Strptime->new(pattern => '%Y-%m-%d'),
    human       => DateTime::Format::Strptime->new(pattern => '%d/%m/%Y, %H:%M'),
    human2      => DateTime::Format::Strptime->new(pattern => '%d-%m-%Y, %H:%M'),
    human_date  => DateTime::Format::Strptime->new(pattern => '%d/%m/%Y'),
    human_date2 => DateTime::Format::Strptime->new(pattern => '%d-%m-%Y'),
    h           => DateTime::Format::Strptime->new(pattern => '%H'),
    hm          => DateTime::Format::Strptime->new(pattern => '%H:%M'),
    hms         => DateTime::Format::Strptime->new(pattern => '%H:%M:%S'),
    year        => DateTime::Format::Strptime->new(pattern => '%Y'),
    dm          => DateTime::Format::Strptime->new(pattern => '%d/%m'),
};

########################################################################
# Purpose    : Define the formatters at application start-up
sub load {
    my ($class, $c) = @_;

    return $class;
}

########################################################################
# Purpose    : Almost now
sub new {
    my ($class, $c, @args) = @_;

    if (@args > 0) {
        my $params = $args[0];

        # Allow to pass an user_formatters hashref for custom formatter
        # (which can add to or override the existing ones)
        if ( exists $params->{formatters} ) {
            my $user_formatters = $params->{formatters};
            die 'Formatters-must-be-hashref' if ref $user_formatters ne 'HASH';
            for my $user_formatter ( keys %$user_formatters ) {
                $formatters->{ $user_formatter } = $user_formatters->{ $user_formatter };
            }
        }

        # Allow to pass a user_patterns hashref for custom Strptime patterns
        if ( exists $params->{patterns} ) {
            my $user_patterns = $params->{patterns};
            die 'Pattern-must-be-hashref' if ref $user_patterns ne 'HASH';
            for my $user_pattern ( keys %$user_patterns ) {
                $formatters->{ $user_pattern } = DateTime::Format::Strptime->new(
                    pattern => $user_patterns->{ $user_pattern }
                );
            }
        }
    }

    my $self = bless {
        _CONTEXT     => $c,
        _FORMATTERS  => $formatters,
    }, $class;

    return $self;
}

########################################################################
# Puropse    : Format date and/or time depending on user format
# Parameters : Datetime object, and string which speicifies the format
# Returns    : Formatted string of the Datetime object
sub format {
    my ($self, $dt, $format) = @_;
    my ( $display_formatters ) = @$self{ qw/ _FORMATTERS /};

    if (!ref $dt) { $dt = DateTime->now(time_zone => 'UTC') }

    # Format only if the passed string and dt are valid, otherwise go on
    if ( exists $display_formatters->{$format} && $dt ) {
        my $formatted_string =
            $display_formatters->{$format}->format_datetime($dt);

        return $formatted_string;
    }

    return;
}

1;

__END__

=head1 NAME

Template::Plugin::DtFormatter - Easily create formatted string from DateTime
objects

=head1 SYNOPSIS

  [% USE DtFormatter %]
  [% DtFromatter.format(mydt, 'human') %]

  15/February/2007, 11:55

  [% DtFromatter.format(mydt, 'hm') %]

  11:55

=head1 DESCRIPTION

This modules provides a simple mean of formatting DateTime object in TT templates.
It provides some predefined formatter C<formatters>, and you can extend it by
providing your own or overriding existing ones.

The advantage of C<dtformatter> is that, basically, it provides human-readable
shortcuts for format strings, which allow you to just modify the formatter
in the module configuration to affect all the dates displayed using it.

Use this way:

    [% USE DtFormatter %]
    [% DtFormatter.format(DateTime_object, formatter_name) %]

=head1 PREDEFINED FORMATTERS

These are the predefined C<formatters>. They all use L<DateTime::Format::Strptime>,
so that is the only dependency of this module.

    sql         => DateTime::Format::Strptime->new(pattern => '%Y-%m-%d %H:%M:%S'),
    sql_date    => DateTime::Format::Strptime->new(pattern => '%Y-%m-%d'),
    human       => DateTime::Format::Strptime->new(pattern => '%d/%m/%Y, %H:%M'),
    human2      => DateTime::Format::Strptime->new(pattern => '%d-%m-%Y, %H:%M'),
    human_date  => DateTime::Format::Strptime->new(pattern => '%d/%m/%Y'),
    human_date2 => DateTime::Format::Strptime->new(pattern => '%d-%m-%Y'),
    h           => DateTime::Format::Strptime->new(pattern => '%H'),
    hm          => DateTime::Format::Strptime->new(pattern => '%H:%M'),
    hms         => DateTime::Format::Strptime->new(pattern => '%H:%M:%S'),
    year        => DateTime::Format::Strptime->new(pattern => '%Y'),
    dm          => DateTime::Format::Strptime->new(pattern => '%d/%m'),

=head1 USER DEFINED FORMATTERS

You can define the formatters (or override existing ones), in two ways. The first
is to provide patterns for L<DateTime::Format::Strptime> using an hashref:

    [% USE DtFormatter( patterns => { 'jazz' => '%H - %Y' } ) %]
    [% DtFormatter.format(DateTime_object, 'jazz') %]

You can also provide any valid DateTime format object. For instance, if you
want an Excel-style date:

    [% USE DtFormatter( formatters =>
        { 'excel' => DateTime->Format->Excel->new() }
    ) %]
    [% DtFormatter.format(DateTime_object, 'excel') %]

=head1 SEE ALSO

L<Template>, L<DateTime>.

=head1 AUTHOR

Michele Beltrame, C<mb@italpro.net>.

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
