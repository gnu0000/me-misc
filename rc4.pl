#!perl
#
# Craig Fitzgerald

use lib 'c:\util\bin\perl\lib';
use warnings;
use strict;
use Compress::Zlib;
use Crypt::RC4;
use Gnu::ArgParse;
use Gnu::FileUtil  qw(SlurpFile SpillFile);


my %ACTIONS = (
   encrypt=> [\&EncryptFile, "enc", "Encrypting", 1],
   decrypt=> [\&DecryptFile, "dec", "Decrypting", 1],
   gzip   => [\&GzipFile   , "gz" , "Gzipping"  , 0],
   ungzip => [\&UngzipFile , "out", "UnGzipping", 0],
   0      => [\&Rc4File    , "rc4", "Rc4ing"    , 1]);

MAIN:
   ArgBuild("*^encrypt *^decrypt *^overwrite *^gzip *^ungzip *^debug *^help *^password=");
   ArgParse(@ARGV) or die ArgGetError();
   Usage () if ArgIs("help") || !ArgGet();
   DoIt();


sub DoIt
   {
   my ($fn, $ext, $label, $reqpassword) = Action();
   my $inspec   = ArgGet();
   my $outspec  = ArgGet(undef,1) || $inspec . ".$ext";
   my $password = ArgGet("password") || "";

   Abort(1, "$label requires a password.")  if $reqpassword && !$password;
   Abort(1, "$outspec' exists."          )  if !ArgIs("overwrite") && -f $outspec;

   print "$label $inspec to $outspec.\n";
   my $data = SlurpFile($inspec, 1) or Abort("Cant read '$inspec'");
   $data = $fn->($data, $password);
   SpillFile($outspec, $data, 1);
   print "Done.\n";
   }


sub EncryptFile
   {
   my ($data, $password) = @_;
   return RC4($password, Compress::Zlib::memGzip($data));
   }

sub DecryptFile
   {
   my ($data, $password) = @_;
   return Compress::Zlib::memGunzip(RC4($password, $data));
   }

sub GzipFile   
   {
   my ($data) = @_;
   return Compress::Zlib::memGzip($data);
   }

sub UngzipFile    
   {
   my ($data) = @_;
   return Compress::Zlib::memGunzip($data);
   }

sub Rc4File       
   {
   my ($data, $password) = @_;
   return RC4($password, $data);
   }

sub Action
   {
   map{return @{$ACTIONS{$_}} if $_ && ArgIs($_)} keys %ACTIONS;
   return @{$ACTIONS{0}};
   }

sub Abort
   {
   my ($exitcode, $msg) = @_;

   print "\n$msg\n";
   exit($exitcode);
   }


#sub GetOutSpec
#   {
#   my ($inspec, $ext, $over) = @_;
#
#   my $outspec = $inspec . ".$ext";
#   return $outspec if $over
#
#   foreach my $i (0..20)
#      {
#      my $outspec = $inspec . ".$ext" . ($i ? ".$i" : "");
#      return $outspec unless -f $outspec;
#      }
#   return
#   }



#sub Encrypt
#   {
#   my ($name, $data) = @_;
#
#   my $password = Context("password");
#   return $data unless $password;
#   $data = Compress::Zlib::memGzip($data);
#   return RC4($name . $password, $data);
#   }
#
#
#sub Decrypt
#   {
#   my ($name, $data) = @_;
#
#   my $password = Context("password");
#   return $data unless $password;
#
#   $data = RC4($name . $password, $data);
#   return  Compress::Zlib::memGunzip($data);
#   }




sub Usage
   {
   print while <DATA>;
   exit (0);
   }

__DATA__

Rc4.pl - Encrypt/Decrypt file

Usage: Rc4.pl [options] infile outfile

Where: options is zero or more of:
   -password=str . crypto passphrase
   <none>   ...... rc4 encrypt/decrypt infile to outfile
   -encrypt ...... gzip, then rc4 encrypt infile to outfile
   -decrypt ...... rc4 decrypt, then ungzip infile to outfile
   -overwrite .... overwrite outfile if it exists
   -gzip ......... gzip infile to outfile
   -ungzip ....... ungzip infile to outfile

Examples
   Rc4.pl -encrypt -password="foo fighters" mydoc.dat mydoc.enc
   Rc4.pl -decrypt -password="foo fighters" mydoc.enc mydoc.dat2
   Rc4.pl -gzip mydoc.dat mydoc.dat.gz
   Rc4.pl -ungzip mydoc.dat.gz mydoc.dat3
   Rc4.pl -enc -o -pass=abcde mydoc.dat

outfile defaults to infile with extension changed (based on options)
to: .rc4 if no options, .enc if encrypt, .dec if decrypt
