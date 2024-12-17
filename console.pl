#!perl
#
#  https://learn.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences#
#  print "\x1b]4;14;rgb:c0/c0/ef\x07"; # B0 0B
#  Craigf Fitzgerald

use Gnu::Console qw(:ALL);
use Gnu::ArgParse;
use Gnu::Template  qw(Usage);
use Gnu::DebugUtil   qw(_StackLocation _StkStr DumpRef);


my @COLORINFO = (
   {name => "black"       , idx => $FG_BLACK       , palette => 0 },
   {name => "blue"        , idx => $FG_BLUE        , palette => 4 },
   {name => "green"       , idx => $FG_GREEN       , palette => 2 },
   {name => "cyan"        , idx => $FG_CYAN        , palette => 6 },
   {name => "red"         , idx => $FG_RED         , palette => 1 },
   {name => "magenta"     , idx => $FG_MAGENTA     , palette => 5 },
   {name => "brown"       , idx => $FG_BROWN       , palette => 3 },
   {name => "lightgray"   , idx => $FG_LIGHTGRAY   , palette => 7 },
   {name => "gray"        , idx => $FG_GRAY        , palette => 8 },
   {name => "lightblue"   , idx => $FG_LIGHTBLUE   , palette => 12},
   {name => "lightgreen"  , idx => $FG_LIGHTGREEN  , palette => 10},
   {name => "lightcyan"   , idx => $FG_LIGHTCYAN   , palette => 14},
   {name => "lightred"    , idx => $FG_LIGHTRED    , palette => 9 },
   {name => "lightmagenta", idx => $FG_LIGHTMAGENTA, palette => 13},
   {name => "yellow"      , idx => $FG_YELLOW      , palette => 11},
   {name => "white"       , idx => $FG_WHITE       , palette => 15},
);

my %NAMEMAP = map{$_->{name} => $_} @COLORINFO;

# Microsoft's names, not mine
my $CSI = "\x1b[";  # CSI  means  Control Sequence Introducer
my $OSC = "\x1b]";  # OSC  means  Operating system command
my $ST  = "\x07";

my $DEFAULT = ConAttr();


MAIN:
   $| = 1;
   ArgBuild("*^charset *^colors *^setcolor *^palette *^example *^list *^help ?");
   ArgParse(@ARGV) or die ArgGetError();
   Usage () if ArgIs("help") || ArgIs("?") ||!ArgIsAny(qw{palette setcolor charset colors example list});

   SetPalette ()  if ArgIs("palette" );
   SetColor   ()  if ArgIs("setcolor");
   ShowCharset()  if ArgIs("charset" );
   ShowColors ()  if ArgIs("colors"  );
   Example    ()  if ArgIs("example" );
   Example    ()  if ArgIs("list" );
   exit(0);


# -color blue on black
# -color green
# -color on gray
#
sub SetColor {   
   my $curr  = ConAttr();
   my @parts = ArgGetAll();

   if (scalar @parts == 3) {
      die "invalid params" unless $parts[1] =~ /^on/i;
      $fg = ColorIndex($parts[0]);
      $bg = ColorIndex($parts[2]) << 4;
      ConAttr($fg | $bg);
   }
   if (scalar @parts == 2) {
      die "invalid params" unless $parts[0] =~ /^on/i;
      $fg = $curr & 0x0f;
      $bg = ColorIndex($parts[1]) << 4;
      ConAttr($fg | $bg);
   }
   if (scalar @parts == 1) {
      $fg = ColorIndex($parts[0]);
      $bg = $curr & 0xf0;
      ConAttr($fg | $bg);
   }
}

# -palette red ff/66/22
#
sub SetPalette {
   my ($color, $rgb) = ArgGetAll();
   my $curr  = ConAttr();

   die "unknown color $color" unless exists($NAMEMAP{lc $color});
   my $spec = $NAMEMAP{lc $color};
   die "invalid color spec" unless $rgb =~ /^[0-9a-f]{2}\/[0-9a-f]{2}\/[0-9a-f]{2}/i;

   print $OSC . "4;$spec->{palette};rgb:$rgb" . $ST;

   $bg = $curr & 0xf0;
   ConAttr($spec->{idx} | $bg);
   print "Palette for $color changed to $rgb\n";
   ConAttr($curr);
}


