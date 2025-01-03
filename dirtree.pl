#!perl
# Craig Fitzgerald

use warnings;
use strict;
use Gnu::ArgParse;

my $INDENT = ".  ";

MAIN:
   $| = 1;
   ArgBuild("*^help ?");
   ArgParse(@ARGV) or die ArgGetError();
   my $root = ArgGet() || ".";
   ShowDirTree(0, $root, $root);
   exit(0);


sub ShowDirTree {
   my ($level, $entry, $dir) = @_;

   $level++;
   opendir(my $dh, $dir) or die "cant open dir '$dir'!";
   my @all = readdir($dh);
   closedir($dh);

   my $ct = FileCount($dir, [@all]);
   Iprint($level, "$entry ($ct)");

   foreach my $entry (@all) {
      my $spec = "$dir\\$entry";
      next unless -d $spec;
      next if $entry =~ /^\.\.?$/;
      next if $entry =~ /^\.git(hub)?$/;
      ShowDirTree($level, $entry, $spec);
   }
}

sub FileCount {
   my ($dir, $entries) = @_;
   return scalar grep{-f "$dir\\$_"} @{$entries};
}


sub Iprint {
   my ($level, $str) = @_;
   print($INDENT x $level . $str . "\n");
}