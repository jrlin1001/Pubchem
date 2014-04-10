## combine CSV files version 1.0  Jerry Lin  10/25/2013
## Take PubChem CSV files and LINCS small moleculars (CID required) and combine into single files
## Usage: perl combine1.pl [index file/CID] [output file] 

use warnings;
use strict;
use Text::CSV;

my $indexfile= "test1.csv";
if ($ARGV[0]){$indexfile=$ARGV[0];}
my $outfile = "combine.csv";
if ($ARGV[1]){$outfile=$ARGV[1];}

open FILEH,"<$indexfile";
open OUTF, ">$outfile";

my $line = <FILEH>;my @title= split "\t",$line;          ## read title;
my $csv = Text::CSV->new({ sep_char => ',' });


while(my $line = <FILEH>){
  chomp $line;
  my @field = split "\t", $line;

  my $filename = "CID_$field[4]_assaydata.csv";
  if (-e $filename) {
    open CSVF,"<$filename";
    my $line2 = <CSVF>;                        # read title of csv file

    while (my $line2 = <CSVF>){
          chomp $line2;

          my @field2;
          if ($csv->parse($line2)) {@field2 = $csv->fields();}
          if ($field2[8]){
            my $target=$field2[8];
            ##print "$target\n";
            $target =~ /gi:(\d+)/;
            $field2[8]="";
            if($1){$field2[8]=$1;}
          }
          foreach(@field){print OUTF "$_\t";}
          foreach(@field2){print OUTF "$_\t";}
          print OUTF "\n";
    }
    close CSVF;
  }
}
close FILEH;
close OUTF;

