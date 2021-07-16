package Autopom;

use List::MoreUtils qw/any uniq/;

my @all_ime, @all_rod, @all_dat, @all_vin, @all_tvo;

my @attack_weight = (
  '��������', '������', '������', '����� ������', '����������� ������',
  '������', '����� ������', '���������� ������', '����������� ������',
  '������', '�������', '�����������', '����������', '���������',
);

my @attack_types = (
  '������',  '������',   '������',     '�������',
  '�����',   '��������', '����������', '������',
  '�������', '�������',  '��������',   '�����',
  '������',  '������',   '������',     '������',
  '��������',
);

@attack_types = map { $_ . '[���]?' } @attack_types;

our $RX_BATTLE1 = '^(.*?)\s' .
  '(' . join( q/|/, @attack_weight ) . ')?\s?' .
  '(' . join( q/|/, @attack_types ) . ')\s' .
  '(.*)\.(\s\(\*+\))?$';

my $rx_ime2_tvo = '^(.+) ��������� � (.+)! ';

my @rx_ime_rod = (
  '^(.+) �������.?�. �� ����� (.+)$',
  '^(.+) �����.? �������� ����� (.+)\.$',
  '^(.+) �������.? ������� (.+) �������� ...?\.$',
  '^(.+) ��������� �������� ����� (.+)',
  '^(.+) �� �����.? ����� ������� � ����� (.+)\.$',
  '^(.+) �����.?.? ���� ����� ������� � ����� (.+)\.( \(\*+\))?$',
  '^(.+) �������.? ���� ������ � ����� (.+)\. �� �������� ��������\.( \(\*+\))?$',
  '^(.+) �������� ����������� �����, ����� ��������� ������� (.+)\.( \(\*+\))?$',
  '^(.+) ������ � ��������� �� ���������� ������� (.+)\.( \(\*+\))?$',
  '^(.+) ��������.? �������� (.+)\.( \(\*+\))?$',
  '^(.+) ����������� �� ������������ ����� (.+)\.( \(\*+\))?$',
  '^(.+) ���������� �� ������������ ����� (.+)\.( \(\*+\))?$',
);

my @rx_ime_ime = (
  '^(.+) ��������.? � ���������� ������, ����� (.+) ������.? �� ��..? �����\.',
);

my @rx_ime_dat = (
  '^(.+) �������.?�. ������� (.+) ���� � �����, �� ...? ��������\.$',
);

my @rx_ime_vin = (
  '^(.+) ��������.?, ����� �����.? ������� (.*)\.$',
  '^(.+) �������.?�. [�-�]+ (.*), �� .*\.$',
  '^(.+) �������.?�. �������� (.*) \- ��������\.$',
  '^(.+) �� ����.?.? �������� (.*) \- ��.? ������ ��������.?\.$',
  '^����� ������ (.+) �������.? (.*) �� �����\.( \(\*+\))?$',
  '^(.+) �������.? (.+) �� ����� ������ ������\.( \(\*+\))?$',
  '^(.+) �������.?�. ����� (.+)\. ������� �� ...? ��������\.$',
  '^(.*?) .+����.? (.+)\. ����� .+ ����������� � ������� ����\.( \(\*+\))?$',
  '^(.*?) .+����.? (.+)\. ������ .+ ���� �����.� ������� �� ����\.( \(\*+\))?$',
  '^(.+) ����� ������.?.? (.+), ������ ...? �� �����\.$',
);

my @rx_rod_rod = (
  '^���� (.+) ������ ���� (.+)\.$',
  '^������� (.+) ��������� ��������� ���� (.+)\.$',
  '^������ ����� (.+) �� ������ (.+)$',
  '^���������� ����� ������ (.+) ��������� �������� ���� (.+)\.$',
);

my @rx_rod_vin = (
  '^������ ��������� (.*) ������ (.*) �� �����\.$',
  '^�� �������� ������� (.*) ��������� (.*)\.$',
);

