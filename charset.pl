
use Time::HiRes qw(sleep usleep);
#use lib "c:/projects/me/Gnu/lib";
use Gnu::Console qw(:ALL);

MAIN:
   $| = 1;

   my $attr = ConAttr();

   ConAttr($FG_GRAY | $BG_BLACK);
   DrawBox();
   ConAttr($attr);


sub DrawBox {
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
     #last if $y==15;
     #printf("\n    %c", $y==15 ? 200 : 199);
     #for my $x (0..15) {printf(c(196) x 3 . c($x==15 ? 182 : 197))}
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















