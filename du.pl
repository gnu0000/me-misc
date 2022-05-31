#!perl
#
# du.pl  -  Traverses dirs, Counts size of files
# Craig Fitzgerald

use warnings;
use strict;
use File::Basename;
use lib dirname(__FILE__);
use lib dirname(__FILE__) . "/lib";
use Gnu::ArgParse;
use Gnu::MiscUtil qw(SizeString);
use Gnu::FileUtil qw(SlurpFile SpillFile);
use Gnu::Template qw(Template Usage);

my %COUNTS = (size=>0, dirs=>0, files=>0, matches=>0);
my (%TYPES, %IGNORE);


MAIN:
   $| = 1;
   ArgBuild("*^type= *^ignore= *^help *^showdirs *^showfiles ?");
   ArgParse(@ARGV) or die ArgGetError();
   Usage() if ArgIsAny("help", "?") || !ArgIs("");

   %TYPES  = InitialTypes();
   %IGNORE = InitIgnoreList();
   ProcessDir(ArgGet());
   Report();
   exit(0);


sub InitialTypes {
   return (all => 1) unless ArgIs("type");
   return map{$_ => 1} ArgGetAll("type");
}


sub InitIgnoreList {
   return ((".." => 1, "." => 1), map{$_ => 1} ArgGetAll("ignore"));
}


sub ProcessDir {
   my ($dir) = @_;

   $COUNTS{dirs}++;
   printf "processing dir: $dir\n" if ArgIs("showdirs");

   opendir(my $dh, $dir) or die "cant open dir '$dir'!";
   my @all = readdir($dh);
   closedir($dh);

   foreach my $entry (@all) {
      my $spec = "$dir\\$entry";
      ProcessDir($spec) if -d $spec && !$IGNORE{$entry};
      ProcessFile($spec) if -f $spec;
   }
}


sub ProcessFile {
   my ($spec) = @_;

   $COUNTS{files}++;
   printf "processing file: $spec\n" if ArgIs("showfiles");

   my ($ext) = $spec =~ /\.(\w+)$/;
   $ext = defined $ext ? $ext : "none";
   return unless $TYPES{$ext} || $TYPES{all};

   $COUNTS{matches}++;
   $COUNTS{size} += -s $spec;
}


# 21.20 GB (2222,242,234,234) in 5,321 files, 43 dirs
sub Report {
   my $ss = SizeString($COUNTS{size});
   my $nf = NumberFormat($COUNTS{size});
   my $ct = $COUNTS{matches} != $COUNTS{files} ? "$COUNTS{matches} of $COUNTS{files}" : "$COUNTS{matches}";
   printf "$ss ($nf) in $ct files, $COUNTS{dirs} dirs\n";
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
du.pl  -  Recursively count source code lines in a directory tree.

USAGE: du.pl [options] dir

WHERE: [options] is 0 or more of:
   -type=type .... Show size of files with this file extension.
   -ignore=dir ... Ignore files in this subtree.
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