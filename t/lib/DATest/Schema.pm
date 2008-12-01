package # hide from PAUSE 
    DATest::Schema;
    
use base qw/DBIx::Class::Schema/;

__PACKAGE__->load_classes(qw/Test1A Test1B Test2A Test2B Test2C/);

1;