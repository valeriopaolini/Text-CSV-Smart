# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Text-CSV-Smart.t'

#########################

use strict;
use warnings;

use Test::More qw(no_plan); #tests => 7;
use Test::Exception;

BEGIN {
  unlink('t/csv/new.csv');
  unlink('t/csv/append.csv');

  use_ok('Text::CSV::Smart');
};

END {
  unlink('t/csv/new.csv');
  unlink('t/csv/append.csv');
};

#########################

my @FIELDS = qw/ a b c /;

# 2
isa_ok(Text::CSV::Smart->new('t/csv/sample.csv'), 'Text::CSV::Smart::Reader', 'new Reader, new');

# 3
isa_ok(Text::CSV::Smart->reader('t/csv/sample.csv'), 'Text::CSV::Smart::Reader', 'new Reader, reader');

# 4
isa_ok(Text::CSV::Smart->writer('t/csv/new.csv', { fields => \@FIELDS }), 'Text::CSV::Smart::Writer', 'new Writer, writer');

# 5
isa_ok(Text::CSV::Smart->appender('t/csv/append.csv', { fields => \@FIELDS }), 'Text::CSV::Smart::Writer', 'new Writer, appender');

# missing tests on Reader, in particular options
