use Test::More tests => 1;

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

1;

