##      putcell02.pl
##     
## assign the cell line into PubChem bioassay record
##

use warnings;
use strict;

my %cellhash;

## read the cell-line reference file
open CELL,"<cellline02.tsv";
while(my $line=<CELL>){
  chomp $line;
  $line=uc $line;
  my @col = split "\t",$line;
  if($col[0]){$cellhash{$col[0]}=$col[1];}
}
close CELL;

my $infile="input.tsv";
if($ARGV[0]){$infile = $ARGV[0];}
open INPUT,"<$infile";

my $outfile="output.tsv";
if($ARGV[1]){$outfile = $ARGV[1];}
open OUTPUT,">$outfile";

my $line = <INPUT>;                 #read & print title;
chomp $line;
$line = "$line\tCelltype\n";

print OUTPUT $line;

while($line = <INPUT>){
  chomp $line;
  my @col = split "\t",$line;
  my $cellname="";

  unless($col[16]){$col[16]="";}
  unless($col[17]){$col[17]="";}

  if($col[14]){
    my $test = uc $col[14];
    my @assay = split " ",$test;

    if($test=~m/(KILLING|ANTITUMOR|ANTICANCER|ANTIPROLIFERATIVE|PROLIFERATION|ARREST|VIABILITY|CYTOSTATIC|CYTOTOXIC|TOXICITY|GROWTH)/){
      for(my $i=0; $i<@assay;$i++){
        my $test1 = $assay[$i];
        if($cellhash{$test1}){$cellname = $cellhash{$test1};}
        ## bi-words processing
        if($i<@assay-1){
           my $test2 = $assay[$i].'-'.$assay[$i+1];
           my $test3 = $assay[$i].$assay[$i+1];
           if($cellhash{$test2}){$cellname = $cellhash{$test2};}
           if($cellhash{$test3}){$cellname = $cellhash{$test3};}
        }#endif($i<@assay-1)
      }#end for

    }#end if($test1)
  }#end if($col[14])
  foreach(@col){print OUTPUT "$_\t";}
  print OUTPUT "$cellname\n";
}#end while

close INPUT;
close OUTPUT;
