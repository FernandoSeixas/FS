use strict; # help you to keep track of variable names and scope


my $VCF_var = $ARGV[0]; 
my $ind_last_col = $ARGV[1];
my $first_gra = $ARGV[2];
my $numb_gra = $ARGV[3];
my $numb_tim = $ARGV[5];


my @individual_number=(9..$ind_last_col);

my @complete_info;

open (VCF_var, '<', $VCF_var) or die "can't open $VCF_var $!\n";
        while (my $line = <VCF_var>) {

                if ($line =~ /^\#/) {next;}
                else {
                        my @cols = split("\t", $line); ## separate vcf into columns
                        my $pos = $cols[1];
                        my $ref_base = $cols[3];

                        my @lep_alleles = split(',',$cols[4]);
                        my $alt_base_1;
                        my $alt_base_2,
                        my $alt_base_3;
                        if ($lep_alleles[0]) {$alt_base_1 = $lep_alleles[0];}
                        if ($lep_alleles[1]) {$alt_base_2 = $lep_alleles[1];}
                        if ($lep_alleles[2]) {$alt_base_3 = $lep_alleles[2];}


                        my @pos_genotype;
#                        push(@pos_genotype, $pos);
                        foreach(@individual_number) {
                                my @gen = split(':',$cols[$_]);
                                chomp(@gen);
                                my $genotype = $gen[0];

                                my $al;
                                if ($genotype =~ /\.\/\./) {$al = "N\tN";}
                                if ($genotype =~ /0\/0/) {$al = "$ref_base\t$ref_base";}
                                if ($genotype =~ /0\/1/) {$al = "$ref_base\t$alt_base_1";}
                                if ($genotype =~ /0\/2/) {$al = "$ref_base\t$alt_base_2";}
                                if ($genotype =~ /0\/3/) {$al = "$ref_base\t$alt_base_3";}
                                if ($genotype =~ /1\/1/) {$al = "$alt_base_1\t$alt_base_1";}
                                if ($genotype =~ /1\/2/) {$al = "$alt_base_1\t$alt_base_2";}
                                if ($genotype =~ /1\/3/) {$al = "$alt_base_1\t$alt_base_3";}
                                if ($genotype =~ /2\/2/) {$al = "$alt_base_2\t$alt_base_2";}
                                if ($genotype =~ /2\/3/) {$al = "$alt_base_2\t$alt_base_3";}
                                if ($genotype =~ /3\/3/) {$al = "$alt_base_3\t$alt_base_3";}

                                push(@pos_genotype, $al);

                                if ($_ == $ind_last_col) {
                                        my $line_info = join("\t",@pos_genotype);
                                        push(@complete_info, $line_info);
                                }
                        }
                }
        }

my $total=0;
my $gra_var=0;
my $gra_tim_fixed=0;

foreach(@complete_info){
        my @array = split("\t", $_);
        my @granatensis = splice(@array, $first_gra, $numb_gra);
        my @timidus = splice(@array, 0, $numb_tim);

# test variable sites in granatensis
        if (grep( /A/, @granatensis) && grep (/T/, @granatensis)) {$gra_var++; $total++;}
        elsif (grep( /A/, @granatensis) && grep (/C/, @granatensis)) {$gra_var++; $total++;}
        elsif (grep( /A/, @granatensis) && grep (/G/, @granatensis)) {$gra_var++; $total++;}
        elsif (grep( /T/, @granatensis) && grep (/C/, @granatensis)) {$gra_var++; $total++;}
        elsif (grep( /T/, @granatensis) && grep (/G/, @granatensis)) {$gra_var++; $total++;}
        elsif (grep( /C/, @granatensis) && grep (/G/, @granatensis)) {$gra_var++; $total++;}

# test fixed sites
        my @gra_all;
        my @tim_all;
        if (grep { /A/ } @granatensis) {push(@gra_all, "A");}
        if (grep { /T/ } @granatensis) {push(@gra_all, "T");}
        if (grep { /G/ } @granatensis) {push(@gra_all, "G");}
        if (grep { /C/ } @granatensis) {push(@gra_all, "C");}
        if (grep { /A/ } @timidus) {push(@tim_all, "A");}
        if (grep { /T/ } @timidus) {push(@tim_all, "T");}
        if (grep { /G/ } @timidus) {push(@tim_all, "G");}
        if (grep { /C/ } @timidus) {push(@tim_all, "C");}
        if (scalar(@gra_all) < 2 && scalar(@tim_all) && $gra_all[0], $tim_all[0]) {$gra_tim_fixed++;}
		
		else {$total++;}
        }

print "VAR.SITES GRAN: $gra_var", "\n";
print "FIXED GRA-TIM DIFFS: $gra_tim_fixed", "\n";
print "TOTAL SITES: $total", "\n";