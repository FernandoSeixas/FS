######################################
###          PreSeqPhase           ###
######################################

#########################################################################################


#########################################################################################

#!/bin/perl -w
use strict;

### get input file (.fas or .phy)
my $input_file  = $ARGV[0];
unless ($input_file) { print "\nNeed input file (.fas or .phy). Command should be:\nperl preSeqPhase.pl <input_file>\n"; } 
###

# Alignment of sequences from homozygous individuals and from heterozygotes to be phased (FASTA, one sequence per individual)
my @unphased;
# Alignment of phased haplotypes, if any (FASTA, two sequences per individual).
my @phased;


###################################################################
#  if input file is .fasta, .fas or .fa convert into .phy format ##
###################################################################

if ($input_file =~ /.*.fasta/ || $input_file =~ /.*.fas/ || $input_file =~ /.*.fas/) {

#	my $inline;
	my $count = 0;
#	my $len;
#	my $substate = 0;
	my @subheader;
	my @subcontent;
	my $m;
	my $n;
	my @converted_phy;

# 
	open (FAS, '<', $input_file) or die "can't open $input_file $!\n";
		while (my $inline = <FAS>) {	
			chomp($inline);
			if ($inline =~ /^>([A-Za-z0-9.\-_:]+)/) {	
				$subheader[$count] = $1;
				$subcontent[$count] = "";
				$count++;}
			else
			{$subcontent[$count - 1] = $subcontent[$count - 1] . " $inline";}
		}
		close (FAS);

# Calculate alignment length
		$n = length($subcontent[0]);
		my $len = $n;
		for ($m = 0; $m < $n; $m++)
		{	if (substr($subcontent[0], $m, 1) eq " ") {	$len--;} }

# create .phy file
	my $header = "   $count    $len"; # create header line of .phy file
	my $seq;
		push (@converted_phy, $header);	
		for ($m = 0; $m < $count; $m++)
		{
			$len = 10 - length($subheader[$m]);
			my $seqname = "$subheader[$m]";
			my $sequence = "$subcontent[$m]";
			for ($n = 0; $n < $len; $n++) {
				$seq = $seqname . " " x $n . $sequence;
				}
			push (@converted_phy, $seq);
		}

# output .phy file
	my $conv_phy_file;
	open($conv_phy_file, ">conv_phy.phy") or die "Can't open $conv_phy_file: \n";
	print $conv_phy_file join("\n", @converted_phy);
	close $conv_phy_file;
	
# Allocate sequences into .known and .input files that can be used as input for SeqPhase.
	my $conv_input = "conv_phy.phy";
	open (PHY, '<', $conv_input) or die "can't open $conv_phy_file $!\n";
	while (my $line = <PHY>) {
		next if ($. == 1);
		chomp $line;
		my @line_E = split(" ", $line);

		my $count_pol = ($line_E[1] =~ tr/[WRYSKM]//);
			if ($count_pol > 1) {
				my $name = ">" . $line_E[0];
				my $seq = $line_E[1];
				push (@unphased, $name);
				push (@unphased, $seq);
			} elsif ($count_pol == 0) {
					if ($line_E[0] =~ /._a/ or $line_E[0] =~ /._b/) {
						my $name = ">" . $line_E[0];
						my $seq = $line_E[1];
						push (@phased, $name);
						push (@phased, $seq);
					} else {
						my $name = ">" . $line_E[0];
						my $seq = $line_E[1];					
						push (@unphased, $name);
						push (@unphased, $seq);
					}
					
			} elsif ($count_pol == 1) {
				my $name_a = ">" . $line_E[0] . "_a";
				my $seq_a = $line_E[1];
				$seq_a =~ tr/W/A/;
				$seq_a =~ tr/R/A/;
				$seq_a =~ tr/Y/C/;
				$seq_a =~ tr/S/C/;
				$seq_a =~ tr/K/G/;
				$seq_a =~ tr/M/A/;
				my $name_b = ">" . $line_E[0] . "_b";
				my $seq_b = $line_E[1];
				$seq_b =~ tr/W/T/;
				$seq_b =~ tr/R/G/;
				$seq_b =~ tr/Y/T/;
				$seq_b =~ tr/S/G/;
				$seq_b =~ tr/K/T/;
				$seq_b =~ tr/M/C/;
				push (@phased, $name_a);
				push (@phased, $seq_a);
				push (@phased, $name_b);
				push (@phased, $seq_b);
			}
		}

}
#####################################################################
# If input file is provided in .phy format. Allocate sequences into #
# .known and .input files that can be used as input for SeqPhase.   #
#####################################################################
	
elsif ($input_file =~ /.*.phy/) {
	
	open (PHY, '<', $input_file) or die "can't open $input_file $!\n";
	while (my $line = <PHY>) {
		next if ($. == 1);
		chomp $line;
		my @line_E = split(" ", $line);
		my $count_pol = ($line_E[1] =~ tr/[WRYSKM]//);
			if ($count_pol > 1) {
				my $name = ">" . $line_E[0];
				my $seq = $line_E[1];
				push (@unphased, $name);
				push (@unphased, $seq);
			} elsif ($count_pol == 0) {
					if ($line_E[0] =~ /._a/ or $line_E[0] =~ /._b/) {
						my $name = ">" . $line_E[0];
						my $seq = $line_E[1];
						push (@phased, $name);
						push (@phased, $seq);
					} else {
						my $name = ">" . $line_E[0];
						my $seq = $line_E[1];					
						push (@unphased, $name);
						push (@unphased, $seq);
					}
					
			} elsif ($count_pol == 1) {
				my $name_a = ">" . $line_E[0] . "_a";
				my $seq_a = $line_E[1];
				$seq_a =~ tr/W/A/;
				$seq_a =~ tr/R/A/;
				$seq_a =~ tr/Y/C/;
				$seq_a =~ tr/S/C/;
				$seq_a =~ tr/K/G/;
				$seq_a =~ tr/M/A/;
				my $name_b = ">" . $line_E[0] . "_b";
				my $seq_b = $line_E[1];
				$seq_b =~ tr/W/T/;
				$seq_b =~ tr/R/G/;
				$seq_b =~ tr/Y/T/;
				$seq_b =~ tr/S/G/;
				$seq_b =~ tr/K/T/;
				$seq_b =~ tr/M/C/;
				push (@phased, $name_a);
				push (@phased, $seq_a);
				push (@phased, $name_b);
				push (@phased, $seq_b);
			}
		}
	}

my $unphasedfile;
my $phasedfile;
open($unphasedfile, ">unphased.fas") or die "Can't open $unphasedfile: \n";
open($phasedfile, ">phased.fas") or die "Can't open $phasedfile: \n"; 
print $unphasedfile join("\n", @unphased);
print $phasedfile join("\n", @phased);
close $unphasedfile;
close $phasedfile;
