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


## -----------Read target GI/Name file-----------------
open GIF,"<drug_target.csv";
my %name_gi;
my %gi_unipro;

<GIF>;                                                 #read title
while (my $line = <GIF>){
  chomp $line;
  $line = uc $line;
  my @column = split ",",$line;
  if (my $name = $column[1]){
     $name =~s/_HUMAN//;
     chomp $column[0];
     $name_gi{$name}=$column[0];
     $gi_unipro{$column[0]}=$column[1];
     print "$name $name_gi{$name} $gi_unipro{$column[0]}\n";
  } ##end if
}##end while
close GIF;
##------------------------------------------------------



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
              my @column = split " ",$assay;
              foreach my $key(@column){
                if($name_gi{$key}){
                  $field2[8]= $name_gi{$key};
                  $unipro = $gi_unipro{$field2[8]};
                } #end if
              } # end foreach
            } #end if ($field[7)
          } #end if ($field[8])

          foreach(@field){print OUTF "$_\t";}
          foreach(@field2){print OUTF "$_\t";}
          print OUTF "$unipro\n";
   }
    close CSVF;
  }# end if
}# end while
close FILEH;
close OUTF;

