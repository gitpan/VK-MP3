use 5.008008;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME              => 'VK::MP3',
    VERSION_FROM      => 'lib/VK/MP3.pm',
    PREREQ_PM         => {
      'LWP'                  => 6.04,
      'LWP::Protocol::https' => 6.03,
      'HTML::Entities'       => 3.69,
      'URI::Escape'          => 3.31,
      'Test::Mock::LWP'      => 0.06,
    },
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/VK/MP3.pm', # retrieve abstract from module
       AUTHOR         => 'Alexandr A Alexeev <afiskon@gmail.com>') : ()),
);
