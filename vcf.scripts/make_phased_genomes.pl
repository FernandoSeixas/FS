### improvements to make:
# at this point can only be applied to each chromossome at a time; HOW TO APPLY TO ALL CHRS AT A TIME?

use strict; # help you to keep track of variable names and scope

## command line should be as follows: script2.pl <reference.fa> <variant_calling.vcf>
my $REFERENCE = $ARGV[0];
my $VCF_all = $ARGV[1];
my $VCF_var = $ARGV[2];
my $ind  = $ARGV[3];


## get reference sequence and create two (equal) sequences that will be used as template 
my @nucleotides;
open (FA, '<', $REFERENCE) or die "can't open $REFERENCE $!\n";
		while (my $l = <FA>) {
				if ($l =~ /^\>/) { next; }
				else {@nucleotides = split('',$l);}
		}

foreach (@nucleotides) {
	$_ = 'N';
	}

my @new_seq_a = @nucleotides;
my @new_seq_b = @nucleotides;


## from the vcf files (including invariant sites) create the lepus sequence 
open (VCF_all, '<', $VCF_all) or die "can't open $VCF_all $!\n";
	while (my $line = <VCF_all>) {
		my @cols = split("\t", $line); ## separate columns
		my $pos = $cols[1];
		my @lep_alleles = split(',',$cols[4]);
		my $ref_base = $cols[3];
		my $alt_base_1 = $lep_alleles[0];
		my $alt_base_2 = $lep_alleles[1];
		my $alt_base_3 = $lep_alleles[2];
		my $genotye = $cols[$ind];		
		my $al;
		if ($genotye =~ /\.\/\./) {$al = 'N';}
		if ($genotye =~ /0\/0/) {$al = $ref_base;}
		if ($genotye =~ /0\/1/) {$al = 'N';}
		if ($genotye =~ /0\/2/) {$al = 'N';}
		if ($genotye =~ /0\/3/) {$al = 'N';}
		if ($genotye =~ /1\/1/) {$al = $alt_base_1;}
		if ($genotye =~ /1\/2/) {$al = 'N';}
		if ($genotye =~ /1\/3/) {$al = 'N';}
		if ($genotye =~ /2\/2/) {$al = $alt_base_2;}
		if ($genotye =~ /2\/3/) {$al = 'N';}
		if ($genotye =~ /3\/3/) {$al = $alt_base_3;}
		
		if ($new_seq_a[$pos-1] != /$al/) {$new_seq_a[$pos-1] = $al;}
		if ($new_seq_b[$pos-1] != /$al/) {$new_seq_b[$pos-1] = $al;}		
		
		}
		
## replace reference sequence by phased snps to create phased genomes (haplotypes)
open (VCF_var, '<', $VCF_var) or die "can't open $VCF_var $!\n";
	while (my $line = <VCF_var>) {
		my @cols = split("\t", $line); ## separate columns
		my $pos = $cols[1];
		my $ref_base = $cols[3];
		my $alt_base = $cols[4];
		my $individual = $cols[$ind];
		my @alleles = split('|',$individual);
		my $al_a;
		my $al_b;
		if ($alleles[0] =~ /0/) {$al_a = $ref_base;}
		if ($alleles[0] =~ /1/) {$al_a = $alt_base;}
		if ($alleles[0] =~ /'\.'/) {$al_a = 'N';}
		if ($alleles[1] =~ /0/) {$al_b = $ref_base;}
		if ($alleles[1] =~ /1/) {$al_b = $alt_base;}
		if ($alleles[1] =~ /'\.'/) {$al_b = 'N';}
		
		if ($new_seq_a[$pos-1] != /$al_a/) {$new_seq_a[$pos-1] = $al_a;}
		if ($new_seq_b[$pos-1] != /$al_b/) {$new_seq_b[$pos-1] = $al_b;}
		}

print ">seq_a\n", join("",@new_seq_a), "\n";
print ">seq_b\n", join("",@new_seq_b), "\n";

