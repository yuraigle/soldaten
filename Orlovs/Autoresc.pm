package Autoresc;

use List::MoreUtils qw/any first_index/;

my $auto_resc = 0;
my @f2resc = ();

my @rx_ime = (
  '^(.+) уклонил.?с. от атаки ',
  '^(.+) сумел.? избежать удара .+\.$',
  '^(.+) полностью отклонил атаку .+',
  '^(.+) содрогнулся от богатырского удара ',
  '^(.+) пошатнулся от богатырского удара ',
  # '^(.+) подгорел.? в нескольких местах, когда (.+) дыхнул.? на не..? огнем\.',
  # '^(.+) медленно покрывается льдом, после морозного дыхания (.+)\.( \(\*+\))?$',
  # '^(.+) бьется в судорогах от кислотного дыхания (.+)\.( \(\*+\))?$',
  # '^(.+) ослеплен.? дыханием (.+)\.( \(\*+\))?$',
);

my @rx_rod = (
  '^.+ не попал.? своим оружием в спину (.+)\.$',
  '^.+ нанес.?.? удар своим оружием в спину (.+)\.( \(\*+\))?$',
  '^.+ воткнул.? свое оружие в спину (.+)\. Ща начнется убивство\.( \(\*+\))?$',
  '^Удар .+ прошел мимо (.+)\.$',
  '^Доспехи (.+) полностью поглотили удар .+\.$',
  '^Мощный пинок .+ не достиг (.+)$',
  '^Магический кокон вокруг (.+) полностью поглотил удар .+\.$',
);

my @rx_vin = (
  '^.+ промазал.?, когда хотел.? ударить (.*)\.$',
  '^.+ попытал.?с. [а-я]+ (.*), но .*\.$',
  '^.+ попытал.?с. ободрать (.*) \- неудачно\.$',
  '^.+ не смог.?.? ободрать (.*) \- он.? просто промазал.?\.$',
  '^Одним ударом .+ повалил.? (.*) на землю\.( \(\*+\))?$',
  '^.+ завалил.? (.+) на землю мощным ударом\.( \(\*+\))?$',
  '^.+ попытал.?с. пнуть (.+)\. Займите же ...? ловкости\.$',
  '^.+ пнул.? (.+)\. Морда .+ искривилась в гримасе боли\.( \(\*+\))?$',
  '^.+ пнул.? (.+)\. Теперь .+ дико враща.т глазами от боли\.( \(\*+\))?$',
);

P::trig {
  my ($t1, $t2) = ($1, $4);
  return if Target1::have_pk_target();
  my $i = first_index {$_->{VIN} eq $t2} @f2resc;
  U::sendline('спасти .' . $f2resc[$i]->{IME}) if $i >= 0;
} $Autopom::RX_BATTLE1, '-nf1000:AUTORESC';

foreach (@rx_ime) {
  P::trig {
    my $t1 = $1;
    return if Target1::have_pk_target();
    my $i = first_index {$_->{IME} eq $t1} @f2resc;
    U::sendline('спасти .' . $f2resc[$i]->{IME}) if $i >= 0;
  } $_, '-nf100:AUTORESC';
}

foreach (@rx_rod) {
  P::trig {
    my $t1 = $1;
    return if Target1::have_pk_target();
    my $i = first_index {$_->{ROD} eq $t1} @f2resc;
    U::sendline('спасти .' . $f2resc[$i]->{IME}) if $i >= 0;
  } $_, '-nf100:AUTORESC';
}

foreach (@rx_vin) {
  P::trig {
    my $t1 = $1;
    return if Target1::have_pk_target();
    my $i = first_index {$_->{VIN} eq $t1} @f2resc;
    U::sendline('спасти .' . $f2resc[$i]->{IME}) if $i >= 0;
  } $_, '-nf100:AUTORESC';
}

sub set_mode_resc_off {
  $auto_resc = 0;
  P::disable('AUTORESC');
  U::sendline('гг не рескаю.');
}

sub set_mode_resc_on {
  $auto_resc = 1;
  P::enable('AUTORESC_UPD');
  U::sendline('груп');
}

P::trig {
  @f2resc = ();
  P::disable('AUTORESC_UPD');
  P::disable('AUTORESC_UPD1');
} '^Но вы же не член ', '-nf1000:AUTORESC_UPD';

P::trig {
  @f2resc = ();
  P::disable('AUTORESC_UPD');
  P::enable('AUTORESC_UPD1');
} '^Ваша группа состоит из:', '-nf1000:AUTORESC_UPD';

P::trig {
  my $t1 = $1;
  my $i = first_index {$_->{IME} eq $t1} @App::FRIENDS;
  if ($i >= 0
      && $App::FRIENDS[$i]->{PROF} ne 'дружинник'
      && $App::FRIENDS[$i]->{IME} ne $App::CONF->{CONNECT}->{name}
  ) {
    push @f2resc, $App::FRIENDS[$i];
  }
} '^([А-Яа-я]+)\s+\|[^|]+\|[^|]+\| (Да |Нет) \|', '-nf1000:AUTORESC_UPD1';

P::trig {
  P::disable('AUTORESC_UPD');
  P::disable('AUTORESC_UPD1');

  if ($#f2resc >= 0) {
    my $s = '';
    foreach my $m (@f2resc) {
      $s .= ($s ? ', ' : '') . $m->{VIN};
    }
    U::sendline("гг рескаю: $s");
    U::sendline('соск;отпу');
    P::enable('AUTORESC');
  } else {
    U::sendline('гг некого тут рескать');
  }
} '^$', '-nf1000:AUTORESC_UPD1';

P::alias {
  set_mode_resc_on();
} 'рескай';

P::alias {
  set_mode_resc_off();
} 'нерескай';

P::trig {
  U::sendline('соск;отпу');
} '^Ну раскорячили вы ноги по сторонам, ', '-nf1000:AUTORESC';

1;
