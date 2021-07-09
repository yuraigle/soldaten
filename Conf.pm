package Conf;

## no critic (Variables::ProhibitPackageVars)

use 5.006;
use strict;
use warnings;
no warnings qw/once/;
our $VERSION = 1.0;

# Configuration defaults

# command char, don't forget to update Parser::cmdre if you change this
$Conf::char = q{/};

# Command separator, cannot be changed at runtime
$Conf::sep = q{;};

# default prompt when the client is not connected to a server
$Conf::defprompt = qq/\3Dmmc> /;

# user input color, be sure to call CL::set_iattr() if you change this
$Conf::incolor = 11;

# control chars color
$Conf::iccolor = 15;

# control chars background
$Conf::icbg = 1;

# status line background
$Conf::statusbg = 8;

# status line default foreground
$Conf::statusfg = 15;

# display all text that gets sent to the server
$Conf::send_verbose = 1;

# display various sucky messages
$Conf::verbose = 1;

# status line position
$Conf::status_type = 2;

# number of status lines
$Conf::status_height = 1;

# automatically save triggers, aliases, keybindings, variables
$Conf::save_stuff = 1;

# write ansi escapes into logs if true
$Conf::ansi_log = 0;

# delay for 5 rooms
$Conf::speedwalk_delay = 500;

# log lines _after_ substitutions take place
$Conf::logsub = 1;

# ignore whitespace at start of command when searching for aliases
$Conf::skipws = 0;

# timestamp each logged line
$Conf::timedlog = 0;

# prefix ALL commands, even from triggers and aliases
$Conf::prefixall = 0;

# don't copy input line to main window when processing newline
$Conf::hideinput = 0;

# don't truncate the input line and prompt when copying to main win
$Conf::fullinput = 0;

# чтобы € мог дать кому-то конф и не объ€сн€ть про параметры запуска
our $ROOT = $::rundir;
push @INC, $ROOT;
push @INC, $ROOT . '/lib';

# ini файл который будет загружен
my $profile = ( $ARGV[0] ) ? $ARGV[0] : 'settings';
our $INI = "$ROOT/$profile.ini";
@ARGV = ("-rk $ROOT/Orlovs/App.pm");

1;
