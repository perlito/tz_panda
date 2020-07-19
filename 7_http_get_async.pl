use Modern::Perl;
use Socket qw(:all);
use URI::Encode qw(uri_encode);
use Fcntl qw(F_GETFL F_SETFL O_NONBLOCK);
use Errno qw(EWOULDBLOCK);
use Time::HiRes qw(ualarm);
use Data::Dumper;

print Dumper( http_get_async('crazypanda.ru','/', {ku => "ok"}, 1) );

sub http_get_async {
    my ( $host, $path, $query, $timeout ) = @_;
    my $port = 80;
    $path ||= '/';
    $query ||= {};
    $timeout ||= 20;

	$host =~ s{^https?://}{};
	
    socket(my $socket, AF_INET,SOCK_STREAM, IPPROTO_TCP)
        or die "Cant create socket::$!";

    my $ip = gethostbyname($host)
                or die "Cant get ip address for host $host";

    my $sa = sockaddr_in($port,$ip);

    connect($socket, $sa);

    $path .= '?' . uri_encode( join('&',
                                    map{ "$_=$query->{$_}" }
                                    keys %$query
                                   )
                            )
             if keys %$query;

    my $request = "GET $path HTTP/1.1\nHost: $host\n\n";

	syswrite($socket,$request);
	
    my $flags = fcntl($socket, F_GETFL, 0)
        or die "Can't get flags for the socket: $!\n";

    fcntl($socket, F_SETFL, $flags | O_NONBLOCK)
        or die "Can't set O_NONBLOCK for the socket: $!\n";

    my $response;
    my $content_length;
    my $body;
    my $response_hash;

    eval {
        local $SIG{ALRM} = sub { die "TIMEOUT\n" };
        ualarm(1000_000 * $timeout);
        while(1){
            my $read = sysread($socket, my $buf, 10);

            if ( defined $read ){
                if ( $read > 0 ){
                    if (defined $body){
                        $body .= $buf;
                        if ( length($body) >= $response_hash->{headers}->{'content-length'} ){
							ualarm(0);
							close($socket);
							last;
						}
                    }
                    else {
                        $response .= $buf;
                    }

                    # Catching headers end
                    if ( $response =~ /\015\012\015\012/ ){
                        my $headers;

                        ( $headers, $body ) = split(/\015\012\015\012/, $response );
                        $response = '';
                        $body //= '';
                        $response_hash = parse_headers($headers);

                        die "Cant define content-length"
                            unless defined $response_hash->{headers}->{'content-length'};
                    }
                } else {
                    ualarm(0);
                    close($socket);
                    last;
                }
            }
            elsif ( $! == EWOULDBLOCK ){
                fill_array();
            } else {
                die "ERROR::$!";
            }
        }
    };

    if ( $@ ){
        die $@ unless $@ eq "TIMEOUT\n";
        $response_hash = {
                          code   => 504,
                          status => 'Gateway Timeout',
                        };

        close($socket);

    } else {
        $response_hash->{body} = $body;
    }

    fill_array(1);
    return $response_hash;
}

sub fill_array {
    state $step;
    state @array;
    if (@_){
        print "Array filled  by [ @{[ scalar(@array) ]} ] elements\n";
        return;
    }
    push @array, ++$step;
}

sub parse_headers {
    my ($headers_string) = @_;
    my @headers = split(/\015\012/, $headers_string);

    my ( $version, $code, $status ) = split(/\s/, shift @headers);
    my %headers = map { my $line = $_;
                        my ($header, $value) = ($line =~ /^(.+?):\s*(\S+)/);
                        lc($header) => $value;
                      }
                  @headers;

    return {code => $code,
          status => $status,
         headers => \%headers,
            };
}


