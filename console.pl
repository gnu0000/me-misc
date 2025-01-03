#!perl
#
#  https://learn.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences#
#  print "\x1b]4;14;rgb:c0/c0/ef\x07"; # B0 0B
#  Craigf Fitzgerald

use warnings;
use strict;
use File::Basename;
use lib dirname(__FILE__) . "/lib";
use Gnu::Color   qw(:ALL);
use Gnu::ArgParse;
use Gnu::Template  qw(Usage);


MAIN:
   $| = 1;
   ArgBuild("*^charset *^colors *^setcolor *^palette *^export= *^import= *^soft *^example *^list *^test *^help *^debug ?");
   ArgParse(@ARGV) or die ArgGetError();
   Usage () if ArgIs("help") || ArgIs("?") || scalar @ARGV < 1;
   Go();
   exit(0);


sub Go {
   return ShowCharset()             if ArgIs("charset");
   return ShowColors ()             if ArgIs("colors" );
   return ListColors ()             if ArgIs("list"   );
   return SetPalette (ArgGetAll())  if ArgIs("palette");
   return ExportPal  (ArgGetAll())  if ArgIs("export");
   return ImportPal  (ArgGetAll())  if ArgIs("import");
   return SoftPalette()             if ArgIs("soft");
   return SetColor   (join(" ", ArgGetAll()));
}


sub ShowCharset {
   # header labels
   SetColor();
   print(" " x 4);
   for my $x (0..15) {printf(" %2.2X ", $x)}
   print("\n");
   SetColor("gray on black");

   # box top
   print(" " x 4 . safec(201));
   for my $x (0..15) {printf(safec(205) x 3 . safec($x == 15 ? 187 : 209))}
   print("\n");

   # box body
   for my $y (0..15) {
      SetColor();
      printf(" %2.2X ", $y * 16);
      SetColor("gray on black");
      print(safec(186));

      for my $x (0..15) {
         SetColor("white on black");
         print(" " . safec($y*16+$x));
         SetColor("gray on black");
         print(" " . safec($x==15 ? 186 : 179));
      }
      printf("\n    " . safec(186));
      for my $x (0..15) {
         SetColor("lightmagenta on black");
         printf("%3.3d", $y*16+$x);
         SetColor("gray on black");
         printf(safec($x==15 ? 186 : 179));
      }
     print("\n");
   }
   #box bottom
   printf("    " . safec(200));
   for my $x (0..15) {printf(safec(205) x 3 . safec($x==15 ? 188 : 207))}
   print("\n");
   SetColor();
}


sub ShowColors { 
   # header labels
   print(" " x 4);
   for my $x (0..15) {printf(" %2.2X ", $x * 16)}
   print("\n");

   # box top
   print(" " x 4 . safec(201));
   for my $x (0..15) {printf(safec(205) x 3 . safec($x == 15 ? 187 : 209))}
   print("\n");

   # box body
   for my $y (0..15) {
      SetColor();
      printf(" %2.2X ", $y);
      print(safec(186));

      for my $x (0..15) {
         SetColor(sprintf("%2.2x", $y + $x * 16));
         print " @ ";
         SetColor();
         print(safec($x==15 ? 186 : 179));
      }
      printf("\n    " . safec(186));
      for my $x (0..15) {
         SetColor(sprintf("%2.2x", $y + $x * 16));
         print "   ";
         SetColor();
         printf(safec($x==15 ? 186 : 179));
      }
     print("\n");
   }
   #box bottom
   printf("    " . safec(200));
   for my $x (0..15) {printf(safec(205) x 3 . safec($x==15 ? 188 : 207))}
   print("\n");
   SetColor();
}


sub ListColors {
   my $curr = ConAttr();
   my $bg   = $curr & 0xF0;

   foreach my $idx (0..15) {
      SetColorByIndex($idx);
      my $name = ColorSpec($idx)->{name};
      printf ("[%x] This foreground color is $name\n", $idx);
   }
   SetColor();
}

sub safec {
   my ($i) = @_;

   my %bad = map{$_=>1} (0, 7..15, 0x1B, 0x7F);
   return $bad{$i} ? " " : sprintf("%c", $i);
}

sub ExportPal {
   my $filespec = ArgGet("export");
   open (my $fh, ">", $filespec) or die "Can't open '$filespec'";
   my $palette = GetPalette();
   print $fh $palette;
   close($fh);
   print "Palette exported to '$filespec'\n";
}

sub ImportPal {
   my $filespec = ArgGet("import");
   open (my $fh, "<", $filespec) or die "Can't open '$filespec'";
   my $line = <$fh>;
   chomp $line;
   SetPalette($line);
   close($fh);
   print "Palette imported\n";
}

sub SoftPalette {
   SetPalette("9:8b/a6/e0,a:97/e0/8b,b:8b/e0/d9,c:e0/8b/95,d:da/8b/e0,e:e0/d7/8b");
   SetColor("09");


}

__DATA__

[usage]
console.pl - View/Set console colors and charset

Usage: console.pl [options]

Where options is one of:
   -charset ........................ Show the charset for this codepage
   -colors ......................... Show the current fg / bg colors
   -list ........................... Show example fg colors on current bg
   -setcolor <fg> on <bg> .......... Set curtrent colors
   -palette  <color> <r>/<g>/<b> ... Adjust the color palette (hex vals)
   -soft ........................... Adjust the bright colors to be softer

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
      console.pl  -setcolor B0             (hex bg/fg)
   
   Change a palette color
      console.pl  -palette brightred ff/66/22
      console.pl  -palette brightblue default 
[fini]