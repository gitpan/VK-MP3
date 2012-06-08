use 5.008008;
use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'VK::MP3',
    AUTHOR        => 'Alexandr Alexeev <eax@cpan.org>',
    LICENSE       => 'perl_5',
    VERSION_FROM  => 'lib/VK/MP3.pm',
    ABSTRACT_FROM => 'lib/VK/MP3.pm',
    EXE_FILES     => [qw!bin/vkmp3!],
    PREREQ_PM     => {
      'LWP'                  => 6.04,
      'LWP::Protocol::https' => 6.03,
      'HTML::Entities'       => 3.69,
      'URI::Escape'          => 3.31,
      'Test::Mock::LWP'      => 0.06,
    },
    META_MERGE   => {
      requires  => { perl => '5.008008' },
      resources => {
        homepage    => 'http://eax.me/vk-get-mp3/',
        license     => 'http://dev.perl.org/licenses/',
        repository  => 'https://bitbucket.org/afiskon/pl-vkmp3',
        bugtracker  => 'https://bitbucket.org/afiskon/pl-vkmp3/issues'
      },
    }
  );
