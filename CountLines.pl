#!perl
#
# CountLines.pl  -  Traverses dirs, Counts lines of source files
# Craig Fitzgerald

use warnings;
use strict;
use File::Basename;
use lib dirname(__FILE__);
use lib dirname(__FILE__) . "/lib";
use Gnu::ArgParse;
use Gnu::FileUtil qw(SlurpFile SpillFile);
use Gnu::Template qw(Template Usage);

my @TYPES = qw(c cpp h pl pm rb cs js ts py html htm css scss json yml yaml xml xslt xsd sql bat btm cmd txt);
my %COUNTS = (dirs=>0, files=>0, matches=>0);
my (%STATS, %IGNORE);


MAIN:
   $| = 1;
   ArgBuild("*^type= *^ignore= *^all *^help *^showdirs *^showfiles ?");
   ArgParse(@ARGV) or die ArgGetError();
   Usage() if ArgIsAny("help", "?") || !ArgIs("");

   %STATS = InitialStats();
   %IGNORE = InitIgnoreList();
   ProcessDir(ArgGet());
   Report();
   exit(0);

sub InitialStats {
   return map{$_ => {files=>0, lines=>0, count=>1}} @TYPES unless ArgIs("type");
   return map{$_ => {files=>0, lines=>0, count=>1}} ArgGetAll("type");
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

   $ext = defined $ext ? $ext : "(none)";
   $STATS{$ext} ||= {files=>0, lines=>0, count=>0};
   $STATS{$ext}->{files}++;
   return unless $STATS{$ext}->{count};

   $COUNTS{matches}++;

   open (my $fh, "<", "$spec") or die "can't open $spec";
   $STATS{$ext}->{lines}++ while(my $line = <$fh>);
   close ($fh);
}

sub Report {
   my @exp = sort {$STATS{$b}->{lines} <=> $STATS{$a}->{lines}} grep{ $STATS{$_}->{count}} keys %STATS;
   my @imp = sort {$STATS{$b}->{files} <=> $STATS{$a}->{files}} grep{!$STATS{$_}->{count}} keys %STATS;

   printf "   extension  files     lines\n-------------------------------\n";
   foreach my $key (@exp) {
      printf("%12s: %5d   %7d\n", $key, $STATS{$key}->{files}, $STATS{$key}->{lines}) if $STATS{$key}->{files};
   }
   return printf "total dirs: $COUNTS{dirs}, total files: $COUNTS{matches}\n" unless ArgIs("all");
   printf("\n");

   foreach my $key (@imp) {
      printf("%12s: %5d\n", $key, $STATS{$key}->{files});
   }
   printf "total dirs: $COUNTS{dirs}, total files: $COUNTS{files}\n";
}

__DATA__

[usage]
CountLines.pl  -  Recursively count source code lines in a directory tree.

USAGE: CountLines.pl [options] dir

WHERE: [options] is 0 or more of:
   -type=type .... Show filecount & linecount with this file extension.
   -ignore=dir ... Ignore files in this subtree.
   -all .......... Show filecount for all file types.
   -help ......... Show this help.

   If no types are specified, a default type list is used. The type option
     may be used multiple times.
   The ignore option may be used multiple times.

EXAMPLES:
   CountLines.pl .\projdir
   CountLines.pl -all projdir
   CountLines.pl -type=c -type="pl" c:\stuff\projdir
   CountLines.pl -type=cpp -all -ignore=.git ..\projdir
   CountLines.pl -t=js -t=ts -t=html -i=.git -i=bkup -i=old projdir
[fini]