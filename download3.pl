use strict;
use LWP::UserAgent;
{
    my $ua = new LWP::UserAgent();
    my $search_address = "http://pubchem.ncbi.nlm.nih.gov/assay/assay.cgi?q=da&ocfilter=act&&cid=3059#";

    #creating the request object
    my $req = new HTTP::Request ('POST', $search_address);

    #sending the request
    my $res = $ua->request($req);
    if (!($res->is_success)){
        warn "Warning:".$res->message."\n";
    }

    my $response = $res->headers_as_string();
    my $response .= $res->content();
    print "$response\n";
}