package Text::CSV::Smart;

use strict;
use warnings;

our $VERSION = '1.01';

use Text::CSV::Smart::Reader;
use Text::CSV::Smart::Writer;

sub new {
  my $class = shift;
  my $type = @_ && ! ref $_[0] && $_[0] =~ /^(?:reader|writer|appender)$/ ? shift : 'reader';
  return $class->$type( @_ );
}

sub reader {
  my $class = shift;
  return Text::CSV::Smart::Reader->new( @_ );
}

sub writer {
  my $class = shift;
  return Text::CSV::Smart::Writer->new( 'writer', @_ );
}

sub appender {
  my $class = shift;
  return Text::CSV::Smart::Writer->new( 'appender', @_ );
}

1;

__END__
=head1 NAME

Text::CSV::Smart - Perl extension for smart manipulation of CSV files

=head1 SYNOPSIS

  use Text::CSV::Smart;

  my $reader = Text::CSV::Smart->reader('sample.csv');
  my $writer = Text::CSV::Smart->writer(
    'gender-M.csv',
    { fields => [qw/name age/] },
  );

  my $iterator = $reader->iterator;
  while (my $row = $iterator->next) {
    next unless $row->gender eq 'M';
    $writer->write($row);
  }

  $reader->close;
  $writer->close;

=head1 DESCRIPTION

Text::CSV::Smart is a small convenience layer around L<Text::CSV::Encoded>.
It is intended for simple CSV and TSV processing where the first record
contains field names and subsequent records can be handled as row objects.

By default the parser uses comma as separator, newline as end of record, binary
mode enabled, and UTF-8 input. Parser options can be overridden with the
C<options> argument passed to readers and writers.

This release is stricter than the original 1.00 release: the default separator
is comma, and invalid or ambiguous field names are rejected instead of being
silently accepted.

=head1 CONSTRUCTORS

=head2 new

  my $reader = Text::CSV::Smart->new($filename);
  my $reader = Text::CSV::Smart->new($filename, \%args);
  my $reader = Text::CSV::Smart->new(reader => $filename, \%args);
  my $writer = Text::CSV::Smart->new(writer => $filename, \%args);
  my $writer = Text::CSV::Smart->new(appender => $filename, \%args);

Creates a reader by default. When the first argument is C<reader>, C<writer>,
or C<appender>, it dispatches to that constructor instead.

=head2 reader

  my $reader = Text::CSV::Smart->reader($filename);
  my $reader = Text::CSV::Smart->reader($filename, \%args);

Creates a L<Text::CSV::Smart::Reader>. The default assumes that the input file
has a header row. Useful arguments are:

=over 4

=item C<header>

Boolean. When false, C<fields> must be supplied.

=item C<fields>

Array reference containing the field names to expose on row objects.

=item C<skip>

Number of physical lines to skip before reading the header or data.

=item C<normalize>

Boolean. When true, values returned by the iterator are trimmed. This affects
row values, not field names.

=item C<options>

Hash reference of options passed to L<Text::CSV::Encoded>. For comma-separated
files the default separator is C<,>. For tab-separated values, pass:

  options => {
    sep_char => "\t", # implements TSV
  }

=back

=head2 writer

  my $writer = Text::CSV::Smart->writer($filename, { fields => \@fields });

Creates a L<Text::CSV::Smart::Writer> and truncates the target file. By
default it writes a header row. Set C<header> to false to suppress it.

=head2 appender

  my $writer = Text::CSV::Smart->appender($filename, { fields => \@fields });

Creates a writer in append mode. In append mode the header row is not written.

=head1 ROWS

Rows are L<Text::CSV::Smart::Row> objects. Field names are available as
methods after normalization:

  print $row->name;
  $row->age(43);

The writer accepts either row objects or array references. When writing a row
object, only the writer's configured fields are emitted.

For explicit row access, use C<_get> and C<_set>:

  my ($name, $age) = $row->_get(qw/name age/);
  $row->_set(age => 43);

C<_get> accepts one or more field names and checks that each field exists.
C<_set> sets one field after checking that it exists. The AUTOLOAD interface is
only shorthand for method-safe field names.

When field names are read from a file header, they are normalized before being
used as row method names. Leading and trailing whitespace is removed, runs of
non-alphanumeric characters are replaced with C<_>, repeated underscores are
collapsed, and leading or trailing underscores are removed.

Field names that are empty after normalization are rejected. Field names
beginning with an underscore are reserved for internal methods such as C<_get>
and C<_set>. Field names beginning with a number are rejected because they
cannot be used with the bareword method syntax used by the AUTOLOAD shorthand
(for example, C<< $row->123 >> and C<< $row->456method >> are syntax errors).
Digits are allowed after the first character, so C<method789> is valid.
Duplicate field names after normalization are rejected.

You can check how header names will be converted without opening a file:

  my $fields = Text::CSV::Smart::Reader->normalize_field_names(
    'First name',
    'Age (years)',
  );

=head1 EXPORT

None.

=head1 SEE ALSO

L<Text::CSV::Encoded>, L<Text::CSV>, L<Text::CSV_XS>.

=head1 AUTHOR

Valerio Paolini, E<lt>valdez@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Valerio Paolini

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.12.3 or,
at your option, any later version of Perl 5 you may have available.


=cut
