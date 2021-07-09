package Autopom;

use List::MoreUtils qw/any uniq/;

my @all_ime, @all_rod, @all_dat, @all_vin, @all_tvo;

my @attack_weight = (
  'легонько', 'слегка', 'сильно', 'очень сильно', 'чрезвычайно сильно',
  'БОЛЬНО', 'ОЧЕНЬ БОЛЬНО', 'НЕВЫНОСИМО БОЛЬНО', 'ЧРЕЗВЫЧАЙНО БОЛЬНО',
  'УЖАСНО', 'ЖЕСТОКО', 'УБИЙСТВЕННО', 'СМЕРТЕЛЬНО', 'ИЗУВЕРСКИ',
);

my @attack_types = (
  'боднул',  'клюнул',   'лягнул',     'ободрал',
  'огрел',   'оцарапал', 'подстрелил', 'пырнул',
  'резанул', 'рубанул',  'сокрушил',   'ткнул',
  'ударил',  'ужалил',   'уколол',     'укусил',
  'хлестнул',
);

@attack_types = map { $_ . '[аои]?' } @attack_types;

my $rx_battle1 = '^(.*?)\s' .
  '(' . join( q/|/, @attack_weight ) . ')?\s?' .
  '(' . join( q/|/, @attack_types ) . ')\s' .
  '(.*)\.(\s\(\*+\))?$';

my $rx_ime2_tvo = '^(.+) сражается с (.+)! ';

my @rx_ime_rod = (
  '^(.+) уклонил.?с. от атаки (.+)$',
  '^(.+) сумел.? избежать удара (.+)\.$',
  '^(.+) избежал.? попытки (.+) завалить ...?\.$',
  '^(.+) полностью отклонил атаку (.+)',
  '^(.+) не попал.? своим оружием в спину (.+)\.$',
  '^(.+) нанес.?.? удар своим оружием в спину (.+)\.( \(\*+\))?$',
  '^(.+) воткнул.? свое оружие в спину (.+)\. Ща начнется убивство\.( \(\*+\))?$',
  '^(.+) медленно покрывается льдом, после морозного дыхания (.+)\.( \(\*+\))?$',
  '^(.+) бьется в судорогах от кислотного дыхания (.+)\.( \(\*+\))?$',
  '^(.+) ослеплен.? дыханием (.+)\.( \(\*+\))?$',
  '^(.+) содрогнулся от богатырского удара (.+)\.( \(\*+\))?$',
  '^(.+) пошатнулся от богатырского удара (.+)\.( \(\*+\))?$',
);

my @rx_ime_ime = (
  '^(.+) подгорел.? в нескольких местах, когда (.+) дыхнул.? на не..? огнем\.',
);

my @rx_ime_dat = (
  '^(.+) попытал.?с. нанести (.+) удар в спину, но ...? заметили\.$',
);

my @rx_ime_vin = (
  '^(.+) промазал.?, когда хотел.? ударить (.*)\.$',
  '^(.+) попытал.?с. [а-я]+ (.*), но .*\.$',
  '^(.+) попытал.?с. ободрать (.*) \- неудачно\.$',
  '^(.+) не смог.?.? ободрать (.*) \- он.? просто промазал.?\.$',
  '^Одним ударом (.+) повалил.? (.*) на землю\.( \(\*+\))?$',
  '^(.+) завалил.? (.+) на землю мощным ударом\.( \(\*+\))?$',
  '^(.+) попытал.?с. пнуть (.+)\. Займите же ...? ловкости\.$',
  '^(.*?) .+пнул.? (.+)\. Морда .+ искривилась в гримасе боли\.( \(\*+\))?$',
  '^(.*?) .+пнул.? (.+)\. Теперь .+ дико враща.т глазами от боли\.( \(\*+\))?$',
  '^(.+) ловко подсек.?.? (.+), уронив ...? на землю\.$',
);

my @rx_rod_rod = (
  '^Удар (.+) прошел мимо (.+)\.$',
  '^Доспехи (.+) полностью поглотили удар (.+)\.$',
  '^Мощный пинок (.+) не достиг (.+)$',
  '^Магический кокон вокруг (.+) полностью поглотил удар (.+)\.$',
);

my @rx_rod_vin = (
  '^Точное попадение (.*) вывело (.*) из строя\.$',
  '^Вы избежали попытки (.*) хлестнуть (.*)\.$',
);

