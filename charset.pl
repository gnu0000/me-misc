#!perl
#
# charset.pl  - show ascii chars or console colors
# Craig Fitzgerald

use Gnu::Console qw(:ALL);
use Gnu::ArgParse;

# print "\x1b]4;14;rgb:c0/c0/ef\x07"; # B0 0B

#ConAttr($FG_LIGHTCYAN | $BG_BLACK);

my $DEFAULT = ConAttr();

MAIN:
   $| = 1;
   ArgBuild("*^colors");
   ArgParse(@ARGV) or die ArgGetError();
   my $attr = ConAttr();
   ConAttr($FG_GRAY | $BG_BLACK);
   ArgIs("colors") ? DrawColorBox() : DrawCharBox();
   #ConAttr($attr);
   #ConAttr($FG_LIGHTGRAY | $BG_BLACK);
   d();



sub DrawCharBox {
   # header labels
   ConAttr($FG_LIGHTGRAY | $BG_BLACK);
   print(" " x 4);
   for my $x (0..15) {printf(" %2.2X ", $x)}
   print("\n");
   ConAttr($FG_GRAY | $BG_BLACK);

   # box top
   print(" " x 4 . c(201));
   for my $x (0..15) {printf(c(205) x 3 . c($x == 15 ? 187 : 209))}
   print("\n");

   # box body
   for my $y (0..15) {

      ConAttr($FG_LIGHTGRAY | $BG_BLACK);
      printf(" %2.2X ", $y * 16);
      ConAttr($FG_GRAY | $BG_BLACK);
      print(c(186));

      for my $x (0..15) {
         ConAttr($FG_WHITE | $BG_BLACK);
         print(" " . c($y*16+$x));
         ConAttr($FG_GRAY | $BG_BLACK);
         print(" " . c($x==15 ? 186 : 179));
      }
      printf("\n    " . c(186));
      for my $x (0..15) {
         #printf("%3.3d" . c($x==15 ? 186 : 179), $y*16+$x)
         ConAttr($FG_MAGENTA | $BG_BLACK);
         printf("%3.3d", $y*16+$x);
         ConAttr($FG_GRAY | $BG_BLACK);
         printf(c($x==15 ? 186 : 179));
      }
     print("\n");
   }
   #box bottom
   printf("    " . c(200));
   for my $x (0..15) {printf(c(205) x 3 . c($x==15 ? 188 : 207))}
   print("\n");
}


sub DrawColorBox {
   # header labels
   d();
   print(" " x 4);
   for my $x (0..15) {printf(" %2.2X ", $x)}
   print("\n");
   d();

   # box top
   print(" " x 4 . c(201));
   for my $x (0..15) {printf(c(205) x 3 . c($x == 15 ? 187 : 209))}
   print("\n");

   # box body
   for my $y (0..15) {

      d();
      printf(" %2.2X ", $y * 16);
      d();
      print(c(186));

      for my $x (0..15) {
         ConAttr($y * 16 + $x);
         print " @ ";
         d();
         print(c($x==15 ? 186 : 179));
      }

      printf("\n    " . c(186));
      for my $x (0..15) {
         ConAttr($y * 16 + $x);
         print "   ";
         d();
         printf(c($x==15 ? 186 : 179));
      }
     print("\n");
   }
   #box bottom
   printf("    " . c(200));
   for my $x (0..15) {printf(c(205) x 3 . c($x==15 ? 188 : 207))}
   print("\n");
}


sub c {
   my ($i) = @_;

   my %bad = map{$_=>1} (0, 7..15, 0x1B, 0x7F);

   return $bad{$i} ? " " : sprintf("%c", $i);
}

sub d {
   ConAttr($DEFAULT);
}













