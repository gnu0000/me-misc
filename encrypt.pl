#!perl
#
# Craig Fitzgerald

use warnings;
use strict;
use Compress::Zlib;
use Crypt::RC4;
use MIME::Base64;
use Gnu::ArgParse;
use Gnu::FileUtil  qw(SlurpFile SpillFile);
use Gnu::Template  qw(Usage);

my $SALT = "This is n0t salt";

my %ACTIONS = (
   encrypt=> [\&EncryptFile, "enc" , "Encrypting", 1],
   decrypt=> [\&DecryptFile, "dec" , "Decrypting", 1],
   gzip   => [\&GzipFile   , "gz"  , "Gzipping"  , 0],
   ungzip => [\&UngzipFile , "ungz", "UnGzipping", 0],
   rc4    => [\&Rc4File    , "rc4" , "Rc4ing"    , 1]);

MAIN:
   ArgBuild("*^encrypt *^decrypt *^overwrite *^gzip *^ungzip *^rc4 *^debug *^help *^password=");
   ArgParse(@ARGV) or die ArgGetError();
   Usage () if ArgIs("help") || !ArgGet();
   DoIt();


sub DoIt
   {
   my ($fn, $ext, $label, $reqpassword) = Action();
   my $inspec   = ArgGet();
   my $outspec  = MakeOutspec($ext);
   my $password = ArgGet("password");

   Abort(1, "$label requires a password.") if $reqpassword && !$password;
   Abort(1, "'$outspec' exists."         ) if !ArgIs("overwrite") && -f $outspec;

   print "$label $inspec to $outspec.\n";
   my $data = SlurpFile($inspec, 1) or Abort("Cant read '$inspec'");
   $data = $fn->($data, $password);
   SpillFile($outspec, $data, 1);
   print "Done.\n";
   }

sub EncryptFile
   {
   my ($data, $password) = @_;
   return RC4($password ^ $SALT, Compress::Zlib::memGzip($data));
   }

sub DecryptFile
   {
   my ($data, $password) = @_;
   return Compress::Zlib::memGunzip(RC4($password ^ $SALT, $data));
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
   return RC4($password ^ $SALT, $data);
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

sub MakeOutspec
   {
   my ($action) = @_;

   my $genspec = ArgIs() < 2;
   my $outspec = $genspec ? ArgGet() : ArgGet(undef, 1);

   return $outspec unless $genspec;

   my ($base, $ext) = $outspec =~ /^(.*)(\.[^.]*)$/;
   ($base, $ext) = ($outspec, "") unless $base;

    return $base if 
      $action =~ /dec/  && $ext =~ /\.enc/i ||
      $action =~ /ungz/ && $ext =~ /\.gz/i  ||
      $action =~ /rc4/  && $ext =~ /\.rc4/i ;

   return $outspec .".". $action;
   }

__DATA__

[usage]
encrypt.pl - Encrypt/Decrypt file

Usage: encrypt.pl [options] infile outfile

Where: options is zero or more of:
   -password=str . crypto passphrase
   <none>   ...... rc4 encrypt/decrypt infile to outfile
   -encrypt ...... gzip, then rc4 encrypt infile to outfile
   -decrypt ...... rc4 decrypt, then ungzip infile to outfile
   -overwrite .... overwrite outfile if it exists
   -gzip ......... gzip infile to outfile
   -ungzip ....... ungzip infile to outfile

Examples
   encrypt.pl -encrypt -password="foo fighters" mydoc.dat mydoc.enc
   encrypt.pl -enc -pass="foo fighters" mydoc.dat
   encrypt.pl -decrypt -password="foo fighters" mydoc.enc mydoc.dat2
   encrypt.pl -gzip mydoc.dat
   encrypt.pl -ungzip mydoc.dat.gz
   encrypt.pl -enc -o -pass=abcde mydoc.dat

outfile defaults to infile with extension changed (based on options)
to: .rc4 if no options, .enc if encrypt