P::trig {
  return if Target1::have_target(); # игнорим если есть ц1

  my ($ime, $tvo) = ($1, $2);
  if ($ime =~ m/^\*/sxm) {
    $ime =~ s/^\*//sxm;
  } elsif ($ime =~ m/\(/sxm) {
    my $ime = U::name_from_titles($ime);
  }
  $tvo =~ s/,\sсидя\sверхом\sна\s.+$//sxm;

  if (any { $_->{IME} eq $ime } @App::FRIENDS) {
    push @all_tvo, $tvo if !U::same($tvo, 'вами');
  } elsif (any { $_->{TVO} eq $tvo } @App::FRIENDS) {
    push @all_ime, $ime if !U::same($ime, 'вы');
  }
} $rx_ime2_tvo, 'nf1000:AUTOPOM';

P::trig {
  my ($t1, $t2) = ($1, $4);
  if (any { $_->{IME} eq $t1 } @App::FRIENDS) {
    push @all_vin, $t2 if !U::same($t2, 'вас');
  } elsif (any { $_->{VIN} eq $t2 } @App::FRIENDS) {
    push @all_ime, $t1 if !U::same($t1, 'вы');
  }
} $rx_battle1, 'nf1000:AUTOPOM';

foreach (@rx_ime_rod) {
  P::trig {
    my ($t1, $t2) = ($1, $2);
    if (any { $_->{IME} eq $t1 } @App::FRIENDS) {
      push @all_rod, $t2 if !U::same($t2, 'вас');
    } elsif (any { $_->{ROD} eq $t2 } @App::FRIENDS) {
      push @all_ime, $t1 if !U::same($t1, 'вы');
    }
  } $_, 'nf1000:AUTOPOM';
}

foreach (@rx_ime_ime) {
  P::trig {
    my ($t1, $t2) = ($1, $2);
    if (any { $_->{IME} eq $t1 } @App::FRIENDS) {
      push @all_ime, $t2 if !U::same($t2, 'вы');
    } elsif (any { $_->{IME} eq $t2 } @App::FRIENDS) {
      push @all_ime, $t1 if !U::same($t1, 'вы');
    }
  } $_, 'nf1000:AUTOPOM';
}

foreach (@rx_ime_dat) {
  P::trig {
    my ($t1, $t2) = ($1, $2);
    if (any { $_->{IME} eq $t1 } @App::FRIENDS) {
      push @all_dat, $t2 if !U::same($t2, 'вам');
    } elsif (any { $_->{DAT} eq $t2 } @App::FRIENDS) {
      push @all_ime, $t1 if !U::same($t1, 'вы');
    }
  } $_, 'nf1000:AUTOPOM';
}

foreach (@rx_ime_vin) {
  P::trig {
    my ($t1, $t2) = ($1, $2);
    if (any { $_->{IME} eq $t1 } @App::FRIENDS) {
      push @all_vin, $t2 if !U::same($t2, 'вас');
    } elsif (any { $_->{VIN} eq $t2 } @App::FRIENDS) {
      push @all_ime, $t1 if !U::same($t1, 'вы');
    }
  } $_, 'nf1000:AUTOPOM';
}

foreach (@rx_rod_rod) {
  P::trig {
    my ($t1, $t2) = ($1, $2);
    if (any { $_->{ROD} eq $t1 } @App::FRIENDS) {
      push @all_rod, $t2 if !U::same($t2, 'вас');
    } elsif (any { $_->{ROD} eq $t2 } @App::FRIENDS) {
      push @all_rod, $t1 if !U::same($t1, 'вас');
    }
  } $_, 'nf1000:AUTOPOM';
}

foreach (@rx_rod_vin) {
  P::trig {
    my ($t1, $t2) = ($1, $2);
    if (any { $_->{ROD} eq $t1 } @App::FRIENDS) {
      push @all_vin, $t2 if !U::same($t2, 'вас');
    } elsif (any { $_->{VIN} eq $t2 } @App::FRIENDS) {
      push @all_rod, $t1 if !U::same($t1, 'вас');
    }
  } $_, 'nf1000:AUTOPOM';
}

my $last_otst = 0;

P::trig {
  $last_otst = time;
} '^Вы отступили из битвы.', 'nf1000:AUTOPOM';

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

  if ($App::ATT1 eq 'пнут' && !$App::PN && !$App::OZ) {
    U::sendline("пнут $trg");
  } elsif ($App::ATT1 eq 'пнут') {
    U::sendline("убит $trg");
  } else {
    U::sendline("$App::ATT1 $trg");
  }
}

1;
