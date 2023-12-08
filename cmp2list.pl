#!perl
use warnings;
use strict;
use File::Slurp;
use Gnu::ArgParse;
use Gnu::DebugUtil qw(DumpHash DumpRef);

MAIN:
   $| = 1;
   ArgBuild("*^help ?");

   ArgParse(@ARGV) or die ArgGetError();
   Usage() if ArgIs("help") || ArgIs() < 2;
   FindMatches(ArgGetAll(undef));
   print "Done.";
   exit(0);


sub FindMatches {
   my ($listfile, $dir) = @_;

   my @lines = read_file($listfile, chomp => 1);
   my %filemap = map{$_ => 1} @lines;

   #foreach my $key (keys %filemap) {print "listline: $key\n"}   

   my @files = grep{-f $_} glob($dir);

   #foreach my $file (@files) {print "file: $file\n" if $filemap{$file}}   

   foreach my $file (@files) {
      print "$file\n" if $filemap{$file}
   }
}
__DATA__

[usage]
cmp2list.pl  -  Look for files in a directory that are also in a list file

USAGE: cmp2list.pl [options] list.txt dir\*

todo...
[fini]
