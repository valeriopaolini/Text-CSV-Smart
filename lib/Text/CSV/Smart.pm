package Text::CSV::Smart;

use strict;
use warnings;

our $VERSION = '1.00';

use Text::CSV::Smart::Reader;
use Text::CSV::Smart::Writer;

sub new {
  my $class = shift;
  my $type = scalar @_ > 1 ? shift : 'reader';
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
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Text::CSV::Smart, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Valerio Paolini, E<lt>valdez@cpan.org<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Valerio Paolini

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.12.3 or,
at your option, any later version of Perl 5 you may have available.


=cut
