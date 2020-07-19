use Modern::Perl;
use FindBin;
use lib "$FindBin::Bin";

use MyApp::Child;

my $obj = MyApp::Child->new();

$obj->test("test_data");

say $obj->test();
$obj->test("test_data2");
say $obj->test();

1;
