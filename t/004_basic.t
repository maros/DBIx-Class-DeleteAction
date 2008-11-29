# -*- perl -*-

# t/004_basic.t - check basic stuff

use Class::C3;
use strict;
use Test::More;
use Test::Exception;
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
    belongs => $belongs->id
});

isa_ok($main,'DBIx::Class::Row');

throws_ok {
    $main->delete;
} qr/Can't delete the object because it is still referenced from/, 'deny exception';

$belongs->delete();

is($schema->resultset('Belongs')->count,0);
is($schema->resultset('Main')->count,0);

my $belongs2 = $schema->resultset('Belongs')->create({
    name    => 'Belongs.2',
    other   => $other,
});

my $might2 = $schema->resultset('Might')->create({
    name    => 'Might.2',
});

my $main2 = $schema->resultset('Main')->create({
    name    => 'Main.2',
    might   => $might2,
    belongs => $belongs2->id
});

my $many2_1 = $schema->resultset('Many')->create({
    name    => 'Many.2.1',
    main    => $main2,
});

my $many2_2 = $schema->resultset('Many')->create({
    name    => 'Many.2.2',
    main    => $main2,
});

is($schema->resultset('Belongs')->count,1);
is($schema->resultset('Main')->count,1);
is($schema->resultset('Might')->count,1);

$many2_2->delete;
