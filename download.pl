use LWP::Simple;
my $test;
$test=get("http://pubchem.ncbi.nlm.nih.gov/assay/assay.cgi?q=da&ocfilter=act&&cid=3059#");
print $test;
