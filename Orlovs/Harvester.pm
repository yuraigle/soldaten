package Harvester;

my $ingr_bag = $App::CONF->{CHARACTER}->{ingr_bag};

sub get_reagent {
  return unless $App::CONF->{CHARACTER}->{harvester};
  return if Target1::have_pk_target();
  U::sendline("�� ���.����;���� ���.���� $ingr_bag");
}

P::trig {
  return if U::get_color( $;, 1 ) ne 'L';
  get_reagent();
} '^� ����� ��� ����� (.+)\.$', 'nf5000:REAGENTS';

P::trig {
  return if U::get_color( $;, 1 ) ne 'L';
  get_reagent();
} '^������ (.+) ������� � ����� ���\.$', 'nf5000:REAGENTS';

P::trig {
  return if U::get_color( $;, 1 ) ne 'L';
  get_reagent();
} '^������� (.+) ��������� �����\.$', 'nf5000:REAGENTS';

P::trig {
  return if U::get_color( $;, 1 ) ne 'L';
  get_reagent();
} '^���� \((.*)\) ������ �����\.$', 'nf5000:REAGENTS';

P::trig {
  return if U::get_color( $;, 1 ) ne 'L';
  get_reagent();
} '^�������������, �� ������ ����� (.*)\.$', 'nf5000:REAGENTS';

P::trig {
  return if U::get_color( $;, 1 ) ne 'L';
  get_reagent();
} '^������� (.*) ���������� ������� � �����\.$', 'nf5000:REAGENTS';

P::trig {
  return if U::get_color( $;, 1 ) ne 'L';
  get_reagent();
} '^���������� ����� (.*) ������ �����\.$', 'nf5000:REAGENTS';

P::trig {
  return if U::get_color( $;, 1 ) ne 'L';
  get_reagent();
} '^��������� ������� (.*) �������� � ����\.$', 'nf5000:REAGENTS';

P::trig {
  return if U::get_color( $;, 1 ) ne 'L';
  get_reagent();
} '^�� �������� (.{6,20})\.$', 'nf5000:REAGENTS';

P::trig {
  return if U::get_color( $;, 1 ) ne 'L';
  get_reagent();
} '^����� ����������� �� �������� (.+)\.$', 'nf5000:REAGENTS';

P::trig {
  return if U::get_color( $;, 1 ) ne 'L';
  get_reagent();
} '^������� ��������� ��� ������� � �����\.$', 'nf5000:REAGENTS';

P::trig {
  U::sendline('���� ���.���');
} '^����� ����� .* ���.$', 'nf1000';

1;
