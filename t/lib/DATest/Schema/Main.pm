package # hide from PAUSE 
    DATest::Schema::Main;
   
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
  "might",
  {
    data_type => "integer",
    is_nullable => 1,
  },
  "belongs",
  {
    data_type => "integer",
    is_nullable => 0,
  },
);
__PACKAGE__->set_primary_key('id');   

__PACKAGE__->has_many(
    'many' => 'DATest::Schema::Many', 
    { 'foreign.main'  => 'self.id' },
    { 
        delete_action   => 'null',
    }
);

__PACKAGE__->belongs_to(
    'belongs' => 'DATest::Schema::Belongs', 
    { 'foreign.id'  => 'self.belongs' },
    { 
        delete_action   => 'deny',
    }
);
    
__PACKAGE__->might_have(
    'might' => 'DATest::Schema::Might', 
    { 'foreign.id'  => 'self.might' },
    { 
        delete_action   => sub {
            my ($self,$relation,@rest) = @_;
        },
    }
);
    
1;
