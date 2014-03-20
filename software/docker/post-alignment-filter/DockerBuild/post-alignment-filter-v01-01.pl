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
my $best_alignment;
my $preceding_sam_alignment = $sam_alignment;

while ($line = <INPUTSAM>) {

	chomp($line);

	$sam_alignment = new SAMAlignment($line);

	# If the read ID of the current SAM record differs from that of the preceding SAM record,
	# then all SAM records for the preceding read ID have been read and we process @alignment_array,
	# which contains the passed-post-alignment-filter SAM records of the PRECEDING read ID.
	# This is done as follows: If @alignment_array is empty, then print an unmapped SAM record to
	# OUTPUT for the preceding read ID.  Otherwise, we extract the best-scoring record in
	# @alignment_array, and print that best-scoring record to OUTPUT, followed by emptying
	# @alignment_array
	if ($preceding_sam_alignment->get_qname() ne $sam_alignment->get_qname()) {
		if (0 < scalar(@alignment_array)) {
			$best_alignment = get_best_alignment(
				'alignment_array_ref'       => \@alignment_array,
				'reference_length_hash_ref' => \%reference_length_hash
				);
			if (4 == $best_alignment->get_flag()) {
				print( OUTPUTSAM $best_alignment->get_alignment_string() . "\tNH:i:0\n");
			} else {
				print( OUTPUTSAM $best_alignment->get_alignment_string() . "\tNH:i:1\n");
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
	$best_alignment = get_best_alignment(
		'alignment_array_ref'       => \@alignment_array,
		'reference_length_hash_ref' => \%reference_length_hash
		);
	if (4 == $best_alignment->get_flag()) {
		print( OUTPUTSAM $best_alignment->get_alignment_string() . "\tNH:i:0\n");
	} else {
		print( OUTPUTSAM $best_alignment->get_alignment_string() . "\tNH:i:1\n");
	}
} else {
	print( OUTPUTSAM generate_unmapped_SAMAlignment_object($preceding_sam_alignment)->get_alignment_string() . "\tNH:i:0\n");
}

close(OUTPUTSAM);
close(LOG);

####################################################################################################
####################################################################################################

sub get_best_alignment {

	my %args = (@_);

	my @alignment_array       = @{$args{'alignment_array_ref'}};
	my %reference_length_hash = %{$args{'reference_length_hash_ref'}};

	my $best_alignment_score = -10000;
	my @best_alignment_array = ();

	my $random_index;
	my $best_alignment;

	my $temp_alignment;
	my $temp_alignment_score;
	my $temp_alignment_string;

	for $temp_alignment (@alignment_array) {
		$temp_alignment_score = ${$temp_alignment->get_optional_fields_ref()}{'AS'};
		if ($temp_alignment_score > $best_alignment_score) {

			$best_alignment_score = $temp_alignment_score;
			@best_alignment_array = ();
			push(@best_alignment_array, $temp_alignment);

		} elsif ($temp_alignment_score == $best_alignment_score) {

			# if $temp_alignment_score equals the current $best_alignment_score, then
			# (i)   check whether the two alignment records ($temp_alignment and $best_alignment),
			#       apart from the fields RNAME and POS , are identical,
			# (ii)  if so, check whether the length of the reference sequence in $temp_alignment is
			#       strictly shorter than the length of the reference sequence in $best_alignment,
			# if both (i) and (ii) hold, then we interpret them together to be an indication of the
			# scenario that the reference sequence in $temp_alignment is a subsequence of that in
			# $best_alignment.  As a result, we regard $temp_alignment to be a better alignment
			# than the current $best_alignment.
			# Hence, we replace $best_alignment with $temp_alignment.

			$temp_alignment_string = remove_RNAME_and_POS($temp_alignment->get_alignment_string());
			my $i     = 0;
			my $found = 0;
			while (0 == $found && $i < scalar(@best_alignment_array)) {
				if ( $temp_alignment_string eq remove_RNAME_and_POS($best_alignment_array[$i]->get_alignment_string()) ) {
					$found = 1;
					if ($reference_length_hash{$temp_alignment->get_rname()} < $reference_length_hash{$best_alignment_array[$i]->get_rname()}) {
						$best_alignment_array[$i] = $temp_alignment;
					}
				}
				$i++;
			}

			if (0 == $found) { push(@best_alignment_array, $temp_alignment); }

		}
	}

	if (1 == scalar(@best_alignment_array)) {
		return($best_alignment_array[0]);
	} else {
		print( LOG "##########\n" );
		for $temp_alignment (@best_alignment_array) {
			print( LOG $temp_alignment->get_alignment_string()."\n" );
		}
		return( generate_unmapped_SAMAlignment_object($best_alignment_array[0]) );
	}

}

sub remove_RNAME_and_POS {
	my ($sam_alignment_string) = @_;
	my @temp_array = split(/\t/,$sam_alignment_string);
	@temp_array = @temp_array[0,1,4..(scalar(@temp_array)-1)];
	return(join("\t",@temp_array));
}

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

