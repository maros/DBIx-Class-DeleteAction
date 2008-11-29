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

sub _delete_identifier {
    my $self = shift;
    my @primary = $self->primary_columns;
    return ref($self) . join '|',map { $self->get_column($_) } @primary;
}

sub delete {
    my ($self, $seen) = @_;

    $seen ||= [];
    
    
    # Build data identifier
    my $identifier = $self->_delete_identifier;
    
    # Check for identifier
    return if (grep { $identifier eq $_ } @$seen);
    
    push @$seen,$identifier;

    # Ignore Class deletes. DBIx::Class::Relationship::CascadeActions
    # does too so why should I bother?
    return $self->next::method() unless ref $self;
    
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

        # This would be much nicer with 5.10s given/when/default
        
        my $related;
        # Only get relations with data
        if ($relationship_info->{attrs}{accessor} eq 'multi') {
            $related = $self->search_related($relationship);
            next unless $related->count;
        } else {
            # We might speed this up by analyzing $relationship_info->{cond}
            $related = $self->$relationship;
            next unless $related;
        }
        
        # Action: NULL
        if ($delete_action eq 'null') {
            warn('SET NULL '.$self.'->'.$relationship_info->{source});
            if ($relationship_info->{attrs}{accessor} eq 'multi') {
                my $update = {};
                foreach my $key (keys %{$relationship_info->{cond}} ) {
                    next unless
                        $key =~ /^foreign\.(.+)$/;
                    $update->{$1} = undef;    
                }
                $related->update($update);
            } else {
#                foreach my $column (keys %{$relationship_info->{cond}}) {
#                    next unless $column =~ /^foreign\.(.+)$/;
#                    $column = $1;
#                    warn('SET COLUMN '.$1);
#                    $related->set_column($1,undef);
#                }
#                $related->update();
                warn("Delete action 'null' does not work with ".$relationship_info->{attrs}{accessor}." relations");
            }
        # Action: DELETE
        } elsif ($delete_action eq 'delete') {
            warn('DELETE '.$self.'->'.$relationship_info->{source});
            if ($related->isa('DBIx::Class::ResultSet')) {
                while (my $item = $related->next) {
                    $item->delete($seen);
                }
            } else {
                $related->delete($seen);
            }
        # Action: DENY
        } elsif ($delete_action eq 'deny') {
            warn('DENY '.$self.'->'.$relationship_info->{source}.$relationship_info->{attrs}{accessor});
            if ($related->isa('DBIx::Class::ResultSet')) {
                while (my $item = $related->next) {
                    my $compare_identifier = $item->_delete_identifier;
                    next if grep {$compare_identifier eq $_} @$seen;
                    $self->throw_exception("Can't delete the object because it is still referenced from other records");
                }
            } else {
                my $compare_identifier = $related->_delete_identifier;
                unless (grep {$compare_identifier eq $_} @$seen) {
                    $self->throw_exception("Can't delete the object because it is still referenced from other records");
                }
            }
            
           
        # Action: CODE
        } elsif (ref $delete_action eq 'CODE') {
            warn('CODE '.$self.'->'.$relationship_info->{source});
            $delete_action->($self,$relationship,$related,$seen);
        # Action: METHOD    
        } elsif ($self->can($delete_action)) {
            warn('METHOD '.$self.'->'.$relationship_info->{source});
            $self->$delete_action($relationship,$related,$seen);
        # Fallback
        } else {
            $self->throw_exception("Invalid delete action '$delete_action'")
        }
    }

    # Run delete
    $self->next::method();
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