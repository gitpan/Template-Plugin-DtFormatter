package Template::Plugin::DtFormatter;

use strict;

use base qw/Template::Plugin/;

use Template::Plugin;
use Template::Exception;
use DateTime;
use DateTime::Format::Strptime;

our $VERSION = "1.00";

# Default formatters
our $formatters = {
    sql         => DateTime::Format::Strptime->new(pattern => '%Y-%m-%d %H:%M:%S'),
    sql_date    => DateTime::Format::Strptime->new(pattern => '%Y-%m-%d'),
    human       => DateTime::Format::Strptime->new(pattern => '%d/%m/%Y, %H:%M'),
    human_date  => DateTime::Format::Strptime->new(pattern => '%d/%m/%Y'),
    hm          => DateTime::Format::Strptime->new(pattern => '%H:%M'),
    hms         => DateTime::Format::Strptime->new(pattern => '%H:%M:%S'),
};

########################################################################
# Purpose    : Define the formatters at application start-up
sub load {
    my ($class, $c) = @_;

    my $self = bless {
        _CONTEXT     => $c,
        _FORMATTERS  => $formatters,
    }, $class;

    return $self;
}

########################################################################
# Purpose    : Accept additional formatters
sub new {
    my ($self, $c, %args) = @_;

    # Allow to pass an user_formatters hashref for custom formatter
    # (which can add to or override the existing ones)
    if ( exists $args{user_formatters} ) {
        my $user_formatters = $args{user_formatters};
        die 'Formatters-must-be-hashref' if ref $user_formatters eq 'HASH';
        for my $user_formatter( %$user_formatters ) {
            $formatters->{ $user_formatter } = $user_formatters->{ $user_formatter };
        }
    }

    return $self;
}

########################################################################
# Puropse    : Format date and/or time depending on user format
# Parameters : Datetime object, and string which speicifies the format
# Returns    : Formatted string of the Datetime object
sub format {
    my ($self, $dt, $format) = @_;
    my ( $formatters ) = @$self{ qw/ _FORMATTERS /};

    if (!ref $dt) { $dt = DateTime->now(time_zone => 'UTC') }

    # Format only if the passed string and dt are valid, otherwise go on
    if ( exists $formatters->{$format} && $dt ) {
        my $formatted_string =
            $formatters->{$format}->format_datetime($dt);

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
    human_date  => DateTime::Format::Strptime->new(pattern => '%d/%m/%Y'),
    hm          => DateTime::Format::Strptime->new(pattern => '%H:%M'),
    hms         => DateTime::Format::Strptime->new(pattern => '%H:%M:%S'),

=head1 SEE ALSO

L<Template>, L<DateTime>.

=head1 AUTHOR

Michele Beltrame, C<mb@italpro.net>.

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
