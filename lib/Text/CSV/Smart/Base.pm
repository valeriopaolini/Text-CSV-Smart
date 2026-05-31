package Text::CSV::Smart::Base;

use strict;
use warnings;

use Carp;
use Scalar::Util qw(blessed);
use Text::CSV::Encoded;

our $VERSION = '1.01';

sub version { $VERSION; }

sub filename { shift->{filename} }

sub width { shift->{width} }  

sub header { shift->{header} }

sub parser_defaults {
  my $self = shift;
  return (
    binary   => 1,
    encoding_in => 'utf8',
    sep_char => qq{,}, 
    eol      => qq{\n},
  );
}

sub parser_options {
  my $self = shift; 
  my %defaults = $self->parser_defaults;
  my $options = $self->{options} || {}; 
  while (my ($field, $value) = each %$options) {
    $defaults{$field} = $value;
  }
  return \%defaults;
}
                         
sub parser {
  my $self = shift;
  if (! defined $self->{parser}) {
    $self->{parser} = Text::CSV::Encoded->new( $self->parser_options );   
  }
  return $self->{parser};
}

sub read {
  my $self = shift;
  my $row = $self->parser->getline( shift );
  if (! defined $row && ! $self->parser->eof) {
    confess "parser error: ". $self->parser->error_diag();
  }
  return $row;
}

sub write {
  my $self = shift;
  if (! defined $self->fh) {
    confess "cannot write on closed filehandle";
  }
  my $count = 0;
  while (my $row = shift) {
    $count++;
    my $values = [];
    if (ref $row eq 'ARRAY') {
      $values = $row;
    }
    else {
      if ( ! blessed($row) || ! $row->isa('Text::CSV::Smart::Row')) {
        confess sprintf "unknown row type '%s'", ref $row;
      }
      foreach my $field ( @{ $self->fields }) {
        push @$values, $row->$field;
      }
    }
    $self->parser->print( $self->fh, $values )
      or confess "parser error: ". $self->parser->error_diag();
  }
  return $count;
}

1;
