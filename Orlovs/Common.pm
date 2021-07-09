package Common;

my $nam = U::cyr_upper($App::CONF->{CONNECT}->{name});
my $prof = $App::CONF->{CHARACTER}->{prof};
my $bag = $App::CONF->{CHARACTER}->{bag};

P::bindkey { U::sendline(q/~/) } q/`/;
P::bindkey { U::sendline(q/~/) } q/ё/;
P::alias { unable_to_move() } q/с/;
P::alias { unable_to_move() } q/ю/;
P::alias { unable_to_move() } q/з/;
P::alias { unable_to_move() } q/в/;

sub unable_to_move {
  P::echo("\3L[WARN] \3Hс одной буквы не хожу")
}

# Бинды от юзера
for my $key (keys %{$App::CONF->{BINDKEY}}) {
  my $act = $App::CONF->{BINDKEY}{$key};

  if ($act eq '_коннект_') {
    P::bindkey { Connection::try_connect() } $key;
  } elsif ($act eq '_двуруч_') {
    P::bindkey { set_mode_two_handed() } $key;
  } elsif ($act eq '_башмод_') {
    P::bindkey { set_mode_shield() } $key;
  } elsif ($act eq '_вскочить_') {
    P::bindkey { mount1() } $key;
  } else {
    P::bindkey { U::sendline($act) } $key;
  }
}

# Алиасы от юзера
for my $key (keys %{$App::CONF->{ALIAS}}) {
  my $act = $App::CONF->{ALIAS}{$key};

  if ($act eq '_коннект_') {
    P::alias { Connection::try_connect() } $key;
  } elsif ($act eq '_двуруч_') {
    P::alias { set_mode_two_handed() } $key;
  } elsif ($act eq '_башмод_') {
    P::alias { set_mode_shield() } $key;
  } elsif ($act eq '_вскочить_') {
    P::alias { mount1() } $key;
  } else {
    P::alias {
      my $s = U::trim("@_");
      (my $t = $act) =~ s/%1/$s/g;
      U::sendline($t);
    } $key;
  }
}

# Простые триггеры от юзера
for my $key (keys %{$App::CONF->{TRIGGERS}}) {
  my $act = $App::CONF->{TRIGGERS}{$key};
  P::trig { U::sendline($act) } $key, 'nf2000';
}

# Обработка команды от лидера
sub act_bot {
  my $s = U::trim("@_");

  my $p, $args;
  if ($s =~ m/^([^\s]+)\s+(.*)$/sxm) {
    ($p, $args) = ($1, $2);
  } else {
    ($p, $args) = ($s, '');
  }

  if ($p eq 'ц1') {
    Target1::set_target1($args);
    Target1::say_target1();
  } elsif ($p eq 'ц0') {
    Target1::set_target1('');
    Target1::say_target1();
  } elsif ($p eq 'долц') {
    Target1::say_target1();
  } elsif ($p eq 'двур' || $p eq 'двуруч') {
    Common::set_mode_two_handed();
  } elsif ($p eq 'башмод' || $p eq 'щит') {
    Common::set_mode_shield();
  } elsif ($p eq 'баш') {
    Common::set_mode_shield();
    Target1::set_target1($args);
    Target1::say_target1();
  } elsif ($p eq 'конфиг') {
    U::sendline('гг версия ' . $App::VERSION);
  } elsif ($p eq 'вск') {
    Common::mount1();
  } elsif ($p =~ m/^(к|ко|кол|колд|К)$/sxm && $prof =~ m/бога|охот|кузн/sxm) {
    return; # мы не колдуем
  } elsif ($p =~ m/^(кли|клич)$/sxm && $prof !~ m/бога|охот|друж/sxm) {
    return; # мы не пляшем
  } else {
    U::sendline($s);
  }
}

sub set_mode_two_handed {
  if ($prof eq 'витязь') {
    U::sendline("вз $nam.ДВУРУЧ $bag");
    U::sendline("сн $nam.ЩИТ;сн $nam.ПРАЙМ;сн $nam.СВЕТ;воор $nam.ДВУРУЧ обе");
    mount1();
    $App::MODE = 'двуруч';
    $App::ATT1 = 'пнут';
  } elsif ($prof eq 'охотник') {
    U::sendline("вз $nam.ЛУК $bag");
    U::sendline("сн $nam.ЩИТ;сн $nam.ПРАЙМ;сн $nam.СВЕТ;воор $nam.ЛУК обе");
    $App::MODE = 'двуруч';
    $App::ATT1 = 'пнут';
    mount1();
  } elsif ($prof =~ m/богатырь|кузнец/sxm) {
    U::sendline("вз $nam.ДВУРУЧ $bag");
    U::sendline("сн $nam.ЩИТ;сн $nam.ПРАЙМ;сн $nam.СВЕТ;воор $nam.ДВУРУЧ обе");
    $App::MODE = 'двуруч';
    $App::ATT1 = 'оглу';
  }
}

sub set_mode_shield {
  if ($prof =~ m/витязь|кузнец/sxm) {
    U::sendline("вз $nam.ПРАЙМ $bag;вз $nam.ЩИТ $bag;вз $nam.СВЕТ $bag");
    U::sendline("сн $nam.ДВУРУЧ;сн $nam.ОФФ;воор $nam.ПРАЙМ;наде $nam.ЩИТ щит;держ $nam.СВЕТ");
    U::sendline('соск;отпу');
    $App::MODE = 'щит';
    $App::ATT1 = 'сбит';
  } elsif ($prof eq 'охотник') {
    U::sendline("сн $nam.ЛУК;сн $nam.ОФФ;воор $nam.ПРАЙМ;наде $nam.ЩИТ щит;держ $nam.СВЕТ");
    U::sendline("вз $nam.ПРАЙМ $bag;вз $nam.ЩИТ $bag;вз $nam.СВЕТ $bag");
    U::sendline('соск;отпу');
    $App::MODE = 'щит';
    $App::ATT1 = 'сбит';
  }
}

sub mount1 {
  U::sendline('соск;отпу');
  U::sendline("снят $nam.САПОГИ;взят сап.шпор $bag;наде сап.шпор");
  U::sendline('топнуть каблук;потереть шпору');
  U::sendline("снят сап.шпор;поло сап.шпор $bag;наде $nam.САПОГИ;вскочить");
}

P::trig {
  if ($prof eq 'богатырь') {
    $App::MODE = 'двуруч';
    $App::ATT1 = 'оглу';
    U::sendline('эм теперь глушит');
  }
} '^Вы взяли .+ в обе руки\.$', 'nf1000';

P::trig {
  if ($prof eq 'богатырь') {
    $App::MODE = 'кулаки';
    $App::ATT1 = 'моло';
  }
} '^Вы прекратили использовать .*(двуруч|дубину|молот).*\.$', 'nf1000';

P::trig {
  if ($prof eq 'богатырь') {
    $App::MODE = 'двуруч';
    $App::ATT1 = 'оглу';
  }
} '^Ваша экипировка мешает вам нанести удар\.$', 'nf1000';


P::trig {
  U::sendline("гг [$1] ошеломить");
} '^\[([\d\s\-!]+)\] ошеломить ', 'nf1000';

P::trig {
  U::sendline('гг Я ПРОКЛЯТ! :(');
} '^Заклинание : проклятие +\(.+ час.+\)\s*$', 'nf1000';

P::trig {
  return if U::get_color( $;, 1 ) ne 'H';
  U::sendline('гг я НЕ МОГУ быть призван');
} '^Вы защищены от призыва.', 'nf1000';

P::trig {
  return if U::get_color( $;, 1 ) ne 'H';
  U::sendline('гг я МОГУ быть призван');
} '^Вы можете быть призваны.', 'nf1000';

P::trig {
  U::sendline('гг я МОГУ быть призван');
} '^ \|\| Вы можете быть призваны.', 'nf1000';

P::trig {
  U::sendline("гг прикрываю $1");
} '^ \|\| Вы прикрываете (.+) от нападения.', 'nf1000';

P::trig {
  if ($prof eq 'богатырь') {
    U::sendline('ярос');
  }
} '^Минул час', 'nf1000';

P::trig {
  U::sendline("гг $1 - следы $2");
} '^([А-Я][а-я]+) : следы (.+)\.$', 'nf1000';

1;
