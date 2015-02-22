use strict; # help you to keep track of variable names and scope

## command line should be as follows: convert_introgression_blocks.pl <inp_file> <window_size>
my $FILE = $ARGV[0];
my $WIN_SIZE = $ARGV[1];

my @introg;

open (FILE, '<', $FILE) or die "can't open $FILE $!\n";
while (my $line = <FILE>) {
	
	my $state;
	my @cols = split("\,", $line); ## separate columns
	if ($cols[0] eq 'p1') {$state=0; push(@introg,$state);}
	if ($cols[0] eq 'p2') {$state=1; push(@introg,$state);}
	}


my @final_int;
my $count=1;
my $sum=0;

foreach (@introg) {
	
	if ($count < $WIN_SIZE) {
		$sum= $sum + $_;
		$count++;
		}
		
	elsif ($count = $WIN_SIZE) {
		$sum= $sum + $_;
		my $mean=$sum/$WIN_SIZE;
		push(@final_int,$mean);
		$count=1;
		$sum=0;
		}		
	}


print join("\n", @final_int);