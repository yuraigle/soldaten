package Harvester;

my $ingr_bag = $App::CONF->{CHARACTER}->{ingr_bag};

sub get_reagent {
  return unless $App::CONF->{CHARACTER}->{harvester};
  return if Target1::have_pk_target();
  U::sendline("вз все.ингр;поло все.ингр $ingr_bag");
}

P::trig {
  return if U::get_color( $;, 1 ) ne 'L';
  get_reagent();
} '^У ваших ног лежит (.+)\.$', 'nf5000:REAGENTS';

P::trig {
  return if U::get_color( $;, 1 ) ne 'L';
  get_reagent();
} '^Лужица (.+) разлита у ваших ног\.$', 'nf5000:REAGENTS';

P::trig {
  return if U::get_color( $;, 1 ) ne 'L';
  get_reagent();
} '^Немного (.+) просыпано здесь\.$', 'nf5000:REAGENTS';

P::trig {
  return if U::get_color( $;, 1 ) ne 'L';
  get_reagent();
} '^Гриб \((.*)\) растет здесь\.$', 'nf5000:REAGENTS';

P::trig {
  return if U::get_color( $;, 1 ) ne 'L';
  get_reagent();
} '^Приглядевшись, вы видите ягоду (.*)\.$', 'nf5000:REAGENTS';

P::trig {
  return if U::get_color( $;, 1 ) ne 'L';
  get_reagent();
} '^Осколок (.*) наполовину утоплен в почву\.$', 'nf5000:REAGENTS';

P::trig {
  return if U::get_color( $;, 1 ) ne 'L';
  get_reagent();
} '^Отломанная ветка (.*) сохнет здесь\.$', 'nf5000:REAGENTS';

P::trig {
  return if U::get_color( $;, 1 ) ne 'L';
  get_reagent();
} '^Маленький кусочек (.*) валяется в пыли\.$', 'nf5000:REAGENTS';

P::trig {
  return if U::get_color( $;, 1 ) ne 'L';
  get_reagent();
} '^Вы заметили (.{6,20})\.$', 'nf5000:REAGENTS';

P::trig {
  return if U::get_color( $;, 1 ) ne 'L';
  get_reagent();
} '^Среди разнотравья вы заметили (.+)\.$', 'nf5000:REAGENTS';

P::trig {
  return if U::get_color( $;, 1 ) ne 'L';
  get_reagent();
} '^Золотой самородок еле заметен в грязи\.$', 'nf5000:REAGENTS';

P::trig {
  U::sendline('взят все.кун');
} '^Здесь лежит .* кун.$', 'nf1000';

1;
