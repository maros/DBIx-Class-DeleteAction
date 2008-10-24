package # hide from PAUSE 
    DATest::Schema::Many;
   
use base 'DBIx::Class';
    
__PACKAGE__->load_components(qw/DeleteAction PK::Auto Core/);
__PACKAGE__->table("main");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    is_nullable => 0,
  },
  "name",
  {
    data_type => "varchar",
    is_nullable => 0,
  },
  "main",
  {
    data_type => "integer",
    is_nullable => 0,
  },
  
);
__PACKAGE__->set_primary_key('id');   

__PACKAGE__->belongs_to(
    'main' => 'DATest::Schema::Main', 
    'main',
    { 
        delete_action   => 'delete',
    }
);

1;
