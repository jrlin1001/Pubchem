use LWP::UserAgent;
use HTML::Form;
use WWW::Mechanize;

my $agent = WWW::Mechanize->new();
my $url="http://pubchem.ncbi.nlm.nih.gov/assay/assay.cgi?q=da&ocfilter=act&&cid=3059#";
$agent->get($url);
my $button = "div.pdn";
my $link ="div.pdn";
$agent->click($button);	 # ????
