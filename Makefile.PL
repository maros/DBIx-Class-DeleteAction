# Load the Module::Install bundled in ./inc/
use strict;
use inc::Module::Install;

# Define metadata
name            'DBIx-Class-DeleteAction';
all_from        'lib/DBIx/Class/DeleteAction.pm';

perl_version    '5.006';

# Specific dependencies
requires        'DBIx::Class'           => 0;
requires        'SQL::Abstract'         => 0;
requires        'version'               => 0;

build_requires  'DBD::SQLite'           => 0;
build_requires  'Test::Pod'             => 0;
build_requires  'Test::Pod::Coverage'   => 0;
build_requires  'Class::C3'             => 0;
build_requires  'Test::Exception'       => 0;
build_requires  'Test::Warn'            => 0;


WriteAll;