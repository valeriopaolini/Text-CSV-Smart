# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Text-CSV-Smart.t'

#########################

use strict;
use warnings;

use Test::More tests => 40;
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
isa_ok(my $r3 = Text::CSV::Smart::Reader->new('t/csv/skip.csv', { skip => 2 }), 'Text::CSV::Smart::Reader', 'Reader->new (with skip)');

# 15
is_deeply($r3->fields, [qw/ four five six /], 'check skip');

# 16
isa_ok(my $r4 = Text::CSV::Smart::Reader->new('t/csv/sample.csv'), 'Text::CSV::Smart::Reader', 'Reader->new');

# 17
is_deeply({ $r4->parser_defaults }, { sep_char => qq{,}, eol => qq{\n}, binary => 1, encoding_in => 'utf8' }, 'Reader->parser_defaults');

# 18
is_deeply($r4->parser_options, { sep_char => qq{,}, eol => qq{\n}, binary => 1, encoding_in => 'utf8' }, 'Reader->parser_options (defaults)');

# 19
isa_ok(my $i = $r4->iterator, 'Text::CSV::Smart::Reader::Iterator', 'Reader->Iterator');

# 20
isa_ok(my $r5 = Text::CSV::Smart::Reader->new('t/csv/comma.csv', { options => { sep_char => qq{,} } }), 'Text::CSV::Smart::Reader', 'Reader->new (with options)');

# 21
is_deeply($r5->parser_options, { sep_char => qq{,}, eol => qq{\n}, binary => 1, encoding_in => 'utf8' }, 'Reader->parser_options (changed sep_char)');

# 22
my $i5 = $r5->iterator;
my $row5 = $i5->next;
is_deeply($row5->_values, [1,2,3], 'check parser');

my $tsv = Text::CSV::Smart::Reader->new('t/csv/tsv.tsv', { options => { sep_char => qq{\t} } });
is_deeply($tsv->fields, \@FIELDS, 'Reader reads TSV with explicit sep_char');
is_deeply($tsv->iterator->next->_values, [1,2,3], 'Reader parses TSV data with explicit sep_char');

is($r5->normalize_field_name(q(Nome campo: 1/2)), 'Nome_campo_1_2', 'Reader->normalize_field_name spaces and punctuation');

is($r5->normalize_field_name(q(a^b]c)), 'a_b_c', 'Reader->normalize_field_name non-word punctuation');

is_deeply(
  scalar Text::CSV::Smart::Reader->normalize_field_names(q( First name ), q(Age (years))),
  [qw/ First_name Age_years /],
  'Reader->normalize_field_names as class method',
);

throws_ok { Text::CSV::Smart::Reader->normalize_field_name(q(1st)) } qr/field name '1st' cannot start with a number/, 'Reader rejects field name starting with number';

throws_ok { Text::CSV::Smart::Reader->normalize_field_name(q(123)) } qr/field name '123' cannot start with a number/, 'Reader rejects numeric field name';

throws_ok { Text::CSV::Smart::Reader->normalize_field_name(q(456method)) } qr/field name '456method' cannot start with a number/, 'Reader rejects method name starting with number';

is(Text::CSV::Smart::Reader->normalize_field_name(q(method789)), 'method789', 'Reader accepts trailing digits in field name');

throws_ok { Text::CSV::Smart::Reader->normalize_field_name(q(!!!)) } qr/empty field name/, 'Reader rejects empty normalized field name';

throws_ok { Text::CSV::Smart::Reader->normalize_field_names(q(first name), q(first-name)) } qr/duplicate field name 'first_name'/, 'Reader rejects duplicate normalized fields';

my $r6 = Text::CSV::Smart::Reader->new('t/csv/spaces.csv');
my $row6 = $r6->iterator->next;
is_deeply($row6->_values, [1,2,3], 'Reader trims values by default');

my $r7 = Text::CSV::Smart::Reader->new('t/csv/spaces.csv', { normalize => 0 });
my $row7 = $r7->iterator->next;
is_deeply($row7->_values, [' 1 ', ' 2 ', ' 3 '], 'Reader preserves values with normalize => 0');

is($r7->normalize, 0, 'Reader->normalize false');

is($r6->normalize, 1, 'Reader->normalize default true');

throws_ok { Text::CSV::Smart::Reader->new('t/csv/mismatch.csv')->iterator->next } qr/wrong number of values: got 2 expected 3/, 'Reader detects row width mismatch';

throws_ok { Text::CSV::Smart::Reader->new('t/csv/number-field.csv')->fields } qr/field name '1st' cannot start with a number/, 'Reader rejects numeric field from file header';

throws_ok { Text::CSV::Smart::Reader->new('t/csv/duplicate-fields.csv')->fields } qr/duplicate field name 'first_name'/, 'Reader rejects duplicate normalized file headers';

__END__

skip(100) = EOF