P::trig {
  return if Target1::have_target(); # ������� ���� ���� �1

  my ($ime, $tvo) = ($1, $2);
  if ($ime =~ m/^\*/sxm) {
    $ime =~ s/^\*//sxm;
  } elsif ($ime =~ m/\(/sxm) {
    my $ime = U::name_from_titles($ime);
  }
  $tvo =~ s/,\s����\s������\s��\s.+$//sxm;

  if (any { $_->{IME} eq $ime } @App::FRIENDS) {
    push @all_tvo, $tvo if !U::same($tvo, '����');
  } elsif (any { $_->{TVO} eq $tvo } @App::FRIENDS) {
    push @all_ime, $ime if !U::same($ime, '��');
  }
} $rx_ime2_tvo, 'nf1000:AUTOPOM';

P::trig {
  my ($t1, $t2) = ($1, $4);
  if (any { $_->{IME} eq $t1 } @App::FRIENDS) {
    push @all_vin, $t2 if !U::same($t2, '���');
  } elsif (any { $_->{VIN} eq $t2 } @App::FRIENDS) {
    push @all_ime, $t1 if !U::same($t1, '��');
  }
} $RX_BATTLE1, 'nf1000:AUTOPOM';

foreach (@rx_ime_rod) {
  P::trig {
    my ($t1, $t2) = ($1, $2);
    if (any { $_->{IME} eq $t1 } @App::FRIENDS) {
      push @all_rod, $t2 if !U::same($t2, '���');
    } elsif (any { $_->{ROD} eq $t2 } @App::FRIENDS) {
      push @all_ime, $t1 if !U::same($t1, '��');
    }
  } $_, 'nf1000:AUTOPOM';
}

foreach (@rx_ime_ime) {
  P::trig {
    my ($t1, $t2) = ($1, $2);
    if (any { $_->{IME} eq $t1 } @App::FRIENDS) {
      push @all_ime, $t2 if !U::same($t2, '��');
    } elsif (any { $_->{IME} eq $t2 } @App::FRIENDS) {
      push @all_ime, $t1 if !U::same($t1, '��');
    }
  } $_, 'nf1000:AUTOPOM';
}

foreach (@rx_ime_dat) {
  P::trig {
    my ($t1, $t2) = ($1, $2);
    if (any { $_->{IME} eq $t1 } @App::FRIENDS) {
      push @all_dat, $t2 if !U::same($t2, '���');
    } elsif (any { $_->{DAT} eq $t2 } @App::FRIENDS) {
      push @all_ime, $t1 if !U::same($t1, '��');
    }
  } $_, 'nf1000:AUTOPOM';
}

foreach (@rx_ime_vin) {
  P::trig {
    my ($t1, $t2) = ($1, $2);
    if (any { $_->{IME} eq $t1 } @App::FRIENDS) {
      push @all_vin, $t2 if !U::same($t2, '���');
    } elsif (any { $_->{VIN} eq $t2 } @App::FRIENDS) {
      push @all_ime, $t1 if !U::same($t1, '��');
    }
  } $_, 'nf1000:AUTOPOM';
}

foreach (@rx_rod_rod) {
  P::trig {
    my ($t1, $t2) = ($1, $2);
    if (any { $_->{ROD} eq $t1 } @App::FRIENDS) {
      push @all_rod, $t2 if !U::same($t2, '���');
    } elsif (any { $_->{ROD} eq $t2 } @App::FRIENDS) {
      push @all_rod, $t1 if !U::same($t1, '���');
    }
  } $_, 'nf1000:AUTOPOM';
}

foreach (@rx_rod_vin) {
  P::trig {
    my ($t1, $t2) = ($1, $2);
    if (any { $_->{ROD} eq $t1 } @App::FRIENDS) {
      push @all_vin, $t2 if !U::same($t2, '���');
    } elsif (any { $_->{VIN} eq $t2 } @App::FRIENDS) {
      push @all_rod, $t1 if !U::same($t1, '���');
    }
  } $_, 'nf1000:AUTOPOM';
}

my $last_otst = 0;

P::trig {
  $last_otst = time;
} '^�� ��������� �� �����.', 'nf1000:AUTOPOM';

my $prof = $App::CONF->{CHARACTER}->{prof};

sub on_prompt {
  my ( $prompt, $prompt_uc ) = @_;

  return if $prompt_uc !~ m/\d+H\s+\d+M/sxm;

  if ($prompt_uc =~ m/\]/sxm) {
    Target1::continue_fight();
    return;
  }

  my $trg = '';
  if (!$trg && @all_ime) { $trg = U::make_alias($all_ime[0], 'ime') }
  if (!$trg && @all_vin) { $trg = U::make_alias($all_vin[0], 'vin') }
  if (!$trg && @all_tvo) { $trg = U::make_alias($all_tvo[0], 'tvo') }
  if (!$trg && @all_rod) { $trg = U::make_alias($all_rod[0], 'rod') }
  if (!$trg && @all_dat) { $trg = U::make_alias($all_dat[0], 'dat') }
  @all_ime = @all_rod = @all_dat = @all_vin = @all_tvo = ();

  return unless $trg;
  return if time - $last_otst < 5;

  if ($App::ATT1 eq '����' && !$App::PN && !$App::OZ) {
    U::sendline("���� $trg");
  } elsif ($App::ATT1 eq '����') {
    U::sendline("���� $trg");
  } else {
    U::sendline("$App::ATT1 $trg");
  }
}

1;
