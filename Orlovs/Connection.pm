package Connection;

my $was_online = time;

sub try_connect {
  my ( $server, $port ) = split /:/sxm, $App::CONF->{CONNECT}->{server};
  CMD::cmd_connect( $server, $port );
}

sub on_prompt {
  my ( $prompt, $prompt_uc ) = @_;
  $was_online = time;

  U::sendline('2') if $prompt_uc =~ m/^Select\sone/sxm;
  CMD::cmd_cr() if $prompt_uc =~ m/ANYKEY\sнажмите\sENTER/sxm;

  if ( $prompt_uc =~ m/^¬ведите\sим€\sперсонажа/sxm ) {
    my $name = $App::CONF->{CONNECT}->{name};
    my $pass = $App::CONF->{CONNECT}->{pass};
    P::sendl(qq/$name $pass/);
  }
}

if ($App::CONF->{CONNECT}->{reconnect}) {
  P::timeout {
    if ( time - $was_online > 300 ) {
      try_connect(); # не было промта в течение 5 минут
    }
  } 30000;
}

if ($App::CONF->{CONNECT}->{logging}) {
  my $folder = $App::CONF->{CONNECT}->{logging};
  P::hook {
    my $fileName = q/#/ . U::date_format() . '.txt';
    MUD::logopen("$folder/$fileName");
  } 'connect';

  P::hook {
    MUD::logopen();
  } 'disconnect';
}

1;
