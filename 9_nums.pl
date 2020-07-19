#!/usr/bin/perl
use Modern::Perl;
use Benchmark;
use Data::Dumper;

my $count = 1000;
my @array = sort { $a <=> $b }
			map { int( rand($count * $count) ) }
			( 1..$count ) ;
for ( my $i = 0; $i <= $#array; $i++ ){
	print "$i:$array[$i]\n";
}

my $num = int( rand($count * $count) );

print "\n\n\$num = $num\n";
sub manual_search {
	my $num = shift;
	
	return 0 if $num <= $array[0];
	return $#array if $num >= $array[-1];
	
	for ( my $i = 0; $i <= $#array; $i++ ){
		#print  "$i = $array[$i]\n";
		
		if ( $num == $array[$i] ){
			return $i;
		}
		
		if ( $num > $array[$i] ){
			return $i unless $array[$i+1];
			
			next if $num > $array[$i+1];
			 
			if ( $num - $array[$i] < $array[$i+1] - $num ) {
				return $i;
			}else {
				return $i+1;
			}
		}
		
		if ( $num < $array[$i] ){
			return $i unless $array[$i-1];
			
			next if $num < $array[$i-1];
			
			if ( $array[$i] - $num < $num - $array[$i-1] ) {
				return $i;
			} else {
				return $i-1;
			}
		}
	}
}

#print Dumper([@array[0..3]]);
my $steps;
sub recursive_search {
	my ($num, $start, $end ) = @_;
	die "Require start and end" unless defined $start && defined $end;
	$steps++;
	die "deeeeeep!" if $steps > $count;
	
	return $end if $num >= $array[$end];
	return $start if $num <= $array[$start];
	
	return $start if $start == $end;
	if ( $end - $start == 1){
		return $array[$end]-$num > $num-$array[$start]
				? $start
				: $end;
	}
	my $middle = int($start + ( $end - $start ) / 2 );
	if ( $num < $array[$middle] ){
		$end = $middle;
	} else {
		$start = $middle;
	}

	return recursive_search($num, $start, $end);
}

print "manual_search=>" . manual_search($num) . "\n";
print "recursive_search => " . recursive_search($num, 0, scalar(@array) -1 ) . "\n";


timethese(1000 => {
	'manual_search' => sub { manual_search($num); },
	'recursive_search' => sub { recursive_search($num, 0, scalar(@array) -1 ); },
	});
