package Text::CSV::Smart::Reader::Iterator;

use strict;
use warnings;

use Carp;
use IO::File;
use Text::CSV::Smart::Row;

sub new {
  my ($class, $reader) = @_;
  if (! defined $reader || ! $reader->isa('Text::CSV::Smart::Reader')) {
    confess "missing Text::CSV::Smart::Reader object\n";
  }
  my $self = bless {
    reader => $reader,
    fields => undef,
    line   => undef,
  }, $class;
  $self->init;
  return $self;
}

sub init {
  my $self = shift;
  my $r = $self->reader;
  my $filename = $r->filename;
  my $fh = IO::File->new($filename, 'r') or confess "open($filename): $!";
  $self->{fh} = $fh;
  
  if (my $skip = $r->skip) {
    <$fh> for 1 .. $skip;
  }
  
  if ($r->header) {
    my $fields = $self->reader->read($fh);
  }
  $self->{line} = 0;

  return $self;
}

sub reader { shift->{reader}; }

sub fh { shift->{fh}; }

sub line { shift->{line} }

sub fields { shift->reader->fields }

sub rewind {
  my $self = shift;
  return $self->init;
}

sub skip {
  my ($self, $total) = @_;
  $total ||= 1;
  my $count = 0;
  for (1 .. $total) {
    $count++;
    $self->next;
  }
  return $count;
}

sub next {
  my ($self, $total) = @_;
  $total ||= 1;
  my $fh = $self->fh;
  my @rows;
  for (1 .. $total) {
    my $row = $self->reader->read($fh);
    last unless defined $row;
    if ($self->reader->normalize) {
      foreach (@$row) {
        $_ =~ s/^\s+//;
        $_ =~ s/\s+$//;
      }
    }
    $self->{line}++;
    push @rows, Text::CSV::Smart::Row->new( $self->fields, $row );
  }
  
  return unless @rows;
  
  if (scalar @rows > 1) {
    return wantarray
         ? @rows
         : \@rows;
  }
  return $rows[0];
}

sub DESTROY {
  my ($self) = @_;
  $self->fh && $self->fh->close;
}

1;
