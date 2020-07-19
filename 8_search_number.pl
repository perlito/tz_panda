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

sub search_num {
	my ($num, $start, $end ) = @_;
	$start //= 0;
	$end //= $#array;

	# debug
	#state $step = 0;
	#$step++;
	#say "step: $step, $start, $end";
	
	return $end   if $num >= $array[$end];
	return $start if $num <= $array[$start];
	return $start if $start == $end; 

	my $middle_position = int( ( $end - $start ) / 2 ) + $start;
	
	if ( $num == $array[$middle_position] ){
		return $middle_position;
	}
	elsif ( $num > $array[$middle_position] ){
		if ( $num < $array[$middle_position+1] ){
			return $array[$middle_position+1] - $num > $num - $array[$middle_position]
					? $middle_position
					: $middle_position+1;
		}
		
		return search_num( $num, $middle_position, $end );
	}
	else {
		if ( $num > $array[$middle_position-1] ){
			return $num - $array[$middle_position-1] < $array[$middle_position] - $num
					? $middle_position-1
					: $middle_position;
		}
		
		return search_num( $num, $start, $middle_position );
	} 
}


sub manual_search {
	my $num = shift;
	
	return 0 if $num <= $array[0];
	return $#array if $num >= $array[-1];
	
	for ( my $i = 0; $i <= $#array; $i++ ){
				
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


my $manual_rearch_idx = manual_search($num);
my $search_num_idx    = search_num($num); 

say "manual_search => $manual_rearch_idx : $array[$manual_rearch_idx]";
say "search_num => $search_num_idx : $array[$search_num_idx]";

timethese(100000 => {
	'manual_search' => sub { manual_search(int( rand($count * $count) )); },
	'search_num' 	=> sub { search_num(int( rand($count * $count) )); },
	});
