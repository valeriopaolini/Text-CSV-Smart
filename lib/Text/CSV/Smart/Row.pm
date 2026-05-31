package Text::CSV::Smart::Row;

use strict;
use warnings;

use Carp;
use Data::Dumper;

sub new {
  my $class = shift;
  
  my $self = {
    fields => undef,
    values => undef,
    map    => {},
    width  => 1,
  };

  if (scalar @_ == 1 && ref $_[0] eq 'ARRAY') {
    $self->{fields} = shift;
  }

  elsif (scalar @_ == 1 && ref $_[0] eq 'HASH') {
    my $tmp = shift;
    my %map = map { $_ => 1 } qw/ fields values width /;
    while (my ($field, $value) = each %$tmp) {
      confess "unknown field '$field'" unless exists $map{ $field };
      $self->{$field} = $value;
    }
  }

  elsif (scalar @_ == 2) {
    $self->{fields} = shift;
    $self->{values} = shift;
  }

  else {
    confess "wrong argument to new, see documentation";
  }
  
  if (ref $self->{fields} ne 'ARRAY') {
    confess sprintf "fields argument is not an ARRAY ref (it is '%s': )", ref $self->{fields} || 'SCALAR', $self->{fields} || '(empty)';
  }
    
  if (defined $self->{values} && ref $self->{values} ne 'ARRAY') {
    confess "values argument is not an ARRAY ref";
  }

  my $count = 0;
  my %map;
  foreach my $field (@{ $self->{fields} }) {
    $map{ $field } = $count;
    $count++;
  }
  confess "empty list of fields" unless $count;
  $self->{map} = \%map;
  
  if ($self->{width}) {
    if (defined $self->{values} && scalar @{ $self->{fields} } != scalar @{ $self->{values} }) {
      #print Dumper($self->{fields}, $self->{values});
      confess sprintf "wrong number of values: got %s expected %s", scalar @{ $self->{fields} }, scalar @{ $self->{values} };
    }
  }

  bless $self, $class;
  return $self;
}

sub _data {
  my $self = shift;
  my %row = map { $_ => $self->{values}[ $self->{map}{$_} ] } @{ $self->{fields} };
  return \%row;
}

sub _clone {
  my ($self, $fields) = @_;
  my @fields = defined $fields ? @$fields : @{ $self->_fields };
  my @values = map { $self->_get($_) } @fields;
  return Text::CSV::Smart::Row->new(\@fields, \@values);
}

sub _map { shift->{map}; }

sub _fields { shift->{fields}; }

sub _values { shift->{values}; }

sub _column {
  my ($self, $pos) = @_;
  confess "index out of range" unless exists $self->{values}[$pos];
  return $self->{values}[$pos];
}

sub _pos {
  my ($self, $field) = @_;
  confess "unknown field '$field'" unless exists $self->{map}{$field};
  return $self->{map}{$field};
}

sub _get {
  my ($self, @fields) = @_;
  my @values;
  push @values, $self->{values}[ $self->_pos( $_ ) ] foreach @fields;
  return @values;
}

sub _set {
  my ($self, $field, $value) = @_;
  return $self->{values}[ $self->_pos( $field ) ] = $value;
}

sub AUTOLOAD {
  use vars qw($AUTOLOAD);
  my $self = shift;
  my ($method) = (split(/::/, $AUTOLOAD))[-1];
  confess "unknown field '$method'" unless exists $self->{map}{$method};
  if (scalar(@_)) {
    $self->_set( $method, shift );
  }
  return $self->{values}[ $self->_pos( $method ) ];
}

sub DESTROY { }

1;
