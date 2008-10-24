# ============================================================================
package DBIx::Class::DeleteAction;
# ============================================================================
use strict;
use warnings;

use base qw(DBIx::Class);

our $VERSION = '1.00';

=encoding utf8

=head1 NAME

DBIx::Class::DeleteAction - Define delete triggers

=head1 SYNOPSIS

 package Your::Schema::Class;
 use strict;
 use warnings;
 
 use base 'DBIx::Class';
 
 __PACKAGE__->load_components(
   "DeleteAction",
   "PK",
   "Core",
 );
 
 __PACKAGE__->table("actor");
 __PACKAGE__->add_columns(qw/name/);
 
 __PACKAGE__->has_many(
    'actorroles' => 'MyDB::Schema::ActorRole',
    'actor',
    { 'foreign.actor' => 'self.id' },
    { delete_action => 'null' }
 );

=head1 DESCRIPTION

With this DBIx::Class component you can specify actions that should be
triggered on a row delete. A delete action is specified by adding the
'delete_acction' key to the optional attribute HASH reference when specifing
a new relation (see L<DBIx::Class::Relationship>).

The following hash values are supported:

=over

=item * null

Set all columns in related rows pointing to this record to NULL.

=item * delete

Delete all related records.

=item * deny

Deny deletion if this record is being referenced from other rows.

=item * CODE reference

Executes the code referece on delete. The current C<DBIx::Class::Row> object 
and the name of the relation are passed to the code reference.

=item * STRING

Execute a method with the given name. The method will be called on the current
C<DBIx::Class::Row> object and will be passed the name of the relation.

=back


=cut

sub delete {
    my ($self, @rest) = @_;

    # Ignore Class deletes. DBIx::Class::Relationship::CascadeActions
    # does too so why should I bother?
    return $self->next::method(@rest) unless ref $self;
    
    # Check if item is in the database before we proceed
    $self->throw_exception( "Not in database" ) unless $self->in_storage;
    
    my $source = $self->result_source;

    # Loop all relations
    foreach my $relationship ($source->relationships) {
        my $relationship_info = $source->relationship_info($relationship);
         
        # Ignore relation with no 'delete_action' key set
        next 
            unless $relationship_info->{attrs}{delete_action};
         
        # Unset DBIC key cascade_delete attribute, so that we do not
        # work twice
        $relationship_info->{attrs}{cascade_delete} = 0;
         
        # Get delete action parameter value
        my $delete_action = $relationship_info->{attrs}{delete_action};

        # Action: NULL
        if ($delete_action eq 'null') {
            if ($relationship_info->{attrs}{accessor} eq 'multi') {
                my $update = {};
                foreach my $key (keys %{$relationship_info->{cond}} ) {
                    next unless
                        $key =~ /^foreign\.(.+)$/;
                    $update->{$1} = undef;    
                }
                $self->search_related($relationship)->udpate($update);
            } else {
                warn("Delete action 'null' does not work with ".$relationship_info->{attrs}{accessor}." relations");
            }
        # Action: DELETE
        } elsif ($delete_action eq 'delete') {
            if ($relationship_info->{attrs}{accessor} eq 'single') {
                warn 'SINGLE'.$self->$relationship;
                $self->$relationship->delete;
            } else {
                warn 'MULTI'.$self->$relationship;
                $self->delete_related($relationship);
            }
        # Action: DENY
        } elsif ($delete_action eq 'deny') {
            if ($self->delete_related($relationship)->count) {
                $self->throw_exception("Can't delete the object because it is still referenced from other records");
            } 
        # Action: CODE
        } elsif (ref $delete_action eq 'CODE') {
            $delete_action->($self,$relationship,@rest);
        # Action: METHOD    
        } elsif ($self->can($delete_action)) {
            $self->$delete_action($relationship,@rest);
        # Fallback
        } else {
            $self->throw_exception("Invalid delete action '$delete_action'")
        }
    }

    # Run delete
    $self->next::method(@rest);
}


=head1 CAVEATS

Note that the C<delete> method in C<DBIx::Class::ResultSet> will not run 
DeleteAction triggers. See C<delete_all> if you need triggers to run.

Any database-level cascade, restrict or trigger will be performed after a 
DBIx-Class-DeleteAction based trigger.

=head1 SUPPORT

Please report any bugs or feature requests to 
C<bug-dbix-class-deleteaction@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/Public/Bug/Report.html?Queue=DBIx::Class::DeleteAction>.
I will be notified, and then you'll automatically be notified of progress on 
your report as I make changes.

=head1 AUTHOR

    Maroš Kollár
    CPAN ID: MAROS
    maros [at] k-1.com
    L<http://www.revdev.at>

=head1 ACKNOWLEDGEMENTS 

This module was written for Revdev L<http://www.revdev.at>, a nice litte
software company I run with Koki and Domm (L<http://search.cpan.org/~domm/>).

=head1 COPYRIGHT

DBIx::Class::DeleteAction is Copyright (c) 2008 Maroš Kollár 
- L<http://www.revdev.at>

This program is free software; you can redistribute it and/or modify it under 
the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut

"Delete me";