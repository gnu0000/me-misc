#!/usr/bin/perl 
#
#
# breakup files in a big dir
#

use 5.12.0;

use warnings;
use strict;
use Cwd qw/getcwd/;

my $BLOCK_SIZE = 65536;

$| = 1;

my $IPOD_INDEX = 37;

MAIN:
   my $startdir = $ARGV[0];
   die "need a param\n" unless $startdir;
   print "\nscanning $startdir";
   my $files = gather ($startdir);
   print "\nsorting...\n";
   my @filz = sort{$a->{name} cmp $b->{name}} @{$files};
   my $filecount = scalar @filz;
   print "$filecount files\n";

   my $folderz = partition(\@filz, $startdir);
   my $foldercount = scalar keys %{$folderz};
   print "$foldercount folders\n";

   my $ct=0;
   foreach my $dir (sort keys %{$folderz})
      {
      print "$dir : " . scalar @{$folderz->{$dir}} . "\n";

      next if scalar scalar @{$folderz->{$dir}} < 3;

      foreach my $file (sort @{$folderz->{$dir}})
         {
#         print "   $file->{name}\n";
         
         my $sub  = "$startdir/$dir";
         my $spec = "$sub/$file->{name}";
         print "  mkdir \"$sub\"\n" unless -d $sub;
         print "  mv \"$file->{spec}\" \"$spec\"\n";
         system("mkdir \"$sub\"") unless -d $sub;
         system("mv \"$file->{spec}\" \"$spec\"");
         }
#      last if $ct++ > 2;      

      }
   exit(0);


sub gather 
   {
   my ($dir, $files) = @_;

   print ".";
   opendir(my $dh, $dir);
   my @all = readdir($dh);
   closedir($dh);
   foreach my $file (@all)
      {
      my $spec = "$dir/$file";
      next unless -f $spec;
      next if $spec =~ /(\.lst)|(\.btm)|(\.txt)|(\.bak)$/i;
      my $size = (stat($spec))[7];
      push @{$files}, {name=>$file, dir=>$dir, spec=>$spec, size=>$size};
      }
#   foreach my $file (@all)
#      {
#      next if $file =~ /^\./;
#      my $subdir = "$dir/$file";
#
#      $files = gather($subdir, $files) if -d $subdir;
#      }
   return $files;
   }


sub partition
   {
   my ($filz, $dir) = @_;
  
   my $dirz = {};
   foreach my $file (@{$filz})
      {
      my ($prefix) = $file->{name} =~ /^([^\^]*)_.*$/;

      if (!$prefix)
         {
         ($prefix) = $file->{name} =~ /^(.{5}).*$/;
         }
      $prefix = "img" if $file->{name} =~ /^img.*$/i;

      $prefix ||= "none";
      push @{$dirz->{$prefix}}, $file;
      }
   return $dirz;
   }


sub set_spec
   {
   my ($file) = @_;

   $file->{newspec} = $file->{dir} . "/" . $file->{newname};
   }
 

