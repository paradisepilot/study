package SAMAlignment;

use strict;
use warnings;
our $AUTOLOAD; # before Perl 5.6.0 say "use vars '$AUTOLOAD';"
use Carp;

### Creator method
sub new {
	my ($class,$sam_alignment_string) = @_;

	my @fields = split(/\t/,$sam_alignment_string);
	
	my %optional_fields_hash = ();
	my @temp_array;
	if (scalar(@fields)>11) {
		my @optional_fields = @fields[11..(scalar(@fields)-1)];
		my $optional_field;
		foreach $optional_field (@optional_fields)	{
			@temp_array = split(/:/,$optional_field);
			if (scalar(@temp_array)==3) {$optional_fields_hash{$temp_array[0]} = $temp_array[2]; }
		}	
	}

	my $self = bless {
		_alignment_string    => $sam_alignment_string,
		_qname               => $fields[0], 
		_flag                => $fields[1], 
		_rname               => $fields[2], 
		_pos                 => $fields[3], 
		_mapq                => $fields[4],
		_cigar               => $fields[5],
		_rnext               => $fields[6],
		_pnext               => $fields[7],
		_tlen                => $fields[8],
		_seq                 => $fields[9],
		_qual                => $fields[10],
		_optional_fields_ref => \%optional_fields_hash
	}, $class;

	return $self;
}

### Accessor Methods
sub get_alignment_string { $_[0]->{_alignment_string}; }
sub set_alignment_string {
	my ($self,$alignment_string) = @_;
	$_[0]->{_alignment_string} = $alignment_string if $alignment_string;
}

sub get_qname { $_[0]->{_qname}; }
sub set_qname {
	my ($self,$qname) = @_;
	$_[0]->{_qname} = $qname if $qname;
}

sub get_flag { $_[0]->{_flag}; }
sub set_flag {
	my ($self,$flag) = @_;
	$_[0]->{_flag} = $flag if $flag;
}

sub get_rname { $_[0]->{_rname}; }
sub set_rname {
	my ($self,$rname) = @_;
	$_[0]->{_rname} = $rname if $rname;
}

sub get_pos { $_[0]->{_pos}; }
sub set_pos {
	my ($self,$pos) = @_;
	$_[0]->{_pos} = $pos if $pos;
}

sub get_mapq { $_[0]->{_mapq}; }
sub set_mapq {
	my ($self,$mapq) = @_;
	$_[0]->{_mapq} = $mapq if $mapq;
}

sub get_cigar { $_[0]->{_cigar}; }
sub set_cigar {
	my ($self,$cigar) = @_;
	$_[0]->{_cigar} = $cigar if $cigar;
}

sub get_rnext { $_[0]->{_rnext}; }
sub set_rnext {
	my ($self,$rnext) = @_;
	$_[0]->{_rnext} = $rnext if $rnext;
}

sub get_pnext { $_[0]->{_pnext}; }
sub set_pnext {
	my ($self,$pnext) = @_;
	$_[0]->{_pnext} = $pnext if $pnext;
}

sub get_tlen { $_[0]->{_tlen}; }
sub set_tlen {
	my ($self,$tlen) = @_;
	$_[0]->{_tlen} = $tlen if $tlen;
}

sub get_seq { $_[0]->{_seq}; }
sub set_seq {
	my ($self,$seq) = @_;
	$_[0]->{_seq} = $seq if $seq;
}

sub get_qual { $_[0]->{_qual}; }
sub set_qual {
	my ($self,$qual) = @_;
	$_[0]->{_qual} = $qual if $qual;
}

sub get_optional_fields_ref { $_[0]->{_optional_fields_ref}; }
sub set_optional_fields_ref {
	my ($self,$optional_fields_ref) = @_;
	$_[0]->{_optional_fields_ref} = $optional_fields_ref if $optional_fields_ref;
}

1;
