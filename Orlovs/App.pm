package App;

use Win32::OLE;
use Config::Tiny;

our $CONF = Config::Tiny->read($Conf::INI)
  or Carp::croak(qq/Error reading $Conf::INI/);

require Orlovs::U;
require Orlovs::Connection;
require Orlovs::Layout;
require Orlovs::Reactions;
require Orlovs::Autopom;
require Orlovs::Target1;
require Orlovs::Common;
require Orlovs::Harvester;
require My;

our @FRIENDS = ();
our @PLAYERS = ();
our @CHARMIS = ();

our $FIGHT = '';
our $OZ = 0;
our $PN = 0;
our $LC = 0;
our $MO = 0;
our $OG = 0;
our $ATT1 = '';
our $MODE = '';

open my $in, '<', 'data.txt' or die $!;
my @lines = <$in>;
close $in;

for my $line (@lines) {
  chomp $line;

  if ($line =~ m/^\[(.+)\]/sxm) {
    $mod = $1;
  } elsif (!$line || $line =~ m/^;/sxm) {
  } elsif ($mod =~ m/������/sxm) {
    my $m = {};
    ($m->{IME}, $m->{ROD}, $m->{DAT}, $m->{VIN}, $m->{TVO}, $m->{PROF}) = split /:/sxm, $line;
    push @FRIENDS, $m;
  }
}

U::showme("��������� ��������� ��� ��������� \3L" . $CONF->{CONNECT}->{name});

P::hook {
  my $prompt    = shift;
  my $prompt_uc = CL::strip_colors( CL::parse_colors($prompt) );

  if ($prompt_uc =~ m/\d+H\s+\d+M/sxm) {
    if ( $prompt_uc =~ m/\s\[([^:]+):[^:]+\]\s>\s$/sxm ) {
      $FIGHT = $1;
    } else {
      $FIGHT = '';
    }

    if ( $prompt_uc =~ m/��:(\d+)/sxm ) { $LC = $1 } else { $LC = 9 }
    if ( $prompt_uc =~ m/��:(\d+)/sxm ) { $OZ = $1 } else { $OZ = 0 }
    if ( $prompt_uc =~ m/��:(\d+)/sxm ) { $PN = $1 } else { $PN = 0 }
    if ( $prompt_uc =~ m/��:(\d+)/sxm ) { $MO = $1 } else { $MO = 0 }
    if ( $prompt_uc =~ m/��:(\d+)/sxm ) { $OG = $1 } else { $OG = 0 }
  }

  Connection::on_prompt($prompt, $prompt_uc);
  Autopom::on_prompt($prompt, $prompt_uc);

  return $prompt;
} 'prompt';

my $prof = $CONF->{CHARACTER}->{prof};
if ($prof =~ m/������|�������/sxm) {
  $ATT1 = '����';
  $MODE = '������';
} elsif ($prof eq '��������') {
  $ATT1 = '����';
  $MODE = '������';
} elsif ($prof eq '������') {
  $ATT1 = '����';
  $MODE = '������';
}

1;
