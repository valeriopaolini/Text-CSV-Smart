package Text::CSV::Smart::Reader;

use strict;
use warnings;

use parent 'Text::CSV::Smart::Base';

use Text::CSV::Smart::Reader::Iterator;
use Data::Dumper; # FIXME
use Carp;

our $VERSION = '1.0';

sub new {
  my ($class, $filename, $args) = @_;

  confess "missing filename"
    unless defined $filename;

  confess sprintf "file '%s' not found", $filename
    unless -f $filename;
  
  my $self = bless {
    filename    => $filename,
    parser      => undef,
    user_fields => undef,
    file_fields => undef,
    skip        => 0,
    header      => 1,
    width       => 1,
    normalize   => 1,
    options     => {},
  }, $class;

  if (defined $args) {
    foreach my $arg (qw/ skip header width normalize options /) {
      next unless defined $args->{$arg};
      $self->{$arg} = $args->{$arg};
    }
    if (exists $args->{fields}) {
      $self->{user_fields} = $args->{fields};
    }
  }

  if (! $self->header && (! defined $self->user_fields || ! scalar @{ $self->user_fields })) {
    confess "cannot handle CSV without header or fields";
  }

  return $self;
}

sub skip { shift->{skip} }

sub user_fields { shift->{user_fields} }

sub normalize { shift->{normalize} }

sub normalize_field_name {
  my ($self, $name) = @_;
  $name =~ tr/[^Sa-zA-Z0-9]/\_/c;
  $name =~ s/\_+/\_/g;
  $name =~ s/^\_//;
  $name =~ s/\_$//;
  return $name;
}

sub file_fields {
  my $self = shift;
  return unless $self->header;

  return $self->{file_fields} if defined $self->{file_fields};
  
  my $filename = $self->filename;
  my $fh = IO::File->new($filename, 'r') or confess "open($filename): $!";
  if (my $skip = $self->skip) {
    <$fh> for (1 .. $skip);
  }
  my $fields = $self->read($fh);
  $fh->close;
  return $self->{file_fields} = [ map { $self->normalize_field_name($_) } @$fields ];
}

sub fields {
  my $self = shift;
  return $self->user_fields || $self->file_fields;  
}

sub iterator {
  my $self = shift;
  return Text::CSV::Smart::Reader::Iterator->new( $self );
}

sub DESTROY { }

1;
