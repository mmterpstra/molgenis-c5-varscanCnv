#!/usr/bin/perl
use strict;
use warnings;
my $use = <<"END";
	converts parameters files
	param,value
	param2,value2
	to
	param,param2
	value,value2
	for molgenis
	
	use: $0 parameters.csv > parameters.molgenis.csv
END
die $use if(scalar(@ARGV)==0);
die "$ARGV[0] does not exist. Is it a file? \n".$use if(not( -e $ARGV[0]));
my @param; my @val;
while(<>){
	chomp;
	my $param; my $val;
	($param, $val)=split(",");
	push(@param, $param);
	push(@val,$val);
}
print join(",",@param)."\n";
print join(",",@val)."\n";
