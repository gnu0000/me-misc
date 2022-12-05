#!perl
#
# du.pl  -  Traverses dirs, Counts size of files
# Craig Fitzgerald

use warnings;
use strict;
use File::Basename;
use lib dirname(__FILE__);
use lib dirname(__FILE__) . "/lib";
use List::Util    qw(max min);
use Gnu::ArgParse;
use Gnu::MiscUtil qw(SizeString);
use Gnu::FileUtil qw(SlurpFile SpillFile);
use Gnu::Template qw(Template Usage);

my %COUNTS = (size=>0, dirs=>0, files=>0, matches=>0);
my (%TYPES, %IGNORE);
my $DIRLEN = 16;


MAIN:
   $| = 1;
   ArgBuild("*^type= *^ignore= *^each *^showdirs *^showfiles *^help ?");
   ArgParse(@ARGV) or die ArgGetError();
   Usage() if ArgIsAny("help", "?") || !ArgIs("");

   %TYPES  = InitialTypes();
   %IGNORE = InitIgnoreList();
   ProcessEach(ArgGet()) if ArgIs("each");
   ProcessDir(ArgGet());
   exit(0);


sub InitialTypes {
   return (all => 1) unless ArgIs("type");
   return map{$_ => 1} ArgGetAll("type");
}


sub InitIgnoreList {
   return ((".." => 1, "." => 1), map{$_ => 1} ArgGetAll("ignore"));
}

sub ProcessEach {
   my ($dir) = @_;

   opendir(my $dh, $dir) or die "cant open dir '$dir'!";
   my @all = grep {-d "$dir\\$_" && !$IGNORE{$_}} readdir($dh);
   closedir($dh);

   my $dirlen = 0;
   map{$dirlen = max($dirlen, length $_)} @all;
   $DIRLEN = $dirlen;

   map{ProcessDir("$dir\\$_")} @all;
}

sub ProcessDir {
   my ($dir) = @_;

   %COUNTS = (size=>0, dirs=>0, files=>0, matches=>0);
   ExamineDir($dir);
   Report($dir);
}

sub ExamineDir {
   my ($dir) = @_;

   $COUNTS{dirs}++;
   printf "examining dir: $dir\n" if ArgIs("showdirs");

   opendir(my $dh, $dir) or die "cant open dir '$dir'!";
   my @all = readdir($dh);
   closedir($dh);

   foreach my $entry (@all) {
      my $spec = "$dir\\$entry";
      ExamineDir($spec) if -d $spec && !$IGNORE{$entry};
      ExamineFile($spec) if -f $spec;
   }
}


sub ExamineFile {
   my ($spec) = @_;

   $COUNTS{files}++;
   printf "examining file: $spec\n" if ArgIs("showfiles");

   my ($ext) = $spec =~ /\.(\w+)$/;
   $ext = defined $ext ? $ext : "none";
   return unless $TYPES{$ext} || $TYPES{all};

   $COUNTS{matches}++;
   $COUNTS{size} += -s $spec;
}


# 21.20 GB (2222,242,234,234) in 5,321 files, 43 dirs
sub Report {
   my ($dir) = @_;

   my ($nm) = $dir =~ /([^\\]+)$/;
   my $ss = SizeString($COUNTS{size});
   my $nf = NumberFormat($COUNTS{size});
   my $ct = $COUNTS{matches} != $COUNTS{files} ? "$COUNTS{matches} of $COUNTS{files}" : "$COUNTS{matches}";
   printf ("%-*s: $ss ($nf) in $ct files, $COUNTS{dirs} dirs\n", $DIRLEN, $nm);
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
   -each ......... Show sizes for each top level dir.
   -showfiles .... Show dirs being examined.
   -showdirs ..... Show files being examined.
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