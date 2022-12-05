#!perl
#

use warnings;
use strict;
use File::Basename;
use Gnu::ArgParse;
use Gnu::MiscUtil qw(SizeString);
use Gnu::FileUtil    qw(SlurpFile SpillFile NormalizeFilename);
use Gnu::Template qw(Template Usage);
use Gnu::KeyInput    qw(GetKey IsCtlKey IsFnKey IsUnprintableChar MakeKey
                        KeyMacroCallback KeyMacrosStream KeyName KeyMacroList);
use Gnu::StringInput qw(:ALL);



MAIN:
   $| = 1;
   ArgBuild("*^clean *^fix *^help*^showfiles ?");
   ArgParse(@ARGV) or die ArgGetError();
   Usage() if ArgIsAny("help", "?") || !ArgIs("");
   Usage() unless ArgIsAny("clean", "fix") || !ArgIs("");

   CleanFiles(ArgGet()) if ArgIs("clean");
   FixFiles(ArgGet()) if ArgIs("fix");
   exit(0);



#################################################
# clean

sub CleanFiles {
   my ($dir) = @_;
   my $files = GatherFiles($dir);
   map {CleanFile($_)} @{$files};
}

sub CleanFile {
   my ($file) = @_;

   my $new = Normalize($file);
   RenameFile($file, $new);
}


#################################################
# fix

sub FixFiles {
   my ($dir) = @_;

   my $files = GatherFiles($dir);
   my $info  = BuildInfo($files);
   map {FixPre($info, $_)} (sort keys %{$info});
}

sub BuildInfo {
   my ($files) = @_;

   my $data = {};
   foreach my $file (@{$files}) {
      my ($pre, $main, $ext) = FileParts($file);

      next unless $pre && $ext;
      $data->{$pre} = {} unless exists $data->{$pre};
      $data->{$pre}->{$ext} = $main;
   }
   return $data;
}


sub FixPre {
   my ($info, $prename) = @_;

   my $pre = $info->{$prename};
   my $rar = $pre->{rar};
   return "no rar for $prename\n" unless $rar;
   my $plen = length $rar;
   
   foreach my $ext (sort keys %{$pre}) {
      next if $ext eq "rar";
      my $elen = length $pre->{$ext};
      next unless $plen > $elen;
      my $file = $prename . $pre->{$ext} . "." . $ext;
      my $new = $prename . $rar . "." . $ext;

      RenameFile($file, $new);
   }
}

#################################################
# util

sub GatherFiles {
   my ($dir) = @_;

   opendir(my $dh, $dir) or die "cant open dir '$dir'!";
   my @all = grep {-f $_} readdir($dh);
   closedir($dh);
   return \@all;
}

sub RenameFile {
   my ($file, $new) = @_;

   return if $file eq $new;

   print "$file  -->  $new ";
   return print "Canceled.\n"  unless GetYesOrNo("rename?");

   return print "rename failed\n" unless rename ($file, $new);
   #print "## renaming '$file'  to  '$new' ##\n";
}

sub FileParts {
   my ($file) = @_;

   my ($pre, undef, $main, $ext) = $file =~ /^(\w+\-\d+([a-zA-Z]+)?)(.*)\.([^.]+)$/i;
#   my ($pre, $main, $ext) = $file =~ /$(\w+\-\d+)(.*)\.([^.]+)$/i;
#   my ($pre, $main) = $file =~ /$(\w+\-\d+)(.*)/i;
#   my ($pre) = $file =~ /^(\w+\-\d+)/i;
#   $pre ||= "nope";
#   $main ||= "nope";
#   $ext ||= "nope";
#
#   print "## $file doesn't parse ##\n" unless $pre && $ext;
   return ("","","") unless $pre && $ext;

   #debug
   #print "$file ==> $pre | $main | $ext\n";

   return ($pre, $main, $ext);

}

sub GetYesOrNo
   {
   my ($label) = @_;

   $label ||= "(y,n,enter,esc)";
   while(1)
      {
      print "$label\n";
      my $key = GetKey(ignore_ctl_keys=>1);
      my $vkey = $key->{vkey};

      return 1 if $vkey == 89 || $vkey == 13;
      return 0 if $vkey == 78 || $vkey == 27;
      }
   }


sub Normalize {
   my ($file) = @_;

   $file =~ s/ \(.*\)//i;
   $file =~ s/\(.*\)//i;
   my $new = NormalizeFilename($file, keep_dashes=>1, lowercase=>1, keep_underscores=>1);
   $new =~ s/,//;
   $new =~ s/&/and/;
   $new =~ s/__/_/;
   $new =~ s/'//;
   return $new;
}

__DATA__

[usage]
   todo...