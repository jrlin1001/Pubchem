use warnings;
use strict;

my $dir =".";


opendir DH, $dir;
foreach my $file (readdir DH){
  if ($file =~ /\.csv/){
    print "$file\n";
  }
}
closedir DH;

