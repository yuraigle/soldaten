package Layout;

use List::MoreUtils qw/any none/;

# ????????? ?????? ? ???

my @success_skills = (
  '^[^:\']+ ???????.? .* ?? ????? ?????? ??????.*',
  '^????? ?????? .* ???????.? .* ?? ?????.*',
  '^[^:\']+ ???????.? .* ?? ???? ??????. .* ?????? ?????? ????????? .*',
  '^[^:\']+ ???????.? ???? ?????? ? ????? .* ?? ???????? .*',
  '^?????????? ?????? ? ?????, .* ????????.? .* ? ????????.*',
  '^[^:\']+ ?????.?.? ???? ????? ??????? ? ????? .*',
  '^[^:\']+ ????? ??????.*, ?????? .*',
  '^[^:\']+ ????? ?????.? .* ?? ???.*',
  '^[^:\']+ ????????.* ?? ???????????? ????? .*',
  '^[^:\']+ ???????.* ?? ???????????? ????? .*',
  '^[^:\']+ ?????????.* ?? ???????????? ????? .*',
  '^[^:\']+ ?????????.* ?? ???????????? ????? .*',
  '^[^:\']+ ????? ?????????? ?????? ????.*',
  '^[^:\']+ ?????? ?????? ???????.? .*',
  '^[^:\']+ ?????? ?????? ????????.? .+!$',
  '^[?-?][^:\']+ ???????[???]? .*',
);

my @blacklist_success = (
  '???? ?????? ????? ???????? ',
  '??? ????????? ???? ??????? ',
  '?????? ????? ?? ????????? ??????? ???!',
);

foreach (@success_skills) {
  P::trig {
    my $line = $_;
    $: = "\3F$line" if none { $line =~ m/^$_/sm } @blacklist_success;
  }
  $_, 'nf1000';
}

# ???????? ??? ?????
P::trig {
  $: = "\3C$_";
}
'^?????? ????????? ', 'nf1000';

# ?????? ????? ????? ?????
P::trig {
  $: = "\3E$_";
}
'^???? ?????? ????????? ?????? ?????? .+\.$', 'nf1000';

my @fail_skills = (
  '^[^:\']+ ???????.??. ?? ??????? .* ???????? ',
  '^[^:\']+ ???????.??. ???????? .*, ?? ',
  '^[^:\']+ ???????.? ??????? .* ???????? ',
  '^[^:\']+ ???????...? ??????? .* ???? ? ?????,',
  '^[^:\']+ ?? ?????.? ????? ??????? ? ????? ',
  '^[^:\']+ ???????.??. ??????? .*, ?? ',
  '^[^:\']+ ???????.??. ????????? .*, ?? ',
);

foreach (@fail_skills) {
  P::trig { $: = "\3I$_" } $_, 'nf1000';
}

my @magic_throws = (
  '^[^:\']+ ?????.?.? ?? ?????!$',
  '^[^:\']+ ????????.? ????!$',
  '^[^:\']+ ??????.?.? ?????????\.$',
);

foreach (@magic_throws) {
  P::trig { $: = "\3O$_" } $_, 'nf1000';
}

# ???????? ? ????????? ????. ALT+2
my @talks = (
  '^[?-?][?-?]+ ???????: \'.*\'\.$',
  '^[?-?][?-?]+ ?????????: \'.*\'\.$',
  '^[?-?][?-?]+ ??????.? : \'.*\'$',
  '^[?-?][?-?]+ ??????.? ??? : \'.*\'$',
  '^?? ??????? [?-?][?-?]+ : \'.*\'$',
  '^[?-?][?-?\-]+ ???????.? : \'.*\'$',
  '^[?-?][?-?\-]+ ???????.? ?????? : \'.*\'$',
  '^[?-?][?-?]+ ????? ???????: \'.*\'$',
  '^[?-?][?-?]+ ????? ?????????: \'.*\'$',
  '^[?-?][?-?\-]+ ???????.? ??? : \'.*\'$',
  '^[?-?][?-?\-]+ ????????.? : \'.*\'$',
  '^[?-?][?-?\-]+ ??????.? : \'.*\'$',
  '^[?-?][?-?\-]+ ?????????.? [^:\' ]+ : \'.*\'$',
  '^\[??????\] .*',
  '^?? ???????? ? ????? ? ?????????? : \'.*\'$',
  '^???-?? ??????.? : \'.*\'$',
  '^???-?? ??????.? ??? : \'.*\'$',
);

my @blacklist_talkers = (
  '???????',  '?????',      '??????????', '???????',
  '??????',   '???????',    '???????',    '???????????',
  '????????', '????????',   '???????',    '?????',
  '???????',  '????????',   '????????',   '???????',
  '????????', '??????????', '??????',
);

my @blacklist_talks = (
  '?????-??????????-?????????????!',
  '?????????-????????????!',
  '??-??-???-??-???????!',
);

foreach (@talks) {
  P::trig {
    my $line = $_;
    return if any { $line =~ m/^$_/sxm } @blacklist_talkers;
    return if any { $line =~ m/'$_'$/sxm } @blacklist_talks;
    P::wecho( 1, U::time_format() . CL::unparse_colors($;) );
  }
  $_, 'nf1000';
}

# ??? ? ????????? ????. ALT+3
P::trig {
  return if ( $3 =~ m/^[?-?\s]+\s?????$/sxm );

  P::wecho( 2, U::time_format() . "$1 ????$2 \3C$3\3H ?? ????? $4" );
  $: = "$1 ????$2 \3C$3\3H ?? ????? $4";
}
'^([^ ]+?) ????(.?) (.+) ?? ????? (.*)$', 'nf10000';

P::trig {
  return if $2 =~ m/\s??\s????????\s???????/sxm;

  P::wecho( 2, U::time_format() . "?? ????? ?????$1 ?????? \3C$2\3H." );
  $: = "?? ????? ?????$1 ?????? \3C$2\3H.";
}
'^?? ????? ?????(.??.) ?????? (.*).', 'nf10000';


# ?????? ????? ? ???? ?4
my $last_mob = '';

P::trig {
  $last_mob = $1;
  P::enable('GETEXP');
} '^([^:]+) ?????.?, ...? ???? ???????? ?????????? ? ??????\.$', 'nf1000';

P::trig {
  $last_mob = $1;
  P::enable('GETEXP');
} '^([^:]+) ????????.? ? ????????.??. ? ????\.$', 'nf1000';

P::trig {
  P::disable('GETEXP');
} '^$', '-nf1000:GETEXP';

P::trig {
  P::wecho(3, U::time_format() . "???????? $1 ?? $last_mob");
  P::disable('GETEXP');
} '^??? ???? ????????? ?? (\d+)', '-nf1000:GETEXP';

1;