sub ShowCharset {
   my $curr = ConAttr();

   # header labels
   ConAttr($FG_LIGHTGRAY | $BG_BLACK);
   print(" " x 4);
   for my $x (0..15) {printf(" %2.2X ", $x)}
   print("\n");
   ConAttr($FG_GRAY | $BG_BLACK);

   # box top
   print(" " x 4 . safec(201));
   for my $x (0..15) {printf(safec(205) x 3 . safec($x == 15 ? 187 : 209))}
   print("\n");

   # box body
   for my $y (0..15) {

      ConAttr($FG_LIGHTGRAY | $BG_BLACK);
      printf(" %2.2X ", $y * 16);
      ConAttr($FG_GRAY | $BG_BLACK);
      print(safec(186));

      for my $x (0..15) {
         ConAttr($FG_WHITE | $BG_BLACK);
         print(" " . safec($y*16+$x));
         ConAttr($FG_GRAY | $BG_BLACK);
         print(" " . safec($x==15 ? 186 : 179));
      }
      printf("\n    " . safec(186));
      for my $x (0..15) {
         #printf("%3.3d" . safec($x==15 ? 186 : 179), $y*16+$x)
         ConAttr($FG_MAGENTA | $BG_BLACK);
         printf("%3.3d", $y*16+$x);
         ConAttr($FG_GRAY | $BG_BLACK);
         printf(safec($x==15 ? 186 : 179));
      }
     print("\n");
   }
   #box bottom
   printf("    " . safec(200));
   for my $x (0..15) {printf(safec(205) x 3 . safec($x==15 ? 188 : 207))}
   print("\n");
   ConAttr($curr);
}


sub ShowColors { 
   my $curr = ConAttr();
   # header labels
   print(" " x 4);
   for my $x (0..15) {printf(" %2.2X ", $x)}
   print("\n");

   # box top
   print(" " x 4 . safec(201));
   for my $x (0..15) {printf(safec(205) x 3 . safec($x == 15 ? 187 : 209))}
   print("\n");

   # box body
   for my $y (0..15) {
      ConAttr($curr);
      printf(" %2.2X ", $y * 16);
      print(safec(186));

      for my $x (0..15) {
         ConAttr($y * 16 + $x);
         print " @ ";
         ConAttr($curr);
         print(safec($x==15 ? 186 : 179));
      }
      printf("\n    " . safec(186));
      for my $x (0..15) {
         ConAttr($y * 16 + $x);
         print "   ";
         ConAttr($curr);
         printf(safec($x==15 ? 186 : 179));
      }
     print("\n");
   }
   #box bottom
   printf("    " . safec(200));
   for my $x (0..15) {printf(safec(205) x 3 . safec($x==15 ? 188 : 207))}
   print("\n");
   ConAttr($curr);
}


sub Example {
   my $curr = ConAttr();
   my $bg   = $curr & \xFF00;
   
   foreach my $spec (@COLORINFO) {
      ConAttr($spec->{idx} | $bg);
      print "This foreground color is $spec->{name}\n";
   }
   ConAttr($curr);
}

sub ColorIndex {
   my ($name) = @_;

   die "unknown color $name" unless exists($NAMEMAP{lc $name});
   return $NAMEMAP{lc $name}->{idx};
}

sub safec {
   my ($i) = @_;

   my %bad = map{$_=>1} (0, 7..15, 0x1B, 0x7F);
   return $bad{$i} ? " " : sprintf("%c", $i);
}


__DATA__

[usage]
console.pl - View/Set console colors and charset

Usage: console.pl [options]

Where options is one of:
   -charset ........................ Show the charset for this codepage
   -colors ......................... Show the current fg / bg colors
   -example ........................ Show example fg colors on current bg
   -setcolor <fg> on <bg> .......... Set curtrent colors
   -palette  <color> <r>/<g>/<b> ... Adjust the color palette

Examples:
   Show the current character set
      console.pl  -charset

   Show the possible fg & bg color combinations
      console.pl  -colors

   Show example text in all the fg colors on current bg color
      console.pl  -example

   Set the current console color
      console.pl  -setcolor gray on black
      console.pl  -setcolor gray           (set fg only)
      console.pl  -setcolor on black       (set bg only)
   
   Change a palette color
      console.pl  -palette red ff/66/22
[fini]