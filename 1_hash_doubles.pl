use strict;
use warnings;
use Benchmark qw(:all);

my %h;
for (1..1e6){
	$h{$_} = int(rand(100000));
}

# my %h = (....); delete_repeated_values(\%h);
sub delete_repeated_values {
	my $hash = shift;
	
	my %hash2;
	for ( keys %{$hash} ) {
		if ( exists $hash2{ $hash->{$_} } ){
			delete $hash->{$_};
			next;
		}
		$hash2{ $hash->{$_} } = undef;
	}
}

sub _reverse {
	my $hash = shift;
	my %hash2 = reverse %{ $hash };
	%{ $hash } = reverse %hash2;
}

sub _reverse_with_copy {
	my %hash = @_;
	my %hash2 = reverse %hash;
	return reverse %hash2;
}

my %h1 = %h;
my %h2 = %h;
my %h3 = %h;

timethese(10000 => {
	'delete_repeated_values' => sub { delete_repeated_values(\%h1); },
	'reverse' 				 => sub { _reverse(\%h2); },
	'revrese_with_copy' 	 => sub { %h3 = _reverse_with_copy(%h3) },
	});

__END__

delete_repeated_values(\%h1);
_reverse(\%h2);
%h3 = _reverse_with_copy(%h3);

print "@{[ scalar(keys %h1) ]} => @{[  scalar(keys %h2) ]} => @{[ scalar(keys %h3) ]}\n";

$ perl 1_hash.pl 
Benchmark: timing 10000 iterations of delete_repeated_values, reverse, revrese_with_copy...
delete_repeated_values: 1035 wallclock secs (1033.54 usr +  0.04 sys = 1033.58 CPU) @  9.68/s (n=10000)
   reverse: 1578 wallclock secs (1576.08 usr +  0.33 sys = 1576.41 CPU) @  6.34/s (n=10000)
revrese_with_copy: 2692 wallclock secs (2689.53 usr +  0.06 sys = 2689.59 CPU) @  3.72/s (n=10000)


