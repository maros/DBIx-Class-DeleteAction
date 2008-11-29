package # hide from PAUSE 
    DATest::Schema::Belongs;
   
use base 'DBIx::Class';
    
__PACKAGE__->load_components(qw/DeleteAction PK::Auto Core/);
__PACKAGE__->table("belongs");
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
  "other",
  {
    data_type => "integer",
    is_nullable => 0,
  },
);
__PACKAGE__->set_primary_key('id');   

__PACKAGE__->has_many(
    'main' => 'DATest::Schema::Main', 
    { 'foreign.belongs' => 'self.id' },
    { 
        delete_action   => 'delete',
    }
);

__PACKAGE__->has_one(
    'other' => 'DATest::Schema::Other', 
    { 'foreign.id' => 'self.other' },
);

1;
