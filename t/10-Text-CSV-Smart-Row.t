# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Text-CSV-Smart.t'

#########################

use strict;
use warnings;

use Test::More tests => 30;
#use Test::More qw(no_plan);
use Test::Exception;

BEGIN { use_ok('Text::CSV::Smart::Row') };

#########################

my @FIELDS = qw/ a b c d e f g /;
my @VALUES = 1 .. 7;
my @INDEX = 0 .. 6;

my %ROW;
@ROW{ @FIELDS } = @VALUES;

my %MAP;
@MAP{ @FIELDS } = @INDEX;

throws_ok { Text::CSV::Smart::Row->new } qr/wrong argument/, 'no parameters';

throws_ok { Text::CSV::Smart::Row->new('scalar') } qr/wrong argument/, 'scalar parameter';

throws_ok { Text::CSV::Smart::Row->new({}) } qr/fields argument is not an ARRAY ref/, 'empty HASH ref';

throws_ok { Text::CSV::Smart::Row->new({ unknown => undef }) } qr/unknown field/, 'empty HASH ref';

throws_ok { Text::CSV::Smart::Row->new({ fields => undef }) } qr/fields argument is not an ARRAY ref/, 'empty fields in HASH ref';

throws_ok { Text::CSV::Smart::Row->new({ fields => [] }) } qr/empty list of fields/, 'empty fields in HASH ref';

throws_ok { Text::CSV::Smart::Row->new([]) } qr/empty list of fields/, 'empty ARRAY ref';

throws_ok { Text::CSV::Smart::Row->new(\@FIELDS, []) } qr/wrong number of values/, 'empty ARRAY ref';

isa_ok(Text::CSV::Smart::Row->new(\@FIELDS), 'Text::CSV::Smart::Row', 'Row->new(ARRAY)');

isa_ok(my $r1 = Text::CSV::Smart::Row->new({ fields => \@FIELDS }), 'Text::CSV::Smart::Row', 'Row->new(HASH)');

is($r1->_values, undef, 'Row->_values (empty)');

isa_ok(my $r2 = Text::CSV::Smart::Row->new(\@FIELDS, \@VALUES), 'Text::CSV::Smart::Row', 'Row->new(ARRAY, ARRAY)');

is_deeply($r2->_fields, \@FIELDS, 'Row->_fields');

is_deeply($r2->_values, \@VALUES, 'Row->_values');

is($r2->a, 1, 'Row->$field');

is($r2->_pos('c'), 2, 'Row->_pos');

my ($v) = $r2->_get('c');
is($v, 3, 'Row->_get');

my @v = $r2->_get(qw/d e f/);
is_deeply( \@v, [4,5,6], 'Row->_get (multiple fields)');

is_deeply($r2->_data, \%ROW, 'Row->_data');

is_deeply($r2->_map, \%MAP, 'Row->_map');

is($r2->_column(6), 7, 'Row->_column');

is($r2->_set('a', 11), 11, 'Row->_set');

is($r2->a(22), 22, 'Row->$field($value)');

is($r2->a, 22, 'Row->$field (after set)');

isa_ok(my $c = $r2->_clone, 'Text::CSV::Smart::Row', 'Row->_clone');

is_deeply($c->_fields, \@FIELDS, 'Row->_fields (on clone)');

is_deeply($c->_values, \@VALUES, 'Row->_values (on clone)');

throws_ok { Text::CSV::Smart::Row->new({ fields => \@FIELDS, values => [1..3] }) } qr/wrong number of values/, 'Row->new(HASH) (wrong number of values)';

isa_ok(my $r3 = Text::CSV::Smart::Row->new({ fields => \@FIELDS, width => 0, values => [1..3] }), 'Text::CSV::Smart::Row', 'Row->new(HASH) (with width => 0)'); 

