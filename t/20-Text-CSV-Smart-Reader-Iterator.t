# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Text-CSV-Smart.t'

#########################

use strict;
use warnings;

use Test::More tests => 21;
use Test::Exception;

#########################

BEGIN { use_ok('Text::CSV::Smart::Reader::Iterator') };

use_ok('Text::CSV::Smart');

my $r = Text::CSV::Smart->reader('t/csv/sample.csv');

# 2
isa_ok(my $i = $r->iterator, 'Text::CSV::Smart::Reader::Iterator', 'Reader->Iterator');

# 3
isa_ok($i->reader, 'Text::CSV::Smart::Reader', 'Iterator->reader');

# 4
isa_ok($i->fh, 'IO::File', 'Iterator->fh');

# 5
is($i->line, 0, 'Iterator->line (zero)');

# 6
is($i->skip(3), 3, 'Iterator->skip(3)');

# 7
is($i->line, 3, 'Iterator->line (after skip)');

# 8
isa_ok($i->next, 'Text::CSV::Smart::Row', 'Iterator->next');

# 9
is($i->line, 4, 'Iterator->line (after next / 1)');

# 10
isa_ok($i->next(1), 'Text::CSV::Smart::Row', 'Iterator->next(1)');

# 11
is($i->line, 5, 'Iterator->line (after next / 2)');

# 12
my @r = $i->next(3);
is(scalar @r, 3, 'Iterator->next(3)');

# 13
isa_ok(my $rows = $i->next(2), 'ARRAY', 'Iterator->next (scalar)');

# 14
$i->rewind;
is($i->line, 0, 'Iterator->line (after rewind)');

# 15
throws_ok { Text::CSV::Smart::Reader::Iterator->new } qr/missing/, 'Iterator->new (w/o Reader)';

my $eof_reader = Text::CSV::Smart->reader('t/csv/sample.csv');
my $eof_iterator = $eof_reader->iterator;
my $eof_count = 0;
$eof_count++ while $eof_iterator->next;
is($eof_count, 10, 'Iterator->next reaches EOF cleanly');
is($eof_iterator->next, undef, 'Iterator->next returns undef at EOF');

my $bulk_reader = Text::CSV::Smart->reader('t/csv/sample.csv');
my $bulk_iterator = $bulk_reader->iterator;
my @bulk_rows = $bulk_iterator->next(100);
is(scalar @bulk_rows, 10, 'Iterator->next(100) returns available rows at EOF');
is($bulk_iterator->line, 10, 'Iterator->line after next(100)');
is($bulk_iterator->next(100), undef, 'Iterator->next(100) returns undef after EOF');

# die "missing test on initial skip";
