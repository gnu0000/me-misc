#!c:/Perl/bin/perl.exe
#
#  AddBatch
#

use strict;
use File::Basename;
use File::Spec;

my $TEMPNANE = "AddBatch.tbe";

MAIN:
   Usage() if (@ARGV < 2 || @ARGV > 3);

   my ($ListFile, $SrcFileName, $DestFileName) = @ARGV;

   $SrcFileName = File::Spec->rel2abs ($SrcFileName);
   if (!$DestFileName)
      {
      my ($Name, $Dir, $Ext) = fileparse ($SrcFileName, qr{\..*});
      $DestFileName = $Dir . "_" . $Name . ".mpg";
      }
   $DestFileName = File::Spec->rel2abs ($DestFileName);

   exit printf "  Error: List File $ListFile does not have a .tbe extension!\n" unless $ListFile =~ m/\.tbe/i;
   exit printf "  Error: file $ListFile does not exist!\n" unless -e $ListFile;
   exit printf "  Error: file $SrcFileName does not exist!\n" unless -e $SrcFileName;

   my ($InFile, $OutFile);
   open ($InFile,  "<$ListFile")   || die "Cannot open $ListFile!";
   open ($OutFile, ">$TEMPNANE") || die "Cannot open $TEMPNANE!";

   my $Depth = 0;
   my @Template = "";
   while (my $Line = <$InFile>)
      {
      if ($Line =~ m/^\s*item\s*$/) # EO worries ?
         {
         @Template = () if (!$Depth);
         $Depth++;
         }
      if ($Line =~ m/^\s*end>?\s*$/) # EO worries ?
         {
         $Depth--;
         if (!$Depth && $Line =~ m/end>/)
            {
            printf "Adding to $ListFile: $SrcFileName => $DestFileName\n";
            die "Never loaded a template!" if !@Template;
            print $OutFile "    end\n";
            while (my $TemplateLine = shift @Template)
               {
               $TemplateLine =~ s/^(.+\.SourceFileName = ')([^'].*)('\s*)$/$1$SrcFileName$3/;
               $TemplateLine =~ s/^(.*Job.OutputFileName = ')([^'].*)('\s*)$/$1$DestFileName$3/;
               print $OutFile $TemplateLine;
               }
            }
         }
      push @Template, $Line if $Depth;
      print $OutFile $Line;
      }
   close $InFile, 
   close $OutFile;

   unlink $ListFile;
   rename $TEMPNANE, $ListFile;

   print "Done.\n";
   exit (0);


sub Usage
   {
   print<<USAGETEXT
AddBatch    Add encode jobs to an TMPGEnc Batch List file    v1.0  

USAGE:   Perl AddBatch  [TMPGEncListFile]  [inputfile] [outputfile]

WHERE:   [TMPGEncListFile] - A text based batch list file from TMPGEnc.  
                              (Make sure to save the initial batch list 
                              in 'text format').
         [inputfile]       - The source file to encode.
         [outputfile]      - Optional, the output file.  by default, the 
                              [inputfile] with an '_' prepended is used.

DESCRIPTION: 
   This program is used to simplify the process ot converting many files
   with TMPGEnc when all of the files need the same conversion.  To use:
    1. Create a batch job in TMPGEnc with at least 1 file to be proccessed.
    2. Save the Batch List using type 'Batch Encode list-text format'
    3. Run this program with the batch list and the file to add to the list.
   The program uses the settings for the LAST job in the list for the newly
   added job.  Call this program from a batch file or a command-line for 
   loop to add several jobs at once.

Example: Perl AddBatch  Batchlst.tbe YoYo.avi
USAGETEXT
   ;
   exit (0);
   }