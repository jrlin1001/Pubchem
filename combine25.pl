## combine CSV files version 0.25  Jerry Lin  03/12/2014
##
## Take PubChem CSV files and a CID list file to combine into single files
## Usage: perl combine1.pl [index file/CID] [output file]
## input file column 1-8 (last column CID)
## CSV file column 1-9 (last column UNIPROT_ID)
## read two data files (gi2uniprot.tsv & aid2uniprot.tsv)
##

use warnings;
use strict;
use Text::CSV;

## -----------Read target GI/AID file-----------------

my %gi_uniprot;           #gi to uniprot hash
my %aid_uniprot;          #AID to uniprot hash

open GIFILE,"<gi2uniprot.tsv";
while (my $line = <GIFILE>){
  chomp $line;
  $line = uc $line;
  my @col = split "\t",$line;
  if($col[0]){$gi_uniprot{$col[0]} = $col[1];}
}#while
close GIFILE;

open AIDFILE,"<aid2uniprot.tsv";
while (my $line = <AIDFILE>){
  chomp $line;
  $line = uc $line;
  my @col = split "\t",$line;
  if($col[0]){$aid_uniprot{$col[0]}=$col[1];}
}#while
close AIDFILE;

##------------------------------------------------------

my $title_flag = 0;                                     #flag for printing title or not

my $indexfile= "input.tsv";                             #input/index file
if ($ARGV[0]){$indexfile=$ARGV[0];}
my $outfile = "combine.csv";                           #output/combined file
if ($ARGV[1]){$outfile=$ARGV[1];}

open MISS,">misslog.csv";                               #log file for missing CIDs
open FILEH,"<$indexfile";
open OUTF, ">$outfile";

my $line = <FILEH>;
chomp $line;
my @title= split "\t",$line;          ## read title;
my $csv = Text::CSV->new({ sep_char => ',' });


while(my $line = <FILEH>){
  chomp $line;
  my @field = split "\t", $line;

  my $cid ="";
  if ($field[7]){$cid=$field[7];}

  my $filename = 'CID_'.$cid.'_assaydata.csv';
  if (-e $filename) {

    print "\nProcessing CID_$cid";
    open CSVF,"<$filename";
    
    my $line2 = <CSVF>;                        # read title of csv file
    chomp $line2;
    my @title2;
    if($csv->parse($line2)){@title2 = $csv ->fields();}
    
    if($title_flag == 0){                              # print title
          foreach(@title){print OUTF "$_\t";}
          foreach(@title2){print OUTF "$_\t";}
          print OUTF "TARGET_UNIPROT\n";
          $title_flag = 1;
    }#endif($title_flag)


    while (my $line2 = <CSVF>){
          chomp $line2;
          print ".";
          my @field2;
          if ($csv->parse($line2)) {@field2 = $csv->fields();}

          if ($field2[8]){
            my $target=$field2[8];
            $target =~ /gi:(\d+)/;
            $field2[8]="";
            if($1){$field2[8]=$1;}
          } # endif ($filed[8])
          my $uniprot ="";

          if($field2[8]){
            if ($gi_uniprot{$field2[8]}){
              $uniprot = $gi_uniprot{$field2[8]};
              }
          }else{
            if($field2[5]){
              my $assay = uc $field2[5];
              if($aid_uniprot{$assay}){$uniprot= $aid_uniprot{$assay};} #end if
            } #end if ($field[5]) AID test
          } #end if ($field[8]) GI test

          if($field2[0]){                                               #output section
            foreach(@field){print OUTF "$_\t";}
            foreach(@field2){print OUTF "$_\t";}
            print OUTF "$uniprot\n";
          }#endif(@filed2[0])

    }#while(<CSVF>)
    close CSVF;
  }else{ print MISS "$field[0]\t$cid\n";}   #end if (-e filename)
}# end while(<INPUT>)

close FILEH;
close OUTF;
close MISS;


