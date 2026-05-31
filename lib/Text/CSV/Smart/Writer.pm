package Text::CSV::Smart::Writer;

use strict;
use warnings;

use parent 'Text::CSV::Smart::Base';

use IO::File;
use Carp;

use Text::CSV::Smart::Row;

our $VERSION = '1.01';

my %TYPES = map { $_ => 1 } qw/ writer appender /;

sub new {
  my ($class, $type, $filename, $args) = @_;
  
  if (! defined $type || ! exists $TYPES{$type}) {
    confess sprintf "unknown Writer type '%s'", $type || '';
  }
  
  confess "missing filename"
    unless defined $filename;

  my $self = bless {
    type        => $type,
    filename    => $filename,
    parser      => undef,
    user_fields => undef,
    options     => {},
    header      => 1,
    width       => 1,
    fh          => undef,
  }, $class;

  if (defined $args) {
    foreach my $arg (qw/ header width options /) {
      next unless defined $args->{$arg};
      $self->{$arg} = $args->{$arg};
    }
    if (exists $args->{fields}) {
      $self->{user_fields} = $args->{fields};
    }
  }
  else {
    confess "missing parameters";
  }
  
  if (! defined $self->fields) {
    confess "cannot handle CSV without fields";
  }

  return $self->init;
}

sub init {
  my $self = shift;
  my $mode = $self->type eq 'writer' ? 'w' : 'a';
  my $filename = $self->filename;
  my $fh = IO::File->new( $filename, $mode) or confess "open($filename): $!";
  $self->{fh} = $fh;
  if ($self->header && $self->type eq 'writer') {
    my $row = Text::CSV::Smart::Row->new( $self->fields, $self->fields );
    $self->write($row);
  }
  return $self;
}

sub type { shift->{type} }

sub fh { shift->{fh} }

# FIXME promote to base class?
sub fields { shift->{user_fields} }

sub row {
  my $self = shift;
  return Text::CSV::Smart::Row->new( $self->fields );
}

sub close {
  my $self = shift;
  if (defined $self->fh) {
    $self->fh->close;
    $self->{fh} = undef;
  }
  return 1;
}

sub DESTROY {
  my $self = shift;
  $self->close;
}

1;
