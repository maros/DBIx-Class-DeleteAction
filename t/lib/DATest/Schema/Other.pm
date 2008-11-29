package # hide from PAUSE 
    DATest::Schema::Other;
   
use base 'DBIx::Class';
    
__PACKAGE__->load_components(qw/DeleteAction PK::Auto Core/);
__PACKAGE__->table("other");
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
);
__PACKAGE__->set_primary_key('id');   

__PACKAGE__->has_many(
    'belongs' => 'DATest::Schema::Belongs', 
    { 'foreign.other' => 'self.id' },
    { 
        delete_action   => 'testme',
    }
);

sub testme {
    warn('testme');
}

1;
