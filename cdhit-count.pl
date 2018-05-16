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

    # get parameters (query,database,rettype, and output file)
    my $infile = $args{'in'} or pod2usage('Missing infile name');
    my $outfile = $args{'out'} or pod2usage('Missing outfile name');
	
	open my $out_fh, ">", $outfile;
	
	my $total_cluster = `grep -c '>Cluster' $infile`;
	for (my $i=0; $i < $total_cluster; $i++) {
		my $j=$i+1;
		my $lines = `perl -ne "print if /^>Cluster $i\$/../^>Cluster $j\$/;" $infile | wc -l`;
		my $lines_exclude_pattern = $lines - 2;
		say $out_fh "Cluster $i,$lines_exclude_pattern";
	}
}

# --------------------------------------------------
sub get_args {
    my %args;
    GetOptions(
        \%args,
        'in=s',
		'out=s',
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

  cdhit-count.pl -i [input] -o [output] 

Options:

  --in			input file name
  --out			output file name
  --help   		Show brief help and exit
  --man    		Show full documentation
  
=head1 DESCRIPTION

This scripts count the cd-hit output cluster.

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
