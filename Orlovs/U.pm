package U;

use strict;
use warnings;
our $VERSION = 1.0;

# ïîñûëàåì ñòðîêó íà ñåðâåð
sub sendline {
    my $line = "@_";
    $line =~ s/\s*;\s*/\n/sxmg;
    P::sendl($line);
    P::echo("\3D[@_]");
    return 1;
}

# âîçâðàùàåò öâåò ñèìâîëà â ñòðîêå
sub get_color {
    my ( $line, $n ) = @_;
    if ( length $line >= 2 * $n + 1 ) {
        my $symbol = substr $line, 2 * $n + 1, 1;
        my $char = ord($symbol) + ord 'A';
        return chr $char;
    }
}

sub cyr_lower {
  my ($s) = @_;
  $s =~ tr/ÉÖÓÊÅÍÃØÙÇÕÚÔÛÂÀ/éöóêåíãøùçõúôûâà/;
  $s =~ tr/ÏÐÎËÄÆÝß×ÑÌÈÒÜÁÞ¨/ïðîëäæýÿ÷ñìèòüáþ¸/;
  return lc $s;
}

sub cyr_upper {
  my ($s) = @_;
  $s =~ tr/éöóêåíãøùçõúôûâà/ÉÖÓÊÅÍÃØÙÇÕÚÔÛÂÀ/;
  $s =~ tr/ïðîëäæýÿ÷ñìèòüáþ¸/ÏÐÎËÄÆÝß×ÑÌÈÒÜÁÞ¨/;
  return lc $s;
}

sub trim {
  my ($s) = @_;
  $s =~ s/^\s+//sxm;
  $s =~ s/\s+$//sxm;
  return $s;
}

sub same {
  my ( $s1, $s2 ) = @_;
  return 0 if ( !$s1 || !$s2 );
  return trim( cyr_lower($s1) ) eq trim( cyr_lower($s2) );
}

# ôîðìàò [08:45]
sub time_format {
    my ( $sec, $min, $hour ) = localtime;
    return sprintf '[%02d:%02d] ', $hour, $min;
}

# ôîðìàò YYYY-MM-DD
sub date_format {
    my ( $sec, $min, $hour, $day, $mon, $year ) = localtime;
    $year += 1900;
    $mon  += 1;
    return sprintf '%04d-%02d-%02d', $year, $mon, $day;
}

sub showme {
  my ($s) = @_;
  P::echo("\3J-\3K:\3J- \3H" . $s);
  return 1;
}

# Ãîðÿ÷àÿ ãîëîâà Âèããå, Îòâàæíûé âîèí Èãîðåâîé ðàòè (õðàáð ÈÐ) => Âèããå
sub name_from_titles {
    my ($nam) = @_;
    $nam =~ s/\s\(.*$//sxm;
    $nam =~ s/^([^,]+),.*$/$1/sxm;
    my @arr = split /\s/sxm, $nam;
    return $arr[$#arr];
}

# ïåñòðîãî äÿòëà => ïåñ.äÿò
sub make_alias {
  my ($s) = @_;
  $s = U::cyr_lower($s);
  my $alias = q//;
  my $wn = 0;
  for my $w (split '[\s\-,]+', $s) {
    if (length($w) >= 3 && $wn < 2) {
      $alias .= $alias ? '.' : '';
      $alias .= substr($w, 0, 3);
      $wn++;
    }
  }
  return $alias ? $alias : $s;
}

1;
