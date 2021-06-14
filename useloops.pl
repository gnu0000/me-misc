use warnings;
use strict;
use Gnu::ArgParse;
use Gnu::FileUtil qw(SlurpFile SpillFile);

my $FILES = {};
my $USEMAP = {};


MAIN:
   $| = 1;
   ArgBuild("*^info *^debug");
   ArgParse(@ARGV) or die ArgGetError();
   Check();
   exit(0);


sub Check
   {
   my $count = 0;
   for (my $i=0; $i<ArgIs(); $i++)
      {
      map {$count += LoadFile($_)} (glob(ArgGet(undef, $i)));
      }
   Trace();
   }


sub LoadFile
   {
   my ($filename) = @_;

   $FILES->{$filename} = SlurpFile($filename);

   my $data = SlurpFile($filename);
   my ($module, @uses) = Scan($data);

   if (ArgIs("info"))
      {
      print "Module: $module\n";
      map {print "   uses: $_\n"} @uses;
      print "\n";
      }
   $USEMAP->{$module} = {};
   map {$USEMAP->{$module}->{$_} = $_} @uses;

   return 1;
   }

sub Scan
   {
   my ($data) = @_;

   my @uses = ();
   my $module = "";

   foreach my $line (split /^/, $data) 
      {
      chomp $line;
      $module = $1 if $line =~ /^package Vplay::(.*);\s*$/;
      push (@uses, $1) if $line =~ /^use Vplay::(\w+) /;
      }
   return ($module, @uses);
   }

sub Trace
   {
   print "'use' circular dependencies:\n";
   foreach my $key (sort keys %{$USEMAP})
      {
      ClearMarks();
      _Trace($key, $key, ());
      }
   }

sub  _Trace
   {
   my ($start, $key, @path) = @_;

   return PrintPath(@path, $key) if $start eq $key && defined $USEMAP->{$key}->{"*"};
   return if defined $USEMAP->{$key}->{"*"};

   $USEMAP->{$key}->{"*"} = 1;
   push(@path, $key);

   map {_Trace($start, $_, @path)} (keys %{$USEMAP->{$key}});
   }

sub PrintPath
   {
   my (@path) = @_;
   print "   " , join(" => ", @path), "\n";
   }

sub ClearMarks
   {
   map {delete $USEMAP->{$_}->{"*"} if defined $USEMAP->{$_}->{"*"}} keys (%{$USEMAP});
   }
