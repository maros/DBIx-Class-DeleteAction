package # hide from PAUSE 
    DATest::Schema;
    
use base qw/DBIx::Class::Schema/;

__PACKAGE__->load_classes(qw/Main Many Belongs Might Other/);

1;