
MAIN:
   Show(8              );
   Show(88             );
   Show(888            );
   Show(1024           );
   Show(8888           );
   Show(88888          );
   Show(888888         );
   Show(1048500        );
   Show(1048576        );
   Show(8888888        );
   Show(88888888       );
   Show(888888888      );
   Show(8888888888     );
   Show(88888888888    );
   Show(888888888888   );
   Show(8888888888888  );
   Show(88888888888888 );
   Show(888888888888888);
   Show(8888888888888888);

sub Show
   {
   my ($size) = @_;


   printf " long: $size => " . SizeString($size) . "\n";
   printf "short: $size => " . SizeString($size, 1) . "\n";
   }



sub SizeString
   {
   my ($size, $short) = @_;

   $short ||= 0;
   my $scale = "B";

   ($scale = "KB", $size /= 1024) if $size >= 1024;
   ($scale = "MB", $size /= 1024) if $size >= 1024;
   ($scale = "GB", $size /= 1024) if $size >= 1024;
   ($scale = "TB", $size /= 1024) if $size >= 1024;

   return sprintf("%04d%s", $size, lc $scale) if $short;
   return sprintf("%04d B", $size) if $scale eq "B";
   return sprintf("%07.2f %s", $size, $scale);
   }
