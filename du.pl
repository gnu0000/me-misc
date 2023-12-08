#!perl
#
# du.pl  -  Traverses dirs, Counts size of files
# Craig Fitzgerald

use warnings;
use strict;
use feature 'state';
use File::Basename;
use lib dirname(__FILE__);
use lib dirname(__FILE__) . "/lib";
use List::Util    qw(max min);
use Gnu::ArgParse;
use Gnu::MiscUtil qw(SizeString);
use Gnu::FileUtil qw(SlurpFile SpillFile);
use Gnu::Template qw(Template Usage);

my (%TYPES, %IGNORE);
my $DIRLEN = 16;


MAIN:
   $| = 1;
   ArgBuild("*^type= *^ignore= *^each *^showdirs *^showfiles ^os ^oc *^help ?");
   ArgParse(@ARGV) or die ArgGetError();
   Usage() if ArgIsAny("help", "?") || !ArgIs("");

   %TYPES  = InitialTypes();
   %IGNORE = InitIgnoreList();
   ProcessTopDir(ArgGet());
   exit(0);


sub InitialTypes {
   return (all => 1) unless ArgIs("type");
   return map{$_ => 1} ArgGetAll("type");
}


sub InitIgnoreList {
   return ((".." => 1, "." => 1), map{$_ => 1} ArgGetAll("ignore"));
}


sub ProcessTopDir {
   my ($dir) = @_;

   opendir(my $dh, $dir) or die "cant open dir '$dir'!";
   my @all = grep {-d "$dir\\$_" && !$IGNORE{$_}} readdir($dh);
   closedir($dh);

   my $dirlen = 0;
   map{$dirlen = max($dirlen, length $_)} @all;
   $DIRLEN = $dirlen;

   map{ProcessDir("$dir\\$_")} @all;
   Report($dir);
}


sub ProcessDir {
   my ($dir) = @_;

   my $counts = {size=>0, dirs=>0, files=>0, matches=>0};
   ExamineDir($dir, $counts);
   Report($dir, $counts);
}


sub ExamineDir {
   my ($dir, $counts) = @_;

   $counts->{dirs}++;
   printf "examining dir: $dir\n" if ArgIs("showdirs");

   opendir(my $dh, $dir) or die "can't open dir '$dir'!";
   my @all = readdir($dh);
   closedir($dh);

   foreach my $entry (@all) {
      my $spec = "$dir\\$entry";
      ExamineDir($spec, $counts) if -d $spec && !$IGNORE{$entry};
      ExamineFile($spec, $counts) if -f $spec;
   }
}


sub ExamineFile {
   my ($spec, $counts) = @_;

   $counts->{files}++;
   printf "examining file: $spec\n" if ArgIs("showfiles");

   my ($ext) = $spec =~ /\.(\w+)$/;
   $ext = defined $ext ? $ext : "none";
   return unless $TYPES{$ext} || $TYPES{all};

   $counts->{matches}++;
   $counts->{size} += -s $spec;
}


# 21.20 GB (2222,242,234,234) in 5,321 files, 43 dirs
sub Report {
   my ($dir, $counts) = @_;

   state $totals = {size=>0, dirs=>0, files=>0, matches=>0};
   state $lines  = [];

   my $ordered = ArgIsAny("os", "oc"); # wait until we get the full list

   if (!$counts && $ordered) {
      my $key = ArgIs("os") ? "size" : "matches";
      my @sortedLines = sort {$a->{$key} <=> $b->{$key}} @{$lines};
      map {print $_->{line}} @sortedLines;
   }
   if (!$counts) {
      print "------\n" if ArgIs("each") || $ordered;
      print ReportLine($dir, $totals);
      return;
   }

   my $line = ReportLine($dir, $counts);
   push(@{$lines}, {size=>$counts->{size}, matches=>$counts->{matches}, dir=>$dir, line=>$line});
   map {$totals->{$_} += $counts->{$_}} (qw(size dirs files matches));

   print $line unless $ordered || !ArgIs("each");
}


sub ReportLine {
   my ($dir, $counts) = @_;

   my ($nm) = $dir =~ /([^\\]+)$/;
   my $ss = SizeString($counts->{size});
   my $nf = NumberFormat($counts->{size});
   my $ct = ArgIs("type") ? sprintf ("%4d of %4d", $counts->{matches}, $counts->{files}) : sprintf ("%4d", $counts->{matches});
   return sprintf ("%-*s: %-*s (%*s) $ct files,%*d dirs\n", $DIRLEN, $nm, 10, $ss, 15, $nf, 4, $counts->{dirs});
}


# Don't ya just love perl ?
#
sub NumberFormat
   {
   my ($number) = @_;

   1 while $number =~ s/^(-?[\d]+)(\d\d\d)/$1,$2/;
   $number;
   }


__DATA__

[usage]
du.pl  -  Recursively count the total size of files of a particular type

USAGE: du.pl [options] dir

WHERE: [options] is 0 or more of:
   -type=type .... Show size of files with this file extension.
   -ignore=dir ... Ignore files in this subtree.
   -each ......... Show sizes for each top level dir.
   -showfiles .... Show dirs being examined.
   -showdirs ..... Show files being examined.
   -os ........... for -each option, list dirs by total size
   -oc ........... for -each option, list dirs by file count
   -help ......... Show this help.

   If no types are specified, all files are included. The type option
     may be used multiple times.
   The ignore option may be used multiple times.

EXAMPLES:
   du.pl .
   du.pl .\projdir
   du.pl -type=cpp projdir
   du.pl -type="pl" -ignore=bkup c:\stuff\projdir
   du.pl -t=js -t=ts -t=html -i=.git -i=bkup -i=old projdir
[fini]