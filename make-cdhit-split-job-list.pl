#!/usr/bin/env perl

use strict;
use warnings;
use autodie;
use feature 'say';
use Getopt::Long;
use Pod::Usage;
use LWP::Simple;

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
	my $infile = $args{'in'} or pod2usage('Missing input .clstr to be split');
	my $outprefix = $args{'out'} or pod2usage('Missing outfile prefix');
	my $size = $args{'size'} || 5000;

	# split .clstr to individual cluster id files 
	my $total_cluster = `grep -c '>Cluster' $infile`;
	my $init = `grep '>Cluster' $infile | head -n1`;
	$init =~ s/^>Cluster //g;
	my $order = 1;
	
	for (my $i=$init; $i < $init+$total_cluster; $i+=$size) {
		my $j=$i+$size;
		my $lines = `perl -ne "print if /^>Cluster $i\$/../^>Cluster $j\$/;" $infile`;
		my @clusters = split ("\n", $lines);

		my $outfile = "$outprefix"."_"."$order";
		open my $out_fh, ">",$outfile;
		foreach my $ele (@clusters) {
			if ($ele ne ">Cluster $j") {
				say $out_fh $ele;
			}
		}	 
		$order++;
	}
}

# --------------------------------------------------
sub get_args {
    my %args;
    GetOptions(
        \%args,
        'in=s',
		'out=s',
		'size=s',
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

  split-cdhit-clstr.pl -i [input] -o [outfile prefix] 

Options:

  --in			input cd-hit ".clstr" file
  --out			out file prefix name
  --size		number of clusters per one file (default: 5000) 
  --help   		Show brief help and exit
  --man    		Show full documentation
  
=head1 DESCRIPTION

This scripts split the cd-hit ".clstr" into several .clstr file for stampede2 launcher 

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
