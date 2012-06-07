#!/usr/bin/perl

# vk-get-mp3.pl script v 0.10.2
# (c) Alexandr A Alexeev 2011-2012 | http://eax.me/
# Special thanks to Bekenev Ruslan ( http://bitbucket.org/KryDos ) 

use strict;
use warnings;
use utf8;

use Text::Unidecode;
use MP3::Info;
use VK::MP3;

use constant VERSION => '0.10.2';
use constant DEFAULT_LOGIN => 'billy@microsoft.com';
use constant DEFAULT_PASSWORD => 'qwerty';
use constant DEFAULT_SAVE_DIR => './';
use constant DEFAULT_MAX_SHOW => 20;

my ($login, $password, $save_dir, $max_show);
for my $x (qw/login password save_dir max_show/) {
    my $X = "\U$x";
    my $cmd = qq{
      \$$x = \$ENV{VKMP3_$X};
      \$$x = DEFAULT_$X unless(defined(\$$x));
    };
    eval $cmd;
}

my $hidden_pass = "*" x length($password);

my $query = join " ", @ARGV;
die "vk-get-mp3.pl ver ".VERSION."\nUsage:\n$0 <query>\n$0 --dialog\n"
    unless($query);

if($query eq "--dialog") {
  print "Dialog mode, enter query or 'exit'\nvkmp3> ";
  while($query = <STDIN>) {
    chomp($query);
    if(length($query)) {
      last if((lc $query eq 'exit')or(lc $query eq 'quit'));
      $query = quotemeta $query;
      system("$0 $query") unless($query eq "--dialog"); # FIXME!
      print "\n";
    }
    print "vkmp3> ";
  }
  exit;
}

print "Looking for '$query'...\n";
utf8::decode($query);

my $vk = VK::MP3->new(login => $login, password => $password);
my $rslt = $vk->search($query);

die "Nothing found\n" unless scalar @{$rslt};

my $i;
for my $t (@{$rslt}) {
  my $name = $t->{name};
  $name = substr($name,0,64)."..." if(length($name) > 64);

  my $duration = $t->{duration};
  $duration = $duration
    ? sprintf("%02d:%02d", int($duration / 60), $duration % 60)
    : "??:??";

  utf8::encode($name);
  print sprintf("%02d", ++$i)." [$duration] $name\n";
  last if($i >= $max_show);
}

print "Your choice(s) [none]: ";
chomp(my $choice = <STDIN>);
my @ch = split /\D/, $choice;

for $choice (@ch) {
  print "$choice - ignored" and next
    unless($choice >= 1 and $choice <= scalar(@{$rslt}));

  my $url = $rslt->[$choice-1]{link};
  $url =~ s/'/\\'/g;

  my $fname = unidecode($rslt->[$choice-1]{name}).'-'.time().'.mp3';
  $fname =~ s/[^a-z0-9\-\_\.\ ]//gsi;
  $fname =~ s/[\s\-]+/-/g;
  $fname = $save_dir.$fname;

  print "Downloading $url to $fname...\n";
  system("lwp-download '$url' '$fname'");
  die "Download: wget returns $?\n" if $?;

  my $bitrate = abs(get_mp3info($fname)->{BITRATE});
  print "Bitrate = ".sprintf("%d",$bitrate)." kbps\n";
  print "$fname\n";
}

