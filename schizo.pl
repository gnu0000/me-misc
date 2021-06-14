#!perl
#
# A markov chain Toy.  
# This makes gibberish out of text
#
#  Craig Fitzgerald

use warnings;
use strict;
use List::Util qw(sum);
use Gnu::ArgParse;
use Gnu::FileUtil   qw(SlurpFile);

my $ROOT_NODE = "##root##";
my $END_NODE  = "##end##";
my $NODES = {};

MAIN:
   ArgBuild("*^debug");
   ArgParse(@ARGV) or die ArgGetError();
   exit(print "File needed as a parameter.\n") unless scalar @ARGV;

   my $filespec = ArgGet();
   my $text     = SlurpFile($filespec);
   my $chain    = MakeChain($text);
   TraverseChain($chain);
   DumpChain($chain) if ArgIs("debug");

sub MakeChain
   {
   my ($str) = @_;

   my $node = FindOrMakeNode($ROOT_NODE);
   my @words = split(" ", $str);
   map {$node = AddWord($node, $_)} @words;
   AddWord($node, "##end##");
   return FindOrMakeNode($ROOT_NODE);
   }

sub AddWord
   {
   my ($node, $word) = @_;

   my $newnode = FindOrMakeNode($word, 1);
   AddKid($node, $newnode);
   return $newnode;
   }

sub FindOrMakeNode
   {
   my ($word) = @_;

   return $NODES->{$word} if exists $NODES->{$word};
   return $NODES->{$word} = {word=>$word, kids=>{}};
   }

sub AddKid
   {
   my ($node, $newnode) = @_;

   my $kids = $node->{kids};
   my $word = $newnode->{word};
   $kids->{$word} = {kid=>$newnode, count=>0} unless exists $kids->{$word};
   $kids->{$word}->{count}++;
   }

sub TraverseChain
   {
   my ($chain) = @_;

   my $node = PickAKid($chain);
   while ($node->{word} ne $END_NODE)
      {
      print "$node->{word} ";
      $node = PickAKid($node);
      }
   print "\n";
   }

sub PickAKid
   {
   my ($node) = @_;

   my $kids  = $node->{kids};
   my $range = sum map{$kids->{$_}->{count}} keys %{$kids};
   my $pick  = int(rand($range));
   foreach my $word (keys %{$kids})
      {
      my $ref = $kids->{$word};
      $pick -= $ref->{count};
      return $ref->{kid} if $pick < 0;
      }
   }
      
sub DumpChain
   {
   foreach my $key (sort keys %{$NODES})
      {
      my $node = $NODES->{$key};

      print "'$node->{word}'\n";
      my $kids = $node->{kids};
      foreach my $word (sort keys %{$kids})
         {
         my $kid = $kids->{$word};
         print "   '$word' [$kid->{count}]\n";
         }
      }
   print "\n";
   }
  