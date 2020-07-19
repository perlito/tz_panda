use strict;
use warnings;
use Socket qw(:all);
use URI::Encode qw(uri_encode);
use Data::Dumper;

print Dumper( http_get('crazypanda.ru', '/ru', { ok => 1}) );

sub http_get {
	my ( $host, $path, $query, $timeout ) = @_;
	my $port = 80;
	$path ||= '/';
	$query ||= {};
	$timeout ||= 20;

	$path .= '?' . uri_encode( join('&',
									map{ "$_=$query->{$_}" } 
									keys %$query 
								   ) 
							)
			 if keys %$query;

	socket(my $socket, AF_INET,SOCK_STREAM, IPPROTO_TCP)
		or die "Cant create socket::$!";
	
	my $ip = gethostbyname($host) 
				or die "Cant get ip address for host $host";
	
	my $sa = sockaddr_in($port,$ip);
	
	connect($socket, $sa);
		
	my $request = "GET $path HTTP/1.1\nHost: $host\n\n";
	
	$socket->autoflush(1);

	print $socket $request;

	my $content_length;
	my $start_body;
	my %headers;
	my @body;
	
	my $rin = '';
	vec($rin, fileno($socket), 1) = 1;
	
	my ( $can_read ) = select($rin,undef,undef, $timeout);

	unless($can_read){
		return {
				code   => 504,
				status => 'Gateway Timeout',
				}
	}
	
	my $response = <$socket>;
	my ( $version, $code, $status ) = split(/\s/, $response);
	
	while(my $line = <$socket>){
		if ($line =~ /content-length:\s?(\d+)/i){
			$content_length = $1;
		}
		if ($line =~ /^\s+$/){
			die "Does not catch content-length" unless $content_length;
			$start_body = 1;
			next;
		}
		if ( $start_body ){
			$content_length -= length($line);
			push @body, $line;
			last if $content_length <= 0;
		} else {
			my ($header, $value) = ($line =~ /^(.+?):\s*(\S+)/);
			$headers{lc($header)} = lc($value);
		}
	}
		
	close($socket);

	return {body => join('', @body),
			code => $code, 
		  status => $status,
		 headers => \%headers,
		 }
}
