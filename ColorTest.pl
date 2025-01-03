#!perl
#
use warnings;
use strict;
use File::Basename;
use lib dirname(__FILE__) . "/lib";
use Gnu::ArgParse;
use Gnu::Color     qw(:ALL);
use Gnu::KeyInput  qw(GetKey);
use Gnu::StringInput qw(:ALL);
use Gnu::Template  qw(Usage);

MAIN:
   $| = 1;
   ArgBuild("*^debug ?");
   ArgParse(@ARGV) or die ArgGetError();
   Usage () if ArgIs("help") || ArgIs("?");
   Test4();
   exit(0);


sub Test1 {
   Test("lightblue on black");
   Test("lightcyan on black");
   Test("on gray");
   Test("lightgreen");
   Test("0c");
   Test("lightred", "brown");
   Test();
}

sub Test {
   my ($val1, $val2) = @_;

   my $ct = scalar @_;

   if ($ct == 0) {
      print "No params\n";
      SetColor();
   }
   if ($ct == 1) {
      print "$val1\n";
      SetColor($val1);
      print "And this is the result!\n";
   }
   if ($ct == 2) {
      print "$val1 $val2\n";
      SetColor($val1, $val2);
      print "And this is the result!\n";
   }
}

sub Test2 {
   SetPalette("blue" , "a3/79/ea");
   SetPalette("green", "ea/c2/a4");
   SetColor("blue");
   print "The blue palette was changed to this\n";
   SetColor("green");
   print "The green palette was changed to this\n";

   SetColor("lightgray");
   print "press a key";  GetKey(); print "\n";

   SetPalette("1:87/ea/4d\n2:ea/b6/77");
   SetColor("blue");
   print "The blue palette was changed to this\n";
   SetColor("green");
   print "The green palette was changed to this\n";

   SetColor("lightgray");
   print "press a key";  GetKey(); print "\n";

   print "This is the full palette:\n", GetPalette() . "\n";

   print "press a key";  GetKey(); print "\n";

   SetPalette("blue" );
   SetPalette("green");

   SetColor("blue");
   print "The blue palette was changed back to the default\n";
   SetColor("green");
   print "The green palette was changed back to the default\n";

   SetColor("lightgray");
   print "This is the original palette:\n", GetPalette() . "\n";
}


sub Test3 {
   while () {
      print "\n";
      my $colorString = SIGetString(prompt=>"Color String (xx/xx/xx)");

      my $isHSV = $colorString =~ /^~/;
      my @c1 = SplitColorString($colorString);
      print "split vals: ", join(", ", @c1) . "\n\n";

      my $cvtString = CombineColorString($isHSV ? HSVToRGB(@c1) : RGBToHSV(@c1));
      print "$colorString ==" . ($isHSV ? "HSVToRGB" : "RGBToHSV") . "=> $cvtString\n";
      my @c2 = SplitColorString($cvtString);
      print "split vals: ", join(", ", @c2) . "\n\n`";

      my $backString = CombineColorString($isHSV ? RGBToHSV(@c2) : HSVToRGB(@c2));
      print "$cvtString ==" . ($isHSV ? "RGBToHSV" : "HSVToRGB") . "=> $backString\n";
   }
}


sub Test4 {
   while () {
      print "\n";
      my $colorString = SIGetString(prompt=>"Color String (ex: lightcyan on black)");

      last if $colorString =~ /^q|exit|quit$/i;
      SetColor($colorString);

      my $err = GetColorError();
      print "Error: $err\n" if $err;
   }
}



__DATA__

[usage]
  whatever...