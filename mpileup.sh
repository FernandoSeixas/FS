## add read groups
cat files.txt | cut -d '.' -f1 | xargs -I {} -n 3 -P 1 sh -c 'java -jar /illumina/hybridadapt/software/picard-tools-1.122/AddOrReplaceReadGroups.jar I=$2.clipped.bam O=$2.RG.bam RGID=$2 RGLB=CibioLib1 RGPL=illumina RGPU=$1 RGSM=$0 RGCN=CIBIO RGDT=2014-12'


== Pipeline for SNP calling, filtering for quality and indel buffering ==
## create bcf per chromosome ##
cat ocn_chromosomes.txt | grep '>' | sed 's/^>//g' | xargs -I {} -n 1 -P 3 sh -c 'samtools mpileup -ug -r {} -f /home/fernandoseixas/hybridadapt/bowtie2-2.2.3/Ocn_default.fa -b /home/fernandoseixas/hybridadapt/bam_input_files --output {}.file'
#/illumina/hybridadapt/software/samtools-1.1/samtools mpileup -q 20 -Q 20 -ug -f ../Ocn_default.fa -b bam_input_files --output ###.bcf

## create vcf (call genotypes - only variant sites and no indels)
# bcftools call -vm -V indels -o ###.vcf ###.bcf
cat ocn_chromosomes.txt | grep '>' | sed 's/^>//g' | xargs -I {} -n 1 -P 3 sh -c 'bcftools call -vm -V indels -o {}.vcf {}.bcf'


== pipeline to get filtering snps and phase data ==
# 1.1 # filter for at most biallelic sites
bcftools view -M2 -o <outfile> <infile>
# 1.2 # filter by MQ (-Q) and total base depth (-d)
vcfutils.pl varFilter -Q 10 -d 10 <infile> > <outfile>
# 1.3 # convert vcf to fastphase.inp
/home/fernandoseixas/software/vcf-conversion-tools-master/vcf2fastPHASE.pl 2.3.chr21_var.filter.vcf.gz file.inp file.pos 15
# 1.4 # run fastPhase without imputation
/home/fernandoseixas/software/fastPHASE/fastPHASE_Linux -usubpops.inp -ochr21_var.phased -g file.inp
# 1.5 # convert phase output back to vcf
/home/fernandoseixas/software/snpcalling/vcf-conversion-tools-master/fastPHASE2VCF.pl <phase input> <phase output> <original VCF> <synteny block number> 
/home/fernandoseixas/software/snpcalling/vcf-conversion-tools-master/fastPHASE2VCF.pl file.inp <phase output> 2.3.chr21_var.filter.vcf.gz 1 


== alternatives ==
# filter by SNPcall quality
## bcftools filter -o <outfile> -i'%QUAL>10' <infile>
## bcftools filter -o test.vcf -i'%INFO/MQ>10' <infile>
