######################################
###      mpileup_vcf_2_fasta       ###
######################################


## Improvements to make:
# at this point can only be applied to each chromossome at a time; HOW TO APPLY TO ALL CHRS AT A TIME?

use strict; # help you to keep track of variable names and scope

## command line should be as follows: script2.pl <reference.fa> <variant_calling.vcf>
my $REFERENCE = $ARGV[0];
my $VCF_all = $ARGV[1];
my $VCF_var = $ARGV[2];
my $ind_last_col  = $ARGV[3];

unless ($REFERENCE) { print "\nNeed reference file. Command should be:\nperl pip_vcf2fasta.pl <reference.fa> <all_snps> <var_snps> <ind_col in vcf> > <outfile.fasta>\n"; } 
unless ($VCF_all) { print "\nNeed invariant+variant file. Command should be:\nperl pip_vcf2fasta.pl <reference.fa> <all_snps> <var_snps> <ind_col in vcf> > <outfile.fasta>\n"; } 
unless ($VCF_var) { print "\nNeed variant only file. Command should be:\nperl pip_vcf2fasta.pl <reference.fa> <all_snps> <var_snps> <ind_col in vcf> > <outfile.fasta>\n"; } 
unless ($ind_last_col) { print "\nNeed individual column in vcf files. Command should be:\nperl pip_vcf2fasta.pl <reference.fa> <all_snps> <var_snps> <ind_col in vcf> > <outfile.fasta>\n"; } 

my @fasta_file;

my $count=9;
while ($count <= $ind_last_col) {

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
			my $ref_base = $cols[3];
			my @lep_alleles = split(',',$cols[4]);
			my $alt_base_1;
			my $alt_base_2,
			my $alt_base_3;
			if ($lep_alleles[0]) {$alt_base_1 = $lep_alleles[0];}
			if ($lep_alleles[1]) {$alt_base_2 = $lep_alleles[1];}
			if ($lep_alleles[2]) {$alt_base_3 = $lep_alleles[2];}
			my @gen = split(':',$cols[$count]);
			chomp(@gen);
			my $genotype = $gen[0];
			my $al;
	
			if ($genotype =~ /\.\/\./) {$al = 'N';}
			if ($genotype =~ /0\/0/) {$al = $ref_base;}
			if ($genotype =~ /0\/1/) {$al = 'N';}
			if ($genotype =~ /0\/2/) {$al = 'N';}
			if ($genotype =~ /0\/3/) {$al = 'N';}
			if ($genotype =~ /1\/1/) {$al = $alt_base_1;}
			if ($genotype =~ /1\/2/) {$al = 'N';}
			if ($genotype =~ /1\/3/) {$al = 'N';}
			if ($genotype =~ /2\/2/) {$al = $alt_base_2;}
			if ($genotype =~ /2\/3/) {$al = 'N';}
			if ($genotype =~ /3\/3/) {$al = $alt_base_3;}
	
			if ($new_seq_a[$pos-1] ne /$al/) {$new_seq_a[$pos-1] = $al;}
			if ($new_seq_b[$pos-1] ne /$al/) {$new_seq_b[$pos-1] = $al;}
	
			}
	
	#print ">seq_a\n", join("",@new_seq_a), "\n";
	#print ">seq_b\n", join("",@new_seq_b), "\n";
	
	
	## replace reference sequence by phased snps to create phased genomes (haplotypes)
	open (VCF_var, '<', $VCF_var) or die "can't open $VCF_var $!\n";
		while (my $line = <VCF_var>) {
			my @cols = split("\t", $line); ## separate columns
			my $pos = $cols[1];
			my $ref_base = $cols[3];
	
			my @lep_alleles = split(',',$cols[4]);
			my $alt_base_1;
			my $alt_base_2,
			my $alt_base_3;
			if ($lep_alleles[0]) {$alt_base_1 = $lep_alleles[0];}
			if ($lep_alleles[1]) {$alt_base_2 = $lep_alleles[1];}
			if ($lep_alleles[2]) {$alt_base_3 = $lep_alleles[2];}
	
			my @hap = split(':',$cols[$count]);
			chomp(@hap);
			my $haplotype = $hap[0];
	
			my @alleles = split("\\|",$haplotype);
	
			my $al_a;
			my $al_b;
			if ($alleles[0] =~ /0/) {$al_a = $ref_base;}
			if ($alleles[0] =~ /1/) {$al_a = $alt_base_1;}
			if ($alleles[0] =~ /2/) {$al_a = $alt_base_2;}
			if ($alleles[0] =~ /3/) {$al_a = $alt_base_3;}
			if ($alleles[0] =~ /'\.'/) {$al_a = 'N';}
	
			if ($alleles[1] =~ /0/) {$al_b = $ref_base;}
			if ($alleles[1] =~ /1/) {$al_b = $alt_base_1;}
			if ($alleles[1] =~ /2/) {$al_b = $alt_base_2;}
			if ($alleles[1] =~ /3/) {$al_b = $alt_base_3;}
			if ($alleles[1] =~ /'\.'/) {$al_b = 'N';}
	
			if ($new_seq_a[$pos-1] ne /$al_a/) {$new_seq_a[$pos-1] = $al_a;}
			if ($new_seq_b[$pos-1] ne /$al_b/) {$new_seq_b[$pos-1] = $al_b;}
			}
	
	#print ">seq_a\n", join("",@new_seq_a), "\n";
	#print ">seq_b\n", join("",@new_seq_b), "\n";
	#
	
	my $head_a = "seq_" . ($count-8) . "_a";
	push(@fasta_file, "$head_a");
	my $seq_a = join("", @new_seq_a);
#	chomp($seq_a);
	push(@fasta_file, $seq_a);

	my $head_b = "seq_" . ($count-8) . "_b";
	push(@fasta_file, "$head_b");
	my $seq_b = join("", @new_seq_b);
#	chomp($seq_b);
	push(@fasta_file, $seq_b);

	$count++;
	}

print join("\n", @fasta_file);
