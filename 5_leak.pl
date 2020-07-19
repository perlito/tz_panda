use Modern::Perl;
use Devel::Leak;
use Scalar::Util qw(weaken);
use Scope::Guard;

# Способ 1, Применить слабые ссылки

my $handle;
my $count_before = Devel::Leak::NoteSV($handle);
say "count_before => $count_before";

for (1..5) {
    my $a = {b => {}};
    $a->{b}{a} = $a;
    weaken($a->{b});
}

my $count_after = Devel::Leak::CheckSV($handle);
say "count_after => $count_after";

say "\n\n\n";

# Способ 2, очистить переменную при выходе, можно явно сделать undef($a->{b}),
# но можно и через деструктор( метод DESTROY ), Создав guard
 
my $handle2;
my $count_before2 = Devel::Leak::NoteSV($handle2);
say "count_before => $count_before2";

for (1..5) {
    my $a = {b => {}};
    my $guard = Scope::Guard->new(sub { undef $a->{b} });
    $a->{b}{a} = $a;
}

my $count_after2 = Devel::Leak::CheckSV($handle2);
say "count_after => $count_after";
