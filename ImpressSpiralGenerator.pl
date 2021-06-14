#!perl
# 
# Craig Fitzgerald

use warnings;
use strict;
use List::Util qw(sum);
use Gnu::ArgParse;
use Gnu::Template;

MAIN:
   print Template("preamble"  );
   print Template("head"      );
   print Template("top"      );
   GenSpiral (40);
   print Template("end"       );


sub GenSpiral
   {
   my ($points) = @_;

   my $direction = 0;
   my $x = 0;
   my $y = 0;
   my $length = 1;

   print Template("slide", i=>0, x=>0, y=>0);
   for (my $i=1; $i<$points; $i++)
      {
      my $t = 
      $direction == 0 ? $y-- :
      $direction == 1 ? $x++ :
      $direction == 2 ? $y++ :
      $direction == 3 ? $x-- : "";

      if (!--$length) 
         {
         $direction = ($direction+1) % 4;
         $length = 1 + int($i/2);
         }
      print Template("slide", i=>$i, x=>$x*1000, y=>$y*800);
      }
   }

__END__
[preamble]
Content-type: text/html

[head]
<!DOCTYPE html>
<html>
   <head>
      <title>test</title>
      <meta http-equiv="content-type" content="text/html;charset=utf-8" />
      <link href="/css/SlideShow2.css" rel="stylesheet">
   </head>
[top]
   <body class="impress-not-supported">
      <div id="impress" data-transition-duration="300">
[slide]
         <div class="step slide" data-x="$x" data-y="$y">
            <p>This is slide ($i: $x,$y)</p>
         </div>
[end]
      </div>
      <script src="/js/impress.js"></script>
      <script>impress().init();</script>
   </body>
</html>
