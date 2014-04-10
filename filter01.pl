##      putcell02.pl
##     
## assign the cell line into PubChem bioassay record
##

use warnings;
use strict;

my $infile="input.tsv";
if($ARGV[0]){$infile = $ARGV[0];}
open INPUT,"<$infile";

my $outfile1="review.tsv";
if($ARGV[1]){$outfile1 = $ARGV[1];}
open OUT1,">$outfile1";

my $outfile2="discard.tsv";
if($ARGV[2]){$outfile2 = $ARGV[2];}
open OUT2,">$outfile2";


my $line = <INPUT>;                 #read & print title;
print OUT1 $line;
print OUT2 $line;

while($line = <INPUT>){
  my $oriline= $line;
  chomp $line;
  my @col = split "\t",$line;
  my $cellname="";

  if($col[14]){
    my $test = uc $col[14];
    if($test=~m/(KILLING|ANTITUMOR|ANTICANCER|ANTIPROLIFERATIVE|PROLIFERATION|ARREST|VIABILITY|CYTOSTATIC|CYTOTOXIC|TOXICITY|GROWTH|ANTIANGIOGENIC|BACTERIAL|INFLAMMATORY|MALARIAL|MICROBIAL|PLASMODIAL|ANTIVIRAL|VIRUS|MITOCHONDRIAL|PRODUCTION)/){
       print OUT2 $oriline;
    }else{
       print OUT1 $oriline;
    }
  }#end if($col[14])
}#end while

close INPUT;
close OUT1;
close OUT2;

