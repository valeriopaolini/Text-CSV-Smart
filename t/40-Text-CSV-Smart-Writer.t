# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Text-CSV-Smart.t'

#########################

use strict;
use warnings;

use Test::More tests => 29;
use Test::Exception;

BEGIN {
  unlink('t/csv/append.csv');
  unlink('t/csv/new.csv');
  unlink('t/csv/parser-error.csv');
  unlink('t/csv/writer.csv');

  use_ok('Text::CSV::Smart::Writer')
};

END {
  unlink('t/csv/append.csv');
  unlink('t/csv/new.csv');
  unlink('t/csv/parser-error.csv');
  unlink('t/csv/writer.csv');
};

#########################

my @FIELDS = qw/ first second third /;

throws_ok { Text::CSV::Smart::Writer->new } qr/unknown Writer type/, 'Writer->new (no type)';

throws_ok { Text::CSV::Smart::Writer->new('unknown') } qr/unknown Writer type/, 'Writer->new (wrong type)';

throws_ok { Text::CSV::Smart::Writer->new('writer') } qr/missing filename/, 'Writer->new (no filename)';

throws_ok { Text::CSV::Smart::Writer->new('writer', 't/csv/writer.csv') } qr/missing parameters/, 'Writer->new (no parameters)';

throws_ok { Text::CSV::Smart::Writer->new('writer', 't/csv/writer.csv', { }) } qr/cannot handle CSV without fields/, 'Writer->new (no fields)';

throws_ok { Text::CSV::Smart::Writer->new('writer', 't/csv/writer.csv', { fields => undef }) } qr/cannot handle CSV without fields/, 'Writer->new (empty fields)';

isa_ok(my $w1 = Text::CSV::Smart::Writer->new('writer', 't/csv/writer.csv', { fields => \@FIELDS, header => 0 }), 'Text::CSV::Smart::Writer', 'Writer->new (no header)');

is($w1->header, 0, 'Writer->header (without)');

ok($w1->close, 'Writer->close');

throws_ok { $w1->write('something') } qr/cannot write on closed filehandle/, 'Writer->write (after close)';

isa_ok(my $w2 = Text::CSV::Smart::Writer->new('writer', 't/csv/writer.csv', { fields => \@FIELDS }), 'Text::CSV::Smart::Writer', 'Writer->new (header)');

is(!!$w2->header, 1, 'Writer->header (with)');

is_deeply($w2->fields, \@FIELDS, 'Writer->fields');

isa_ok($w2->fh, 'IO::File', 'Writer->fh');

isa_ok(my $r2 = $w2->row, 'Text::CSV::Smart::Row', 'Writer->Row');

is_deeply($r2->_fields, \@FIELDS, 'Row->_fields');

throws_ok { $w2->write( $w2 ) } qr/unknown row type/, 'Writer->write (not a Row)';

throws_ok { $w2->write({ first => 1 }) } qr/unknown row type/, 'Writer->write (unblessed ref)';

ok($w2->write($r2), 'Writer->write(Row)');

ok($w2->write([qw/ a b c /]), 'Writer->write(ARRAY)');

$r2->first(1);
$r2->second(2);
$r2->third(3);

ok($w2->write($r2), 'Writer->write(Row)');

ok($w2->close, 'Writer->close');

is(slurp('t/csv/writer.csv'), slurp('t/csv/writer-t1.csv'), 'check file');

isa_ok(my $w3 = Text::CSV::Smart::Writer->new('appender', 't/csv/writer.csv', { fields => \@FIELDS }), 'Text::CSV::Smart::Writer', 'Writer->new (appender)');

ok($w3->write([qw/ 7 8 9 /]), 'Writer->write(ARRAY)');

ok($w3->close, 'Writer->close');

is(slurp('t/csv/writer.csv'), slurp('t/csv/writer-t2.csv'), 'check file (appended)');

my $w4 = Text::CSV::Smart::Writer->new('writer', 't/csv/parser-error.csv', { fields => \@FIELDS, header => 0 });
$w4->{parser} = Text::CSV::Smart::Test::BrokenParser->new;
throws_ok { $w4->write([qw/ a b c /]) } qr/parser error: forced failure/, 'Writer->write reports parser errors';
$w4->close;

sub slurp {
  my ($filename) = @_;
  open my $fh, '<', $filename or die "open($filename): $!";
  local $/;
  return <$fh>;
}

package Text::CSV::Smart::Test::BrokenParser;

sub new { bless {}, shift }

sub print { 0 }

sub error_diag { 'forced failure' }
