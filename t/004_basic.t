# -*- perl -*-

# t/004_basic.t - check basic stuff

use Class::C3;
use strict;
use Test::More;
use warnings;
no warnings qw(once);

BEGIN {
    eval "use DBD::SQLite";
    plan $@
        ? ( skip_all => 'needs DBD::SQLite for testing' )
        : ( tests => 30 );
}

use lib qw(t/lib);

use_ok( 'DATest' );

use_ok( 'DATest::Schema' );

my $schema = DATest->init_schema();

my $other = $schema->resultset('Other')->create({
    name    => 'Other.1',
});

my $belongs = $schema->resultset('Belongs')->create({
    name    => 'Belongs.1',
    other   => $other,
});



$belongs->insert;


my $main = $schema->resultset('Main')->create({
    name    => 'Main.1',
    might   => undef,
    belongs => $belongs
});

isa_ok($main,'DBIx::Class::Row');