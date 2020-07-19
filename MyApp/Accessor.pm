package MyApp::Accessor;
use strict;
use warnings;

sub import {
	my %restrict = (
						 attr => undef, 
				          new => undef,
				     AUTOLOAD => undef,
				      DESTROY => undef,
				        BEGIN => undef,
				    UNITCHECK => undef,
				        CHECK => undef,
				         INIT => undef,
				          END => undef,
				   );

	no strict 'refs';    
	my $pkg = ( caller )[0];
	
	*{"$pkg\::attr"} = 
				sub {  my $method = shift;

						die "Incorrect accessor name :: $method "
							if exists $restrict{$method};
							
						*{ "$pkg\::$method" } = 
							sub { my ( $self, $arg ) = @_;
								  if ($_[1]){
									  $_[0]->{$method} = $_[1];
								  } 
								  return $_[0]->{$method}; 
								};
					  };
					  
}


sub new {
	return bless {}, shift; 
}

1;
