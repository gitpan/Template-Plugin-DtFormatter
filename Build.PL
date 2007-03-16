use strict;
use Module::Build;

my %arguments = (
    #create_makefile_pl => 'passthrough',
    create_makefile_pl  => 'traditional',
    license            => 'perl',
    module_name        => 'Template::Plugin::DtFormatter',
    requires           => {
        'Template'                    => 2.15,
        'DateTime'         	      => 0.32,
        'DateTime::Format::Strptime'  => 1.0700,
    },
    build_requires      => {
#        'Test::Exception'   => 0
    },
);

my $build = Module::Build->new(%arguments);
$build->create_build_script();
