use Test::More tests => 3;

use strict;
use Template;
use DateTime;

# ### Format a DT object ####

my $template_source = "
[%- USE DtFormatter -%]
[% DtFormatter.format(mydt, 'sql') %]";

my $t = Template->new();

my $output;
my $stash = {
    mydt => DateTime->new(
        year      => 2007,
        month     => 03,
        day       => 15,
        hour      => 19,
        minute    => 16,
        time_zone => 'UTC',
    ),
};

$t->process(\$template_source, $stash, \$output) or die "Can't process template: $!";

ok( $output eq '2007-03-15 19:16:00' );

# ### Custom pattern ###

$template_source = "
[%- USE DtFormatter(patterns => { funky => '%H:%M -- %Y' }) -%]
[% DtFormatter.format(mydt, 'funky') %]";

$output = '';
$t->process(\$template_source, $stash, \$output) or die "Can't process template: $!";

ok( $output eq '19:16 -- 2007' );

# ### Custom formatter ###

$stash->{rockformatter} = DateTime::Format::Strptime->new(pattern => '%S / %H');

$template_source = "
[%- USE DtFormatter(formatters => { rock => rockformatter }) -%]
[% DtFormatter.format(mydt, 'rock') %]";

$output = '';
$t->process(\$template_source, $stash, \$output) or die "Can't process template: $!";

ok( $output eq '00 / 19' );

1;

