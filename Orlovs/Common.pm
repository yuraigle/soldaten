package Common;

my $nam = U::cyr_upper($App::CONF->{CONNECT}->{name});
my $prof = $App::CONF->{CHARACTER}->{prof};
my $bag = $App::CONF->{CHARACTER}->{bag};

P::bindkey { U::sendline(q/~/) } q/`/;
P::bindkey { U::sendline(q/~/) } q/�/;
P::alias { unable_to_move() } q/�/;
P::alias { unable_to_move() } q/�/;
P::alias { unable_to_move() } q/�/;
P::alias { unable_to_move() } q/�/;

sub unable_to_move {
  P::echo("\3L[WARN] \3H� ����� ����� �� ����")
}

# ����� �� �����
for my $key (keys %{$App::CONF->{BINDKEY}}) {
  my $act = $App::CONF->{BINDKEY}{$key};

  if ($act eq '_�������_') {
    P::bindkey { Connection::try_connect() } $key;
  } elsif ($act eq '_������_') {
    P::bindkey { set_mode_two_handed() } $key;
  } elsif ($act eq '_������_') {
    P::bindkey { set_mode_shield() } $key;
  } elsif ($act eq '_��������_') {
    P::bindkey { mount1() } $key;
  } else {
    P::bindkey { U::sendline($act) } $key;
  }
}

# ������ �� �����
for my $key (keys %{$App::CONF->{ALIAS}}) {
  my $act = $App::CONF->{ALIAS}{$key};

  if ($act eq '_�������_') {
    P::alias { Connection::try_connect() } $key;
  } elsif ($act eq '_������_') {
    P::alias { set_mode_two_handed() } $key;
  } elsif ($act eq '_������_') {
    P::alias { set_mode_shield() } $key;
  } elsif ($act eq '_��������_') {
    P::alias { mount1() } $key;
  } else {
    P::alias {
      my $s = U::trim("@_");
      (my $t = $act) =~ s/%1/$s/g;
      U::sendline($t);
    } $key;
  }
}

# ������� �������� �� �����
for my $key (keys %{$App::CONF->{TRIGGERS}}) {
  my $act = $App::CONF->{TRIGGERS}{$key};
  P::trig { U::sendline($act) } $key, 'nf2000';
}

# ��������� ������� �� ������
sub act_bot {
  my $s = U::trim("@_");

  my $p, $args;
  if ($s =~ m/^([^\s]+)\s+(.*)$/sxm) {
    ($p, $args) = ($1, $2);
  } else {
    ($p, $args) = ($s, '');
  }

  if ($p eq '�1') {
    Target1::set_target1($args);
    Target1::say_target1();
  } elsif ($p eq '�0') {
    Target1::set_target1('');
    Target1::say_target1();
  } elsif ($p eq '����') {
    Target1::say_target1();
  } elsif ($p eq '����' || $p eq '������') {
    Common::set_mode_two_handed();
  } elsif ($p eq '������' || $p eq '���') {
    Common::set_mode_shield();
  } elsif ($p eq '���') {
    Common::set_mode_shield();
    Target1::set_target1($args);
    Target1::say_target1();
  } elsif ($p eq '���') {
    Common::mount1();
  } elsif ($p =~ m/^(�|��|���|����|�)$/sxm && $prof =~ m/����|����|����/sxm) {
    return; # �� �� �������
  } elsif ($p =~ m/^(���|����)$/sxm && $prof !~ m/����|����|����/sxm) {
    return; # �� �� ������
  } else {
    U::sendline($s);
  }
}

sub set_mode_two_handed {
  if ($prof eq '������') {
    U::sendline("�� $nam.������ $bag");
    U::sendline("�� $nam.���;�� $nam.�����;�� $nam.����;���� $nam.������ ���");
    mount1();
    $App::MODE = '������';
    $App::ATT1 = '����';
  } elsif ($prof eq '�������') {
    U::sendline("�� $nam.��� $bag");
    U::sendline("�� $nam.���;�� $nam.�����;�� $nam.����;���� $nam.��� ���");
    $App::MODE = '������';
    $App::ATT1 = '����';
    mount1();
  } elsif ($prof =~ m/��������|������/sxm) {
    U::sendline("�� $nam.������ $bag");
    U::sendline("�� $nam.���;�� $nam.�����;�� $nam.����;���� $nam.������ ���");
    $App::MODE = '������';
    $App::ATT1 = '����';
  }
}

sub set_mode_shield {
  if ($prof =~ m/������|������/sxm) {
    U::sendline("�� $nam.����� $bag;�� $nam.��� $bag;�� $nam.���� $bag");
    U::sendline("�� $nam.������;�� $nam.���;���� $nam.�����;���� $nam.��� ���;���� $nam.����");
    U::sendline('����;����');
    $App::MODE = '���';
    $App::ATT1 = '����';
  } elsif ($prof eq '�������') {
    U::sendline("�� $nam.���;�� $nam.���;���� $nam.�����;���� $nam.��� ���;���� $nam.����");
    U::sendline("�� $nam.����� $bag;�� $nam.��� $bag;�� $nam.���� $bag");
    U::sendline('����;����');
    $App::MODE = '���';
    $App::ATT1 = '����';
  }
}

sub mount1 {
  U::sendline('����;����');
  U::sendline("���� $nam.������;���� ���.���� $bag;���� ���.����");
  U::sendline('������� ������;�������� �����');
  U::sendline("���� ���.����;���� ���.���� $bag;���� $nam.������;��������");
}

P::trig {
  if ($prof eq '��������') {
    $App::MODE = '������';
    $App::ATT1 = '����';
    U::sendline('�� ������ ������');
  }
} '^�� ����� .+ � ��� ����\.$', 'nf1000';

P::trig {
  if ($prof eq '��������') {
    $App::MODE = '������';
    $App::ATT1 = '����';
  }
} '^�� ���������� ������������ .*(������|������|�����).*\.$', 'nf1000';

P::trig {
  if ($prof eq '��������') {
    $App::MODE = '������';
    $App::ATT1 = '����';
  }
} '^���� ���������� ������ ��� ������� ����\.$', 'nf1000';


P::trig {
  U::sendline("�� [$1] ���������");
} '^\[([\d\s\-!]+)\] ��������� ', 'nf1000';

P::trig {
  U::sendline('�� � �������! :(');
} '^���������� : ��������� +\(.+ ���.+\)\s*$', 'nf1000';

P::trig {
  return if U::get_color( $;, 1 ) ne 'H';
  U::sendline('�� � �� ���� ���� �������');
} '^�� �������� �� �������.', 'nf1000';

P::trig {
  return if U::get_color( $;, 1 ) ne 'H';
  U::sendline('�� � ���� ���� �������');
} '^�� ������ ���� ��������.', 'nf1000';

P::trig {
  U::sendline('�� � ���� ���� �������');
} '^ \|\| �� ������ ���� ��������.', 'nf1000';

P::trig {
  U::sendline("�� ��������� $1");
} '^ \|\| �� ����������� (.+) �� ���������.', 'nf1000';

P::trig {
  if ($prof eq '��������') {
    U::sendline('����');
  }
} '^����� ���', 'nf1000';

P::trig {
  U::sendline("�� $1 - ����� $2");
} '^([�-�][�-�]+) : ����� (.+)\.$', 'nf1000';

1;
