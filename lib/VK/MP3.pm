package VK::MP3;

use strict;
use warnings;
use utf8;

use LWP;
use LWP::Protocol::https;
use HTML::Entities;
use URI::Escape;

our $VERSION = 0.01;

sub new {
  my ($class, %args) = @_;
  die 'USAGE: VK::MP3->new(login => ..., password => ...)'
    unless _valid_new_args(\%args);

  my $self = { 
      ua => _create_ua(),
      login => $args{login},
      password => $args{password},
    };
  bless $self, $class;

  die 'ERROR: login failed' unless($self->_login());

  return $self;
}

sub search {
  my ($self, $query) = @_;

  my $res = $self->{ua}->get('http://vk.com/search?c[section]=audio&c[q]='.uri_escape_utf8($query));
  die 'LWP: '.$res->status_line unless $res->is_success;

  my @matches = $res->decoded_content =~  m'<input type="hidden" id="audio_info(.*?)</span></div>'sgi;

  my @rslt;
  push @rslt, $self->_parse_found_item($_) for(@matches);
  @rslt = grep { defined $_ } @rslt;

  return \@rslt;
}

sub _parse_found_item {
  my ($self, $str) = @_;
  my ($name) = $str =~ m{<div class="audio_title_wrap"><b>(.+)</a>}si;
  return undef unless $name;
 
  $name =~ s/<[^>]+>//g;
  $name =~ s/ ?\([^\(]*$//;
  $name = decode_entities($name);

  my ($duration) = $str =~ m{<div class="duration fl_r" onmousedown="if \(window\.audioPlayer\) audioPlayer\.switchTimeFormat\('[^']+', event\);">(\d+:\d+)</div>}i;
  my ($link) = $str =~ m{value="(http://[^",]+\.mp3)}i;

  if($duration) {
    my ($min, $sec) = split /:/, $duration, 2;
    $duration = $min * 60 + $sec;
  } else {
    $duration = 0;
  }
  
  return { name => $name, duration => $duration, link => $link };
}

sub _login {
  my $self = shift;
  my $res = $self->{ua}->post('https://login.vk.com/?act=login', {
      email => $self->{login},
      pass => $self->{password},
    });  
  return 0 unless $res->is_success;
  return $res->decoded_content =~ m#<a[^>]+href="https://login\.vk\.com/\?act=logout&hash=#i;
}

sub _create_ua {
  my $ua = LWP::UserAgent->new();

  push @{ $ua->requests_redirectable }, 'POST';
  $ua->ssl_opts(verify_hostname => 0);
  $ua->cookie_jar( {} );

  return $ua;
}

sub _valid_new_args {
  my $args = shift;
  return 0 unless ref($args) eq 'HASH';
  for(qw/login password/) {
    return 0 unless defined($args->{$_}) && (ref($args->{$_}) eq '');
  }
  return 1;
}

1;

__END__

=head1 NAME

VK::MP3 - search for mp3 on vk.com

=head1 SYNOPSIS

    use VK::MP3;
     
    my $vk = VK::MP3->new(login => 'user', password => 'secret');
    my $rslt = $vk->search('Nightwish');

    for (@{$rslt}) {
        # $_->{name}, $_->{duration}, $_->{link}
    }

=head1 DESCRIPTION

Really simple module, wich uses regular expressions and LWP.

=head1 METHODS

=head2 C<new>

    my $vk = VK::MP3->new(login => $login, password => $password)

Constructs a new C<VK::MP3> object and login to vk.com. Throws exception in case of any error.

=head2 C<search>

    my $rslt = $vk->search($query)

Results, found by $query.

=head1 SEE ALSO

L<VKontakte::API>, L<LWP::UserAgent>.

=head1 AUTHOR

Alexandr A Alexeev, <afiskon@gmail.com>

=head1 COPYRIGHT

Copyright 2011-2012 by Alexandr A Alexeev

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
