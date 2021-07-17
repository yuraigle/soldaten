package Autoresc;

use List::MoreUtils qw/any first_index/;

my $auto_resc = 0;
my @f2resc = ();

my @rx_ime = (
  '^(.+) �������.?�. �� ����� ',
  '^(.+) �����.? �������� ����� .+\.$',
  '^(.+) ��������� �������� ����� .+',
  '^(.+) ����������� �� ������������ ����� ',
  '^(.+) ���������� �� ������������ ����� ',
  # '^(.+) ��������.? � ���������� ������, ����� (.+) ������.? �� ��..? �����\.',
  # '^(.+) �������� ����������� �����, ����� ��������� ������� (.+)\.( \(\*+\))?$',
  # '^(.+) ������ � ��������� �� ���������� ������� (.+)\.( \(\*+\))?$',
  # '^(.+) ��������.? �������� (.+)\.( \(\*+\))?$',
);

my @rx_rod = (
  '^.+ �� �����.? ����� ������� � ����� (.+)\.$',
  '^.+ �����.?.? ���� ����� ������� � ����� (.+)\.( \(\*+\))?$',
  '^.+ �������.? ���� ������ � ����� (.+)\. �� �������� ��������\.( \(\*+\))?$',
  '^���� .+ ������ ���� (.+)\.$',
  '^������� (.+) ��������� ��������� ���� .+\.$',
  '^������ ����� .+ �� ������ (.+)$',
  '^���������� ����� ������ (.+) ��������� �������� ���� .+\.$',
);

my @rx_vin = (
  '^.+ ��������.?, ����� �����.? ������� (.*)\.$',
  '^.+ �������.?�. [�-�]+ (.*), �� .*\.$',
  '^.+ �������.?�. �������� (.*) \- ��������\.$',
  '^.+ �� ����.?.? �������� (.*) \- ��.? ������ ��������.?\.$',
  '^����� ������ .+ �������.? (.*) �� �����\.( \(\*+\))?$',
  '^.+ �������.? (.+) �� ����� ������ ������\.( \(\*+\))?$',
  '^.+ �������.?�. ����� (.+)\. ������� �� ...? ��������\.$',
  '^.+ ����.? (.+)\. ����� .+ ����������� � ������� ����\.( \(\*+\))?$',
  '^.+ ����.? (.+)\. ������ .+ ���� �����.� ������� �� ����\.( \(\*+\))?$',
);

P::trig {
  my ($t1, $t2) = ($1, $4);
  my $i = first_index {$_->{VIN} eq $t2} @f2resc;
  U::sendline('������ .' . $f2resc[$i]->{IME}) if $i >= 0;
} $Autopom::RX_BATTLE1, '-nf1000:AUTORESC';

foreach (@rx_ime) {
  P::trig {
    my $t1 = $1;
    my $i = first_index {$_->{IME} eq $t1} @f2resc;
    U::sendline('������ .' . $f2resc[$i]->{IME}) if $i >= 0;
  } $_, '-nf100:AUTORESC';
}

foreach (@rx_rod) {
  P::trig {
    my $t1 = $1;
    my $i = first_index {$_->{ROD} eq $t1} @f2resc;
    U::sendline('������ .' . $f2resc[$i]->{IME}) if $i >= 0;
  } $_, '-nf100:AUTORESC';
}

foreach (@rx_vin) {
  P::trig {
    my $t1 = $1;
    my $i = first_index {$_->{VIN} eq $t1} @f2resc;
    U::sendline('������ .' . $f2resc[$i]->{IME}) if $i >= 0;
  } $_, '-nf100:AUTORESC';
}

sub set_mode_resc_off {
  $auto_resc = 0;
  P::disable('AUTORESC');
  U::sendline('�� �� ������.');
}

sub set_mode_resc_on {
  $auto_resc = 1;
  P::enable('AUTORESC_UPD');
  U::sendline('����');
}

P::trig {
  @f2resc = ();
  P::disable('AUTORESC_UPD');
  P::disable('AUTORESC_UPD1');
} '^�� �� �� �� ���� ', '-nf1000:AUTORESC_UPD';

P::trig {
  @f2resc = ();
  P::disable('AUTORESC_UPD');
  P::enable('AUTORESC_UPD1');
} '^���� ������ ������� ��:', '-nf1000:AUTORESC_UPD';

P::trig {
  my $t1 = $1;
  my $i = first_index {$_->{IME} eq $t1} @App::FRIENDS;
  if ($i >= 0
      && $App::FRIENDS[$i]->{PROF} ne '���������'
      && $App::FRIENDS[$i]->{IME} ne $App::CONF->{CONNECT}->{name}
  ) {
    push @f2resc, $App::FRIENDS[$i];
  }
} '^([�-��-�]+)\s+\|[^|]+\|[^|]+\| (�� |���) \|', '-nf1000:AUTORESC_UPD1';

P::trig {
  P::disable('AUTORESC_UPD');
  P::disable('AUTORESC_UPD1');

  if ($#f2resc >= 0) {
    my $s = '';
    foreach my $m (@f2resc) {
      $s .= ($s ? ', ' : '') . $m->{VIN};
    }
    U::sendline("�� ������: $s");
    U::sendline('����;����');
    P::enable('AUTORESC');
  } else {
    U::sendline('�� ������ ��� �������');
  }
} '^$', '-nf1000:AUTORESC_UPD1';

P::alias {
  set_mode_resc_on();
} '������';

P::alias {
  set_mode_resc_off();
} '��������';

P::trig {
  U::sendline('����;����');
} '^�� ����������� �� ���� �� ��������, ', '-nf1000:AUTORESC';

1;
