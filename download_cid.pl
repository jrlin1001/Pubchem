## script for download bioassay data from PubChem using CID list. 
## 2014/04/03
## Jerry Lin
##
## Usage:  Perl download_cid.pl [input.tsv] [Column for CID]
##

use strict;
use warnings;
use LWP::Simple;

my $cidfile ="lincs-1.tsv";                 #default input.tsv
my $cidcol = 6;                             #default CID column

if($ARGV[0]){$cidfile=$ARGV[0];}
if($ARGV[1]){$cidcol=$ARGV[1]-1;}

open INPUTF,"<$cidfile";

<INPUTF>;                               #skip title line

while(<INPUTF>){
  chomp;
  my @line= split(/\t/,$_);
  if($line[$cidcol]){
      my $cid = $line[$cidcol];
      my $esearch = 'http://pubchem.ncbi.nlm.nih.gov/assay/assay.cgi?q=dcsv&ocfilter=act&&cid='.$cid;
      print "Retrieving CID $cid data from Pubchem\n";
      my $result=get($esearch);                       #get CSV file from PubChem
      sleep 1;
      my $assayf= 'CID_'.$cid.'_assaydata.csv';
      if(length($result)>37){                         #ignore empty bioassay file
        open OUTF,">$assayf";
        print OUTF $result;
        close OUTF;}
  } #endif ($line[$cidcol])
}#while
close INPUTF;


