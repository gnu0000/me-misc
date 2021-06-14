#!perl
#
use bignum;

my $TRIES = 10000;
my $SHOW = 0;
my $SHOW2 = 0;
my $SHOW3 = 1;

MAIN:
   GenPalindromes(1,5000);
   exit (0);




sub GenPalindromes
   {
   my ($start, $end) = @_;

   my $unfound = 0;

   for (my $i=$start; $i<=$end; $i++)
      {
      my $found = 0;
      print "[$i]\n" if $SHOW;
      my $curr = $i;
      for (my $step=0; $step<$TRIES; $step++)
         {
         if (Palindromic($curr)) 
            {
            print "$i palendrome took $step steps\n" if $step > 10 && $SHOW3;

            print "$i palendrome took $step steps\n" if $SHOW2;

            print "$curr ($step steps)\n" if $SHOW;
            $found = 1;
            last;
            }
         my $reversed = reverse "$curr";
         $reversed += 0;

         print  " $curr + $reversed = " if $SHOW;
         $curr += $reversed;
         print "$curr\n" if $SHOW;
         }
      print "******** no solution for $i in the first $TRIES tries ******\n" unless $found;
      $unfound++ unless $found;

      print "\n-----------------------------------------------\n" if $SHOW;
      }
   print "($unfound numbers not found)\n";
   }






sub Palindromic
   {
   my ($val) = @_;

   my $reversed = reverse "$val";

   return $val == $reversed;
   }