  use WWW::Search;
  my $search = new WWW::Search('PubChem');

  my @ids = qw/ 126941 3253 77231 /;
  $search->native_query( \@ids );

  while( my $chem = $search->next_result ) {
    printf "PubChem ID: %s\n", $chem->{pubchemid};
    printf "IUPAC name: %s\n", $chem->{iupac_name};
    printf "SMILES string: %s\n", $chem->{smiles};
    printf "Molecular formula: %s\n", $chem->{molecular_formula};
    printf "Molecular weight: %s\n", $chem->{molecular_weight};
    printf "Exact mass: %s\n", $chem->{exact_mass};
    printf "# H-bond acceptors: %d\n", $chem->{nhacceptors};
    printf "# H-bond donors: %d\n", $chem->{nhdonors};
    printf "# Rotatable bonds: %d\n", $chem->{nrotbonds};
    printf "Fingerprint: %s\n", $chem->{fingerprint};
    printf "InChI string: %s\n", $chem->{inchi};
    printf "XLogP2: %s\n", $chem->{xlogp2};
    printf "Polar surface area: %s\n", $chem->{tpsa};
    printf "Monoisotopic weight: %s\n", $chem->{monoisotopic_weight};
  }
