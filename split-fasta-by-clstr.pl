#!/usr/bin/env perl

use strict;
use warnings;
use autodie;
use feature 'say';
use Getopt::Long;
use Pod::Usage;
use Bio::SeqIO;

main();

# --------------------------------------------------
sub main {
    my %args = get_args();

    if ($args{'help'} || $args{'man_page'}) {
        pod2usage({
            -exitval => 0,
            -verbose => $args{'man_page'} ? 2 : 1
        });
    }; 

	# get parameters
	my $clstr_file = $args{'clstr'} or pod2usage('Missing input .clstr for spliting');
	my $outprefix = $args{'out'} or pod2usage('Missing outfile prefix');
	my $fasta = $args{'fasta'} or pod2usage('Missing fasta file');
	my $threshold = $args{'minimum'} || 2;

	# split .clstr to individual cluster id files 
	my $total_cluster = `grep -c '>Cluster' $clstr_file`;
	for (my $i=0; $i < $total_cluster; $i++) {
		my $j=$i+1;
		my $lines = `perl -ne "print if /^>Cluster $i\$/../^>Cluster $j\$/;" $clstr_file`;
		my @cluster = split ("\n", $lines);
		@cluster = grep {$_ ne ">Cluster $i" and $_ ne ">Cluster $j"} @cluster;
		next if (scalar @cluster < $threshold);	
		my %id_hash;
		my $outfile = "$outprefix"."_"."$i";
		foreach my $ele (@cluster) {
				$ele =~ s/^.*\>//g;
				$ele =~ s/\.\.\..*//g;
				$id_hash{$ele}++;
		}
		my $seq_in = Bio::SeqIO -> new(-file => "$fasta", -format => 'fasta');	
		my $seq_out = Bio::SeqIO -> new(-file => ">$outfile", -format => 'fasta');
		while (my $inseq = $seq_in -> next_seq) {
			my $seq_id = $inseq -> id();
			$seq_out -> write_seq($inseq) if (exists $id_hash{$seq_id});
		}
		%id_hash= ();
	}
}
# --------------------------------------------------
sub get_args {
    my %args;
    GetOptions(
        \%args,
		'fasta=s',
        'clstr=s',
		'out=s',
		'minimum=i',
		'help',
        'man',
    ) or pod2usage(2);

    return %args;
}

__END__

# --------------------------------------------------

=pod

=head1 NAME

cdhit-count.pl - a script

=head1 SYNOPSIS

  split-fasta-by-clstr.pl -f [fasta] -c [.clstr file] -o [outfile prefix] --minimum [threshold] 

Options:

  --fasta		input fasta file
  --clstr		input cd-hit ".clstr" file
  --out			out file prefix name
  --minimum		threshold, minimum seqeunces cluster have 
  --help   		Show brief help and exit
  --man    		Show full documentation
  
=head1 DESCRIPTION

This scripts split the cd-hit ".clstr" into individual files with seq ids.

=head1 SEE ALSO

perl.

=head1 AUTHOR

Xiang Liu E<lt>Xiang@email.arizona.eduE<gt>.

=head1 COPYRIGHT

Copyright (c) 2018 Xiang

This module is free software; you can redistribute it and/or
modify it under the terms of the GPL (either version 1, or at
your option, any later version) or the Artistic License 2.0.
Refer to LICENSE for the full license text and to DISCLAIMER for
additional warranty disclaimers.

=cut
