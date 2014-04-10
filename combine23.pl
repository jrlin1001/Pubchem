## combine CSV files version 0.23  Jerry Lin  12/06/2013
## Take PubChem CSV files and NCI60 CID list and combine into single files
## Usage: perl combine1.pl [index file/CID] [output file]

use warnings;
use strict;
use Text::CSV;


## -----------Read target GI/Name file-----------------
open GIF,"<drug_target-2.csv";
my %name_gi;
my %gi_unipro;
my %name_unipro;

while (my $line = <GIF>){
  chomp $line;
  $line = uc $line;
  my @column = split ",",$line;
  if (my $name = $column[1]){
     $name =~s/_HUMAN//;
     $name_unipro{$name}=$column[1];
     chomp $column[0];
     $name_gi{$name}=$column[0];
     $gi_unipro{$column[0]}=$column[1];

     print "$name $name_gi{$name} $gi_unipro{$column[0]}\n";
  } ##end if
}##end while
close GIF;
##------------------------------------------------------


my $indexfile= "input.tsv";                             #input/index file
if ($ARGV[0]){$indexfile=$ARGV[0];}
my $outfile = "combine.csv";                           #output/combined file
if ($ARGV[1]){$outfile=$ARGV[1];}

open MISS,">misslog.csv";                               #log file for missing CIDs
open FILEH,"<$indexfile";
open OUTF, ">$outfile";

my $line = <FILEH>;my @title= split "\t",$line;          ## read title;
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
          my $unipro ="";

          if($field2[8]){

            if ($gi_unipro{$field2[8]}){
              $unipro = $gi_unipro{$field2[8]};
              }
          }else{
            if($field2[6]){
              my $assay = uc $field2[6];

              $assay =~s/\// /g;                ## remove "/" in assay
              $assay =~s/\(/ /g;
              $assay =~s/\)/ /g;
              #print "assay= $assay\n";
              print "\n";
              my @column = split " ",$assay;
              foreach my $key(@column){
                if($name_gi{$key}){
                  $field2[8]= $name_gi{$key};
                  $unipro = $gi_unipro{$field2[8]};
                  print " $key";
                } #end if
              } # end foreach
            } #end if ($field[7)
          } #end if ($field[8])

          foreach(@field){print OUTF "$_\t";}
          foreach(@field2){print OUTF "$_\t";}
          print OUTF "$unipro\n";
   }
    close CSVF;
  }else{ print MISS "$field[0]\t$cid\n";}   #end if (-e filename)
}# end while
close FILEH;
close OUTF;
close MISS;


