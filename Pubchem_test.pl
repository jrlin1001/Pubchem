use SOAP::Lite;	# +trace => qw(debug);
import SOAP::Data qw(name);

# Create PUG SOAP service object
my $pug_soap = new SOAP::Lite
	uri => "http://pubchem.ncbi.nlm.nih.gov/",
	proxy => "http://pubchem.ncbi.nlm.nih.gov/pug_soap/pug_soap.cgi";

################################################################################
#
# Wrappers
#
################################################################################
	
sub GetOperationStatus
{
	my $AnyKey = shift;
	my $som = $pug_soap->GetOperationStatus(name(AnyKey => $AnyKey));
	die $som->faultstring if $som->fault;
	return $som->result;
}

sub waitForStatus {
        my $AnyKey = shift;
        my $status = GetOperationStatus($AnyKey);
        #print "Waiting...";
        while ( $status eq eStatus_Queued || $status eq eStatus_Running ) {
                #print ".";
                sleep 2;
                $status = GetOperationStatus($AnyKey);
                #print "status: $status\n";
        }
        if ($status eq eStatus_Success) {
            return;
        }
        if ($status eq eStatus_HitLimit || $status eq eStatus_TimeLimit) {
            print "Warning: hit or time limit encountered before operation completed.\n";
            return;
        }
        die "Error encountered; status = $status.\n";
}

sub InputStructure
{
	print "InputStructure($_[0], $_[1])\n";
	
	my $som = $pug_soap->InputStructure(name(structure => $_[0]), name(format => $_[1]));
	die $som->faultstring if $som->fault;
	return $som->result;
}

sub InputListText
{
	print "InputListText($_[0], $_[1])\n";

	my $som = $pug_soap->InputListText(name(ids => $_[0]), name(idType => $_[1]));
	die $som->faultstring if $som->fault;
	return $som->result;
}

sub IdentitySearch
{
	print "IdentitySearch($_[0], $_[1])\n";
	my $som = $pug_soap->IdentitySearch(name(StrKey => $_[0]), name(idOptions => \name(eIdentity => $_[1])));
	die $som->faultstring if $som->fault;
	my $ListKey = $som->result;
	waitForStatus($ListKey);
	return $ListKey;
}

sub MFSearch
{
	print "MFSearch($_[0], $_[1])\n";
	my $som = $pug_soap->MFSearch(name(MF => $_[0]), name(mfOptions => \name(AllowOtherElements => $_[1])));
	die $som->faultstring if $som->fault;
	my $ListKey = $som->result;
	waitForStatus($ListKey);
	return $ListKey;
}

sub Standardize
{
	print "Standardize($_[0])\n";
	my $som = $pug_soap->Standardize(name(StrKey => $_[0]));
	die $som->faultstring if $som->fault;
	my $StrKey = $som->result;
	waitForStatus($StrKey);
	
	$som = $pug_soap->GetStandardizedCID(name(StrKey => $StrKey));
	die $som->faultstring if $som->fault;
	my $CID = $som->result;
	
	$som = $pug_soap->GetStandardizedStructure(name(StrKey => $StrKey), name(format => $_[1]));
	die $som->faultstring if $som->fault;
	my $structure = $som->result;
	
	return [$CID, $structure];
}

sub GetStatusMessage
{
	my $AnyKey = shift;
	my $som = $pug_soap->GetStatusMessage(name(AnyKey => $AnyKey));
	die $som->faultstring if $som->fault;
	return $som->result;
}

sub Download
{
	my $som = $pug_soap->Download(name(ListKey => $_[0]), name(eFormat => $_[1]), name(eCompress => $_[2]));
	die $som->faultstring if $som->fault;
	my $DwldKey = $som->result;
	waitForStatus($DwldKey);
	$som = $pug_soap->GetDownloadUrl(name(DownloadKey => $DwldKey));
	die $som->faultstring if $som->fault;
	return $som->result;
}

sub GetListItemsCount
{
	my $ListKey = shift;
	my $som = $pug_soap->GetListItemsCount(name(ListKey => $ListKey));
	die $som->faultstring if $som->fault;
	return $som->result;
}

sub GetIDList
{
	my $ListKey = shift;
	my $som = $pug_soap->GetIDList(name(ListKey => $ListKey));
	die $som->faultstring if $som->fault;
	return $som->result;
}

################################################################################
#
# Tests
#
################################################################################

# InputStructure
my $StrKey = InputStructure("c1ccccc1", eFormat_SMILES);

# IdentitySearch
my $ListKey = IdentitySearch($StrKey, eIdentity_SameConnectivity);
print GetListItemsCount($ListKey) . " structures found\n";

# Standardize
my $stdres = Standardize($StrKey, eFormat_SMILES);
print "Standardized: CID: $stdres->[0], SMILES: $stdres->[1]\n";

my $url = Download($ListKey, eFormat_SDF, eCompress_GZip);
print "Download: $url\n";

0;