package Reactions;

use List::MoreUtils qw/any/;

P::trig { U::sendline('1') } '^�� ������! ��� ����� ����', 'nf1000';

my @botovod = split /\s*,\s*/sxm, $App::CONF->{GROUP}->{botovod};
my @recall_corpse = split /\s*,\s*/sxm, $App::CONF->{GROUP}->{recall_corpse};

P::trig {
  my ( $nam, $act ) = ( $1, $2 );
  $act =~ s/^\s*//sxm;
  Common::act_bot($act) if ( any { $_ eq $nam } @botovod );
} '^(.*) ��������? ������ : \'!(.*)\'', 'nf1000';

P::trig {
  my ( $nam, $me, $act ) = ( $1, $2, $3 );
  $act =~ s/^\s*//sxm;
  return if ( $me ne $App::CONF->{CONNECT}->{name} );
  Common::act_bot($act) if ( any { $_ eq $nam } @botovod );
} '^([�-��-�]+) ��������? ������ : \'([�-��-�]+) (.*?)\'', 'nf1000';

P::trig {
  my $nam = $1;
  return if Target1::have_pk_target();
  if (any { $_ eq $nam } @recall_corpse) {
    U::sendline("~;��� ���;����� ����.����");
  }
} '^([�-��-�]+) ������?, �..? ���� �������� ', 'nf100';

my $last_eat = 0;

my @im_hungry = (
  '^�� �������.',
  '^��� ������ �����.',
  '^�� ����� �������.',
  '^�� ������ ������� ����.',
  '^��� ������ ������ �����.',
  '^��� ������� ������ �����.',
);

foreach (@im_hungry) {
  P::trig {
    if (time - $last_eat > 5) {
      U::sendline($App::CONF->{ALIAS}->{'���'});
      $last_eat = time;
    }
  } $_, 'nf1000';
}

my @im_down = (
  '^���... �� ������� �����������...',
  '^�������, ��� ����� ������ �� ����.',
  '^��� ����� ������ �� ����!',
  '^�� ���������� ������� .*, �� ����� ����...$',
  '^������, � ���� ���� �� ����� �� ����������.$',
  '^��� �������� �� �����.',
  '^�� �������� �� ����� �� ������� ����� ',
  ' �������.? ��� �� �����. ������������!$',
  ' ����� ������.?.? ���, ������ �� ����\.$',
);

foreach (@im_down) {
  P::trig { U::sendline('����') } $_, 'nf1000';
}

# ����������� ����� ������
my $nam = U::cyr_upper($App::CONF->{CONNECT}->{name});
P::trig {
  if ($App::MODE eq '������') {
    U::sendline("���� $nam.������ ���");
  } elsif ($App::MODE eq '���') {
    U::sendline("���� $nam.��� ���");
    U::sendline("���� $nam.����");
  }
} '^�� (��������|�������) ', 'nf1000';

# ������ ������ ������
P::trig {
  U::sendline("�� ���.$nam");
  if ($App::MODE eq '������') {
    U::sendline("���� $nam.������ ���");
  } elsif ($App::MODE eq '���') {
    U::sendline("���� $nam.�����");
    U::sendline("���� $nam.��� ���");
    U::sendline("���� $nam.����");
  }
} ' �����.? �� ����� ���\.$', 'nf1000';

1;
