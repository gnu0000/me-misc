#!perl
use warnings;
use strict;
use POSIX          qw(strftime);
use List::Util     qw(max min);
use Gnu::Template  qw(Template Usage);
use Gnu::ArgParse;
use Gnu::DebugUtil qw(DumpHash DumpRef);

MAIN:
   $| = 1;
   ArgBuild("*^help *^split *^size *^diffs ?");

   ArgParse(@ARGV) or die ArgGetError();
   Usage() if ArgIs("help") || ArgIs() < 2;
   CompareDirs(ArgGetAll(undef));
   print "Done.";
   exit(0);


sub CompareDirs
   {
   my ($dir1, $dir2) = @_;

   my $files1 = GetFileList($dir1, "A");
   my $files2 = GetFileList($dir2, "B");
   my $catalog = Combine($files1, $files2);

   my $namelen = max(map{length $_} keys %{$catalog});
   map{$catalog->{$_}->{namelen} = $namelen} (keys %{$catalog});
   map{CalcState($catalog->{$_})} (keys %{$catalog});
   ShowEntries($catalog);
#   map{ShowEntry($_, $catalog->{$_})} (sort keys %{$catalog});
   }

# $catalog->{$name}->{A}->{set,name,etc...}
sub Combine
   {
   my ($files1, $files2) = @_;

   my $catalog = {};
   foreach my $file (@{$files1}, @{$files2})
      {
      my $name = $file->{name};
      $catalog->{$name} = {} unless exists $catalog->{$name};
      $catalog->{$name}->{$file->{set}} = $file;
      }
   #return [sort {$a->{name} cmp $b->{name}} @{$catalog}];
   return $catalog;
   }

sub CalcState
   {
   my ($entry) = @_;

   my $siz = ArgIs("size");

   $entry->{state} =
      !exists $entry->{B}                                  ? "A"  :
      !exists $entry->{A}                                  ? "B"  :
      !$siz && $entry->{A}->{mtime} > $entry->{B}->{mtime} ? ">"  :
      !$siz && $entry->{A}->{mtime} < $entry->{B}->{mtime} ? "<"  :
      $siz && $entry->{A}->{size} > $entry->{B}->{size}    ? ">>" :
      $siz && $entry->{A}->{size} < $entry->{B}->{size}    ? "<<" :
                                                             "="  ;
   }

sub ShowEntries
   {
   my ($catalog) = @_;

   return map{ShowEntry($_, $catalog->{$_})} (sort keys %{$catalog}) unless ArgIs("split");

   my @keys = sort keys %{$catalog};
   map{ShowEntry($_, $catalog->{$_}, "=" )} @keys;
   map{ShowEntry($_, $catalog->{$_}, ">" )} @keys;
   map{ShowEntry($_, $catalog->{$_}, "<" )} @keys;
   map{ShowEntry($_, $catalog->{$_}, ">>")} @keys;
   map{ShowEntry($_, $catalog->{$_}, "<<")} @keys;
   map{ShowEntry($_, $catalog->{$_}, "A" )} @keys;
   map{ShowEntry($_, $catalog->{$_}, "B" )} @keys;
   }

sub ShowEntry
   {
   my ($name, $entry, $teststate) = @_;

   my $state = $entry->{state};
   return if $teststate && ($teststate ne $state);
   return if ArgIs("diffs") && $state eq "=";
   print "$name " . "." x ($entry->{namelen} - (length $name) + 3) . " ";

   return Print1($entry, "A", "1st dir only") if $state eq "A";
   return Print1($entry, "B", "2nd dir only") if $state eq "B";
   return Print2($entry, "1st is newer")      if $state eq ">";
   return Print2($entry, "2nd is newer")      if $state eq "<";
   return Print2($entry, "1st is bigger")     if $state eq ">>";
   return Print2($entry, "2nd is bigger")     if $state eq "<<";

   return print "OK\n";
   }

sub Print1
   {
   my ($entry, $set, $msg) = @_;

   my $size = sprintf("%07.7d", $entry->{$set}->{size});
   print "$msg [$size] ($entry->{$set}->{date})\n";
   }

sub Print2
   {
   my ($entry, $msg) = @_;

   my $asize = sprintf("%07.7d", $entry->{A}->{size});
   my $bsize = sprintf("%07.7d", $entry->{B}->{size});
   print "$msg [$asize <-> $bsize] ($entry->{A}->{date} <-> $entry->{B}->{date})\n";
   }

#sub GetFileList0
#   {
#   my ($dir, $set) = @_;
#
#   my $files;
#   opendir(my $dh, $dir) or return die("\ncannot open dir '$dir'!");
#   my @all = readdir($dh);
#   closedir($dh);
#   foreach my $file (@all)
#      {
#      my $spec = "$dir\\$file";
#      next unless -f $spec;
#
#      my ($size,$mtime) = (stat($spec))[7,9];
#      my $date          = strftime("%y/%m/%d", localtime($mtime));
#
#      push @{$files}, 
#         {
#         set   => $set  ,
#         name  => $file ,
#         dir   => $dir  ,
#         spec  => $spec ,
#         size  => $size ,
#         mtime => $mtime,
#         date  => $date ,                        @
#         used  => 0
#         }
#      }
#   #return [sort {$a->{name} cmp $b->{name}} @{$files}];
#   return $files;
#   }

sub GetFileList
   {
   my ($path, $set) = @_;

   my $files;
   my $spec = -d $path ? "$path\\*" : $path;
   my @all = grep{-f $_} glob($spec);

   foreach my $file (@all)
      {
      my ($size,$mtime) = (stat($file))[7,9];
      my $date          = strftime("%y/%m/%d", localtime($mtime));
      my ($dir, $name)  = $file =~ /^(.*\\)?([^\\\/]+)$/;
      $dir ||= "";
      push @{$files}, 
         {
         set   => $set  ,
         name  => $name ,
         dir   => $dir  ,
         spec  => $spec ,
         size  => $size ,
         mtime => $mtime,
         date  => $date ,
         used  => 0
         }
      }
   return $files;
   }

__DATA__

[usage]
cmpdir.pl  -  Compare 2 sets of files

USAGE: cmpdir.pl [options] dir1\* dir2\*

WHERE: [options] are 0 or more of:
   -size ..... Compare by size instead of date
   -split .... Order output by comparison state
   -diffs .... Only show files that do not match
   
EXAMPLES:
   cmpdir.pl dir1\*.json dir2\*.json
   cmpdir.pl -size dir1\* dir2\*
   cmpdir.pl -split * dir2\*
   cmpdir.pl -size -split dir1\* dir2\*
   cmpdir.pl -diffs dir1\* dir2\*
[fini]
