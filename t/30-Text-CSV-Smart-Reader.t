# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Text-CSV-Smart.t'

#########################

use strict;
use warnings;

#use Test::More qw(no_plan);
use Test::More tests => 22;
use Test::Exception;

BEGIN { use_ok('Text::CSV::Smart::Reader') };

#########################

my @FIELDS = qw/ one two three /;
my @REDUCED = qw/ a b c /;

# 2
throws_ok { Text::CSV::Smart::Reader->new } qr/missing filename/, 'Reader->new (no params)';

# 3
throws_ok { Text::CSV::Smart::Reader->new('t/csv/notexistent.csv') } qr/file .* not found/, 'Reader->new (file not found)';

# 4
throws_ok { Text::CSV::Smart::Reader->new('t/csv/sample.csv', { header => 0 }) } qr/cannot handle CSV without header or fields/, 'Reader->new (without header)';

# 5
throws_ok { Text::CSV::Smart::Reader->new('t/csv/sample.csv', { header => 0, fields => [] }) } qr/cannot handle CSV without header or fields/, 'Reader->new (empty fields)';

# 6
isa_ok(my $r1 = Text::CSV::Smart::Reader->new('t/csv/sample.csv', { header => 0, fields => [qw/a b c/] }), 'Text::CSV::Smart::Reader', 'Reader->new (no header but fields)');

# 7
is_deeply($r1->fields, \@REDUCED, 'Reader->fields');

# 8
is_deeply($r1->user_fields, \@REDUCED, 'Reader->user_fields');

# 9
is($r1->file_fields, undef, 'Reader->file_fields');

# 10
isa_ok(my $r2 = Text::CSV::Smart::Reader->new('t/csv/sample.csv', { header => 1, fields => [qw/a b c/] }), 'Text::CSV::Smart::Reader', 'Reader->new (header and fields)');

# 11
is_deeply($r2->fields, \@REDUCED, 'Reader->fields');

# 12
is_deeply($r2->user_fields, \@REDUCED, 'Reader->user_fields');

# 13
is_deeply($r2->file_fields, \@FIELDS, 'Reader->file_fields');

# 14
isa_ok(my $r3 = Text::CSV::Smart::Reader->new('t/csv/sample.csv', { skip => 2 }), 'Text::CSV::Smart::Reader', 'Reader->new (with skip)');

# 15
is_deeply($r3->fields, [4,5,6], 'check skip');

# 16
isa_ok(my $r4 = Text::CSV::Smart::Reader->new('t/csv/sample.csv'), 'Text::CSV::Smart::Reader', 'Reader->new');

# 17
is_deeply({ $r4->parser_defaults }, { sep_char => qq{\t}, eol => qq{\n}, binary => 1 }, 'Reader->parser_defaults');

# 18
is_deeply($r4->parser_options, { sep_char => qq{\t}, eol => qq{\n}, binary => 1 }, 'Reader->parser_options (defaults)');

# 19
isa_ok(my $i = $r4->iterator, 'Text::CSV::Smart::Reader::Iterator', 'Reader->Iterator');

# 20
isa_ok(my $r5 = Text::CSV::Smart::Reader->new('t/csv/comma.csv', { options => { sep_char => qq{,} } }), 'Text::CSV::Smart::Reader', 'Reader->new (with options)');

# 21
is_deeply($r5->parser_options, { sep_char => qq{,}, eol => qq{\n}, binary => 1 }, 'Reader->parser_options (changed sep_char)');

# 22
my $i5 = $r5->iterator;
my $row5 = $i5->next;
is_deeply($row5->_values, [1,2,3], 'check parser');

__END__

skip(100) = EOF

