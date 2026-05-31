use 5.012003;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Text::CSV::Smart',
    VERSION_FROM      => 'lib/Text/CSV/Smart.pm', # finds $VERSION
    PREREQ_PM         => {
                        'Text::CSV::Encoded' => 0.10,
                      },
    TEST_REQUIRES     => {
                        'Test::Exception'    => 0,
                      },
    META_ADD          => {
                        license => 'perl',
                      },
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Text/CSV/Smart.pm', # retrieve abstract from module
       AUTHOR         => 'Valerio Paolini <valerio.paolini@gmail.com>') : ()),
);
