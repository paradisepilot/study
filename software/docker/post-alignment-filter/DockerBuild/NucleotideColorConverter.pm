package NucleotideColorConverter;

use strict;
use warnings;
our $AUTOLOAD; # before Perl 5.6.0 say "use vars '$AUTOLOAD';"
use Carp;

### Creator method
sub new {
	my ($class) = @_;
	my $self = bless {}, $class;
	return $self;
}

### Converter Methods
sub base2cs {
	my ($self,$base_string) = @_;
	my $i;
	my $color_string = $base_string;
	for ($i = 1; $i<length($base_string); $i++) {
		substr($color_string,$i,1) = _dinucleotide2color(substr($base_string,$i-1,2));
	}
	return($color_string);
}

sub cs2base {
	my ($self,$color_string) = @_;
	my $i;
	my $base_string = $color_string;
	for ($i = 1; $i<length($base_string); $i++) {
		substr($base_string,$i,1) = _nucleotide_color_2_nucleotide(substr($base_string,$i-1,2));
	}
	return($base_string);
}

sub _dinucleotide2color {
	my ($dinucleotide) = @_;
	if ($dinucleotide eq 'AA' || $dinucleotide eq 'CC' || $dinucleotide eq 'GG' || $dinucleotide eq 'TT') { return('0'); }
	if ($dinucleotide eq 'AC' || $dinucleotide eq 'CA' || $dinucleotide eq 'GT' || $dinucleotide eq 'TG') { return('1'); }
	if ($dinucleotide eq 'AG' || $dinucleotide eq 'GA' || $dinucleotide eq 'CT' || $dinucleotide eq 'TC') { return('2'); }
	if ($dinucleotide eq 'AT' || $dinucleotide eq 'TA' || $dinucleotide eq 'CG' || $dinucleotide eq 'GC') { return('3'); }
}

sub _nucleotide_color_2_nucleotide {
	my ($nucleotide_color) = @_;
	if ($nucleotide_color eq 'A0' || $nucleotide_color eq 'C1' || $nucleotide_color eq 'G2' || $nucleotide_color eq 'T3') { return('A'); }
	if ($nucleotide_color eq 'A1' || $nucleotide_color eq 'C0' || $nucleotide_color eq 'G3' || $nucleotide_color eq 'T2') { return('C'); }
	if ($nucleotide_color eq 'A2' || $nucleotide_color eq 'C3' || $nucleotide_color eq 'G0' || $nucleotide_color eq 'T1') { return('G'); }
	if ($nucleotide_color eq 'A3' || $nucleotide_color eq 'C2' || $nucleotide_color eq 'G1' || $nucleotide_color eq 'T0') { return('T'); }
}

1;
