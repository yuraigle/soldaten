package Reactions;

use List::MoreUtils qw/any/;

P::trig { U::sendline('1') } '^Вы мертвы! Нам очень жаль', 'nf1000';

my @botovod = split /\s*,\s*/sxm, $App::CONF->{GROUP}->{botovod};
my @recall_corpse = split /\s*,\s*/sxm, $App::CONF->{GROUP}->{recall_corpse};

P::trig {
  my ( $nam, $act ) = ( $1, $2 );
  $act =~ s/^\s*//sxm;
  Common::act_bot($act) if ( any { $_ eq $nam } @botovod );
} '^(.*) сообщила? группе : \'!(.*)\'', 'nf1000';

P::trig {
  my ( $nam, $me, $act ) = ( $1, $2, $3 );
  $act =~ s/^\s*//sxm;
  return if ( $me ne $App::CONF->{CONNECT}->{name} );
  Common::act_bot($act) if ( any { $_ eq $nam } @botovod );
} '^([А-Яа-я]+) сообщила? группе : \'([А-Яа-я]+) (.*?)\'', 'nf1000';

P::trig {
  my $nam = $1;
  return if Target1::have_pk_target();
  if (any { $_ eq $nam } @recall_corpse) {
    U::sendline("~;взя все;зачит свит.возв");
  }
} '^([А-Яа-я]+) мертва?, е..? душа медленно ', 'nf100';

my $last_eat = 0;

my @im_hungry = (
  '^Вы голодны.',
  '^Вас мучает жажда.',
  '^Вы очень голодны.',
  '^Вы готовы сожрать быка.',
  '^Вас сильно мучает жажда.',
  '^Вам хочется выпить озеро.',
);

foreach (@im_hungry) {
  P::trig {
    if (time - $last_eat > 5) {
      U::sendline($App::CONF->{ALIAS}->{'еда'});
      $last_eat = time;
    }
  } $_, 'nf1000';
}

my @im_down = (
  '^Нет... Вы слишком расслаблены...',
  '^Пожалуй, вам лучше встать на ноги.',
  '^Вам лучше встать на ноги!',
  '^Вы попытались подсечь .*, но упали сами...$',
  '^Похоже, в этой позе Вы много не наколдуете.$',
  '^Вас повалило на землю.',
  '^Вы полетели на землю от мощного удара ',
  ' завалил.? вас на землю. Поднимайтесь!$',
  ' ловко подсек.?.? вас, усадив на попу\.$',
);

foreach (@im_down) {
  P::trig { U::sendline('вста') } $_, 'nf1000';
}

# вооружаемся после рекола
my $nam = U::cyr_upper($App::CONF->{CONNECT}->{name});
P::trig {
  if ($App::MODE eq 'двуруч') {
    U::sendline("воор $nam.ДВУРУЧ обе");
  } elsif ($App::MODE eq 'щит') {
    U::sendline("наде $nam.ЩИТ щит");
    U::sendline("держ $nam.СВЕТ");
  }
} '^Вы (зачитали|осушили) ', 'nf1000';

# точкой выбили оружие
P::trig {
  U::sendline("вз все.$nam");
  if ($App::MODE eq 'двуруч') {
    U::sendline("воор $nam.ДВУРУЧ обе");
  } elsif ($App::MODE eq 'щит') {
    U::sendline("воор $nam.ПРАЙМ");
    U::sendline("наде $nam.ЩИТ щит");
    U::sendline("держ $nam.СВЕТ");
  }
} ' выпал.? из ваших рук\.$', 'nf1000';

1;
