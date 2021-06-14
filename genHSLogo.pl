#!perl
#
use warnings;
use strict; 
use POSIX;
use List::Util qw(min max);
use Gnu::Template qw(Template Usage);
use Gnu::ArgParse;

my %CTX;

MAIN:
   ArgBuild("*^size= *^grid= *^radius= *^gap= *^color=");
   ArgParse(@ARGV) or die ArgGetError();
   Usage() if !scalar @ARGV;
   GenLogo();
   exit(0);

sub GenLogo {
   my %ctx = Ctx();
   my $grid = $ctx{grid};
   print Template("top", %ctx);
   for (my $y=0; $y<$grid; $y++) {
      for (my $x=0; $x<$grid; $x++) {
         print Template("rect", Ctx($x, $y)) unless ($grid - $y > $x + 1);
      }
   }
   print Template("bottom");
}

sub Ctx {
   my ($x, $y) = @_;

   if (defined $x) {
      $CTX{x} = $x * ($CTX{w} + $CTX{g});
      $CTX{y} = $y * ($CTX{w} + $CTX{g});
      return %CTX;
   }
   my $size   = ArgGet("size"  ) || 50;
   my $grid   = ArgGet("grid"  ) ||  4;
   my $radius = ArgGet("radius") || 22;
   my $gap    = ArgGet("gap"   ) || 17;
   my $color  = ArgGet("color" ) || "#468bc9";
   my $w      = $size / ($grid + ($grid-1.0)*0.01*$gap);
   my $r      = $w * $radius * 0.01;
   my $g      = ($size - $grid * $w) / ($grid-1.0);
   my $scale  = 4 - log10($size);

   return %CTX = (
      size   => $size,
      grid   => $grid, 
      color  => $color,
      radius => round($radius, $scale),
      gap    => round($gap   , $scale),
      w      => round($w     , $scale),
      r      => round($r     , $scale),
      g      => round($g     , $scale)
   );
}

sub round {
   my ($num, $scale) = @_;
   return $num unless $scale > 0;
   my $n = 10 ** $scale;   
   return floor($num * $n) / $n;
}

#############################################################################
#                                                                           #
#############################################################################

__DATA__
[top]
<!DOCTYPE html>
<html>
<head>
</head>
<body>
   <div class="logo">
      <svg width="$size" height="$size">
[rect]
         <rect x="$x" y="$y" width="$w" height="$w" rx="$r" ry="$r" style="fill:$color" />
[bottom]
      </svg>
   </div>
</body>
</html>
[usage]
GenHSLogo  - Generate a SVG version of the helpsteps logo

USAGE: perl GenHSLogo.pl [options]

WHERE: [options] are one or more of:
   -size=50 ........ X and Y size of icon
   -grid=4 ......... blocks per row/column
   -radius=22 ...... rounding (in %) of block corners
   -gap=17 ......... space (in %) between blocks
   -color=#468bc9 .. block color

EXAMPLES:
   perl GenHSLogo.pl -s=100
   perl GenHSLogo.pl -size=100 -gap=40 -radius=45 -color=#e36
   perl GenHSLogo.pl -s=500 -grid=8 -c=violet > logo8.html