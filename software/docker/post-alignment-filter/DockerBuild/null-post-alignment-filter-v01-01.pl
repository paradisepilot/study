#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use Data::Dumper;
use SAMAlignment;
use CIGAR;

####################################################################################################
####################################################################################################

my $inputSAM;
my $outputSAM;
my $logFile;
GetOptions(
	'i|inputSAM=s'  => \$inputSAM,
	'o|outputSAM=s' => \$outputSAM,
	'l|log=s'       => \$logFile
	);

####################################################################################################
####################################################################################################

my %reference_length_hash = ();

# count the number of header lines in inputSAM
open( INPUTSAM, "<",  $inputSAM);

my $line;
my @temp_array;
my $referenceID;
my $num_of_header_lines = 0;
while ($line = <INPUTSAM>) {
	chomp($line);
	if ($line =~ /^@/) {
		$num_of_header_lines++;
		if ($line =~ /^\@SQ/) {
			@temp_array = split(/\t/,$line);
			$referenceID = (split(/:/,$temp_array[1]))[1];
			$reference_length_hash{$referenceID} = (split(/:/,$temp_array[2]))[1];
		}
	} else {
		last;
	}
}

close(INPUTSAM);

####################################################################################################

open( INPUTSAM, "<",  $inputSAM);
open(OUTPUTSAM, ">", $outputSAM);
open(LOG,       ">",   $logFile);

# scroll through the header lines; print each to outputSAM
my $count;
for ($count = 0; $count < $num_of_header_lines ; $count++) {
	$line = <INPUTSAM>;
	chomp($line);
	print( OUTPUTSAM $line . "\n");
}

my @alignment_array = ();

# read this first SAM entry
$line = <INPUTSAM>;
chomp($line);
my $sam_alignment = new SAMAlignment($line);

# If the first SAM record is NOT an unmapped record, and it passes post-alignment-filter,
# then push it in @alignment_array.
if (4 != $sam_alignment->get_flag() && 1 == passed_post_alignment_filter($sam_alignment)) {
	push(@alignment_array, $sam_alignment);
}

# begin loop to process the rest of the SAM records
my $temp_alignment;
my $preceding_sam_alignment = $sam_alignment;

while ($line = <INPUTSAM>) {

	chomp($line);

	$sam_alignment = new SAMAlignment($line);

	if ($preceding_sam_alignment->get_qname() ne $sam_alignment->get_qname()) {
		if (0 < scalar(@alignment_array)) {
			$count = 1;
			for $temp_alignment (@alignment_array) {
				print( OUTPUTSAM $temp_alignment->get_alignment_string() . "\tNH:i:".$count."\n");
				$count++;
			}
		} else {
			print( OUTPUTSAM generate_unmapped_SAMAlignment_object($preceding_sam_alignment)->get_alignment_string() . "\tNH:i:0\n");
		}
		@alignment_array = ();
	}

	# Next, we check whether the current SAM record passes post-alignment filter.
	# If so, push it in @alignment_array.
	if (4 != $sam_alignment->get_flag() && 1 == passed_post_alignment_filter($sam_alignment)) {
		push(@alignment_array, $sam_alignment);
	}

	$preceding_sam_alignment = $sam_alignment;

}

close(INPUTSAM);

# Lastly, we process @alignment_array for the last read ID.
if (0 < scalar(@alignment_array)) {
	$count = 1;
	for $temp_alignment (@alignment_array) {
		print( OUTPUTSAM $temp_alignment->get_alignment_string() . "\tNH:i:".$count."\n");
		$count++;
	}
} else {
	print( OUTPUTSAM generate_unmapped_SAMAlignment_object($preceding_sam_alignment)->get_alignment_string() . "\tNH:i:0\n");
}

close(OUTPUTSAM);
close(LOG);

####################################################################################################
####################################################################################################

sub passed_post_alignment_filter {
	my ($sam_alignment) = @_;

	# if first aligned position on the reference sequence >= 2, then return 0.
	my $position = $sam_alignment->get_pos();
	if (1 < $position) { return(0); }

	# if edit distance of alignment >= 2, then return 0.
	my $edit_distance = ${$sam_alignment->get_optional_fields_ref()}{'NM'};
	if (1 < $edit_distance) { return(0); }

	# if number of hard-clipped positions at 5-prime end on the read >= 2, then return 0.
	# if number of hard-clipped positions at 3-prime end on the read >= 2, then return 0.
	my $cigar = new CIGAR($sam_alignment->get_cigar());
	if (1 < $cigar->get_H_5prime()) { return(0); }
	if (1 < $cigar->get_H_3prime()) { return(0); }

	# if the number of colour-space mismatches of the alignment is >= 3, then return 0.
	my $num_of_color_space_mismatches = ${$sam_alignment->get_optional_fields_ref()}{'CM'};
	if (2 < $num_of_color_space_mismatches) { return(0); }

	## if number of soft-clipped positions on the read >= 2, then return 0.
	#if (1 < $cigar->get_S_total())  { return(0); }

	#my $crossover  = ${$sam_alignment->get_optional_fields_ref()}{'XX'};
	#my $crossover0 = $crossover;
	#$crossover =~ s/[A-Z]//g;
	#if (2 < length($crossover)) {
	#	#print($sam_alignment->get_qname()." ## ".$sam_alignment->get_rname()." ## ".$crossover0." ## ".$crossover."\n");
	#	return(0);
	#}

	return(1);
}

sub generate_unmapped_SAMAlignment_object {
	my ($sam_alignment) = @_;
	my $tempstring = $sam_alignment->get_qname();
	$tempstring .= "\t4\t*\t0\t0\t*\t*\t0\t0\t*\t*\tCQ:Z:*";
	$tempstring .= "\tCS:Z:" . ${$sam_alignment->get_optional_fields_ref()}{'CS'};
	my $temp_sam_alignment = new SAMAlignment($tempstring);
	return($temp_sam_alignment);
}

