package CIGAR;

use strict;
use warnings;
our $AUTOLOAD; # before Perl 5.6.0 say "use vars '$AUTOLOAD';"
use Carp;

### Creator method
sub new {
	my ($class, $_cigar_string) = @_;

	$_cigar_string =~ s/=/E/g;
	my @_lengths = split(/[MIDNSHPEX]/, $_cigar_string);

	my $_operations_string = $_cigar_string;
	$_operations_string =~ s/[0-9]//g;
	my @_operations = split('',$_operations_string);

	my %_operation_total_length_hash = (
		'M'     => 0,
		'I'     => 0,
		'D'     => 0,
		'N'     => 0,
		'S'     => 0,
		'Hfive' => 0,
		'H'     => 0,
		'P'     => 0,
		'E'     => 0,
		'X'     => 0
	);

	if ($_operations[0] eq 'H') {
		$_operation_total_length_hash{'Hfive'} += $_lengths[0];		
	}

	my $_num_of_operations = scalar(@_operations);
	my $_i;
	for ($_i = 1 ; $_i<$_num_of_operations ; $_i++) {
		$_operation_total_length_hash{$_operations[$_i]} += $_lengths[$_i];
	}

	my $self = bless {
		_cigar_string => $_cigar_string,
		_M_total      => $_operation_total_length_hash{'M'},
		_I_total      => $_operation_total_length_hash{'I'},
		_D_total      => $_operation_total_length_hash{'D'},
		_N_total      => $_operation_total_length_hash{'N'},
		_S_total      => $_operation_total_length_hash{'S'},
		_H_5prime     => $_operation_total_length_hash{'Hfive'},
		_H_3prime     => $_operation_total_length_hash{'H'},
		_P_total      => $_operation_total_length_hash{'P'},
		_E_total      => $_operation_total_length_hash{'E'},
		_X_total      => $_operation_total_length_hash{'X'}
	}, $class;

	return $self;
}

### Accessor Methods
sub get_cigar_string { $_[0]->{_cigar_string}; }

sub get_M_total  { $_[0]->{_M_total};  }
sub get_I_total  { $_[0]->{_I_total};  }
sub get_D_total  { $_[0]->{_D_total};  }
sub get_N_total  { $_[0]->{_N_total};  }
sub get_S_total  { $_[0]->{_S_total};  }
sub get_H_5prime { $_[0]->{_H_5prime}; }
sub get_H_3prime { $_[0]->{_H_3prime}; }
sub get_P_total  { $_[0]->{_P_total};  }
sub get_E_total  { $_[0]->{_E_total};  }
sub get_X_total  { $_[0]->{_X_total};  }

1;
