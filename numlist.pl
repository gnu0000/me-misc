#!perl

use warnings;
use strict;
use Gnu::ArgParse;
use Gnu::Template qw(Template Usage);


MAIN:
   $| = 1;
   ArgBuild("*^start= *^end= *^digits= ^*hex *^help ?");
   ArgParse(@ARGV) or die ArgGetError();
   Usage() if ArgIsAny("help", "?");

   my $hex    = ArgIs("hex");
   my $start  = Boundry(ArgGet("start"), 0, $hex);
   my $end    = Boundry(ArgGet("end"), 99, $hex);
   my $digits = ArgGet("digits") || DeriveDigits($end, $hex);

   for (my $i = $start; $i <= $end; $i++) {
      printf("%0" . $digits . ($hex?"x":"d") . "\n", $i);
   }


sub Boundry {
   my ($num, $default, $hex) = @_;
   $num = defined $num ? $num : $default;
   return $hex ? hex($num) : $num;
}


sub DeriveDigits {
   my ($end, $hex) = @_;
   return length($hex ? sprintf("%x", $end) : sprintf("%d", $end));
}


__DATA__

[usage]
numlist.pl  -  Print a consecutive list of numbers

USAGE: numlist.pl -start 0 -end 50


WHERE: [options] is 0 or more of:
   -start .... Specify starting #
   -end ...... Specify ending #
   -digits ... Make number this many digits
   -hex ...... All numbers are hex
   -help ..... Show this help.

[fini]
