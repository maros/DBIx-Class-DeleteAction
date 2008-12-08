package # hide from PAUSE 
    DATest::Schema::Test4A;
   
use base 'DBIx::Class';
    
__PACKAGE__->load_components(qw/DeleteAction PK::Auto Core/);
__PACKAGE__->table("test4_A");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    is_nullable => 0,
  },
  "name",
  {
    data_type => "varchar",
    is_nullable => 1,
  },
  "a",
  {
    data_type => "integer",
    is_nullable => 1,
  },
);
__PACKAGE__->set_primary_key('id');   

__PACKAGE__->might_have(
    'a' => 'DATest::Schema::Test4A', 
    { 'foreign.id'  => 'self.a' },
    { 
        delete_action   => 'bogus',
    }
);


   
1;