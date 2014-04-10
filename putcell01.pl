##      putcell01.pl
##     
## assign the cell line into PubChem bioassay record
##

use warnings;
use strict;

my %cellhash;
my $debug = 1;

## read the cell-line reference file
open CELL,"<cellline01.tsv";
while(my $line=<CELL>){
  chomp $line;
  $line=uc $line;
  $cellhash{$line}++;
  print "$line\t";
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
    my $test1 = uc $col[14];
    my @assay = split " ",$test1;
    if($debug){print "$test1\n";}
    
    if($test1=~m/(ANTITUMOR|ANTICANCER|ANTIPROLIFERATIVE|PROLIFERATION|ARREST|VIABILITY|CYTOTOXICITY|CYTOSTATIC|CYTOTOXIC|TOXICITY)/){
      for(my $i=0; $i<@assay;$i++){
        my $test = uc $assay[$i];
        if($debug){print "[$test]";}
        if($cellhash{$test}){$cellname = $test;}
      }#end for
      if($debug){print "\n";}

    }#end if($test1)
  }#end if($col[14])
  foreach(@col){print OUTPUT "$_\t";}
  print OUTPUT "$cellname\n";
}#end while

close INPUT;
close OUTPUT;










