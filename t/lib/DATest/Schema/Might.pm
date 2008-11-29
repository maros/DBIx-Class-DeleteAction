package # hide from PAUSE 
    DATest::Schema::Might;
   
use base 'DBIx::Class';
    
__PACKAGE__->load_components(qw/DeleteAction PK::Auto Core/);
__PACKAGE__->table("might");
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
    'mains' => 'DATest::Schema::Main', 
    { 'foreign.might' => 'self.id' },
    { 
        delete_action   => 'testme',
    }
);

sub testme {
    my ($self,$relation,@rest) = @_;
}
1;
