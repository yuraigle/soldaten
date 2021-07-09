package Target1;

my $target0, $target1;
my $t0_set_at = 0;
my $t0_steps = 0;

sub have_target {
  return $target0 ? 1 : 0;
}

sub have_pk_target {
  return $target0 && $target0 =~ m/^\./sxm;
}

sub set_target1 {
  my ($s) = @_;

  if ($s) {
    $t0_set_at = time;
    $t0_steps = 0;
  }

  $target1 = $s;
  $target0 = $s =~ m/^[�-�]/sxm ? '.' . $target1 : $target1;
}

sub say_target1 {
  if (have_pk_target()) {
    U::sendline("�� ��� ����: $target1 (�����), ��������� $App::ATT1");
  } elsif ($target1) {
    U::sendline("�� ��� ����: $target1, ��������� $App::ATT1");
  } else {
    U::sendline("�� ��� ����! ������� �����, ��������� $App::ATT1");
  }
}

P::alias {
  my ($s) = @_;
  $s = U::trim($s);
  set_target1($s);
  say_target1();
} '�1';

P::alias {
  set_target1('');
  say_target1();
} '�0';

P::alias {
  say_target1();
} '����';

P::trig {
  if ($target0) {
    U::sendline("$App::ATT1 $target0");
  }
} '^:.+@', 'nf1000';

P::trig {
  if ($target1 eq $1) {
    U::sendline("$App::ATT1 $target0");
  }
} '^([�-�][�-�]+) ���.+ �.+\.$', 'nf100';

P::trig {
  if ($target1 eq $1) {
    U::sendline("$App::ATT1 $target0");
  }
} '^([�-�][�-�]+) ������.?�. �� �����������\.$', 'nf100';

P::trig {
  if ($target1 eq $1) {
    U::sendline("$App::ATT1 $target0");
  }
} '^([�-�][�-�]+) ������.? �� ������\.$', 'nf100';

P::trig {
  if ($target1 eq $1) {
    U::sendline("$App::ATT1 $target0");
  }
} '^([�-�][�-�]+) �������� ������.?�. ������-��\.$', 'nf100';

# ���������� ��������-�������-������ ���� � ���
my $last_mo = 0;
my $last_pn = 0;
my $last_og = 0;
my $last_sb = 0;
sub continue_fight {
  if ($App::ATT1 eq '����' && !$App::MO && !$App::OZ && time - $last_mo > 0) {
    U::sendline('����');
    $last_mo = time;
  } elsif ($App::ATT1 eq '����' && !$App::PN && !$App::OZ && time - $last_pn > 0 ) {
    U::sendline("���� $target0") if $target0;
    U::sendline('����');
    $last_pn = time;
  } elsif ($App::ATT1 eq '����' && !$App::OG && !$App::OZ && time - $last_og > 0) {
    U::sendline("���� $target0") if $target0;
    U::sendline('����');
    $last_og = time;
  } elsif ($App::ATT1 eq '����' && time - $last_sb > 0) {
    U::sendline("���� $target0") if $target0;
    U::sendline('����');
    $last_sb = time;
  }
}

P::trig {
  $t0_steps++ if $target0;

  # ����� ��� 50 �����, ������ >5���, � ���� �� ��
  # ������ ����� ������ ����� ������� �0
  if (
    $target0 && $target0 !~ m/^\./sxm
    && $t0_steps > 50 
    && time - $t0_set_at > 300
  ) {
    set_target1('');
    say_target1();
  }
} '^�� ��������� ������ �� ', 'nf1000';

1;
