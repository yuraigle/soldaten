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
  $target0 = $s =~ m/^[А-Я]/sxm ? '.' . $target1 : $target1;
}

sub say_target1 {
  if (have_pk_target()) {
    U::sendline("гг моя цель: $target1 (игрок), использую $App::ATT1");
  } elsif ($target1) {
    U::sendline("гг моя цель: $target1, использую $App::ATT1");
  } else {
    U::sendline("гг нет цели! помогаю танку, использую $App::ATT1");
  }
}

P::alias {
  my ($s) = @_;
  $s = U::trim($s);
  set_target1($s);
  say_target1();
} 'ц1';

P::alias {
  set_target1('');
  say_target1();
} 'ц0';

P::alias {
  say_target1();
} 'долц';

P::trig {
  if ($target0) {
    U::sendline("$App::ATT1 $target0");
  }
} '^:.+@', 'nf1000';

P::trig {
  if ($target1 eq $1) {
    U::sendline("$App::ATT1 $target0");
  }
} '^([А-Я][а-я]+) при.+ с.+\.$', 'nf100';

P::trig {
  if ($target1 eq $1) {
    U::sendline("$App::ATT1 $target0");
  }
} '^([А-Я][а-я]+) появил.?с. из пентаграммы\.$', 'nf100';

P::trig {
  if ($target1 eq $1) {
    U::sendline("$App::ATT1 $target0");
  }
} '^([А-Я][а-я]+) прибыл.? по вызову\.$', 'nf100';

P::trig {
  if ($target1 eq $1) {
    U::sendline("$App::ATT1 $target0");
  }
} '^([А-Я][а-я]+) медленно появил.?с. откуда-то\.$', 'nf100';

# продолжаем молотить-глушить-пинать цель в бою
my $last_mo = 0;
my $last_pn = 0;
my $last_og = 0;
my $last_sb = 0;
sub continue_fight {
  if ($App::ATT1 eq 'моло' && !$App::MO && !$App::OZ && time - $last_mo > 0) {
    U::sendline('моло');
    $last_mo = time;
  } elsif ($App::ATT1 eq 'пнут' && !$App::PN && !$App::OZ && time - $last_pn > 0 ) {
    U::sendline("пнут $target0") if $target0;
    U::sendline('пнут');
    $last_pn = time;
  } elsif ($App::ATT1 eq 'оглу' && !$App::OG && !$App::OZ && time - $last_og > 0) {
    U::sendline("оглу $target0") if $target0;
    U::sendline('оглу');
    $last_og = time;
  } elsif ($App::ATT1 eq 'сбит' && time - $last_sb > 0) {
    U::sendline("сбит $target0") if $target0;
    U::sendline('сбит');
    $last_sb = time;
  }
}

P::trig {
  $t0_steps++ if $target0;

  # ходим уже 50 шагов, прошло >5мин, и цель не ПК
  # значит лидер просто забыл сказать ц0
  if (
    $target0 && $target0 !~ m/^\./sxm
    && $t0_steps > 50 
    && time - $t0_set_at > 300
  ) {
    set_target1('');
    say_target1();
  }
} '^Вы поплелись следом за ', 'nf1000';

1;
