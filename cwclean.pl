#!perl
#
# kill extra copies of codewright
#

use warnings;
use strict;
use Win32::Process;
use Win32::Process::Info;

MAIN:
   Go();

sub Go
   {
   print "killing hung codewright processes...\n";

   my $pi = Win32::Process::Info->new ();
   my @info = grep {$_->{Name} =~ m/CW32/} $pi->GetProcInfo ();
   my $ex = 0;

   map{Win32::Process::KillProcess($_->{ProcessId}, $ex) if ($_->{ThreadCount} == 1)} @info;
   }

