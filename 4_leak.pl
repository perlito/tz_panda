use Modern::Perl;
use Devel::Leak;
use Scalar::Util qw(weaken);

my $handle;
my $count_before = Devel::Leak::NoteSV($handle);
say "count_before => $count_before";


# Из-за замыкания счетчик ссылок на $a не будет обнулятся при каждой итерации
# и память будет утекать. Для избежания можно явно очистить переменную перед
# выходом из итерации цыкла (undef $a) или сделать $a слабой ссылкой 

for (1..10) {
    my $a = {};
    $a->{func} = sub {
        $a->{cnt}++;
    };
    # undef $a;
    weaken($a);
}

my $count_after = Devel::Leak::CheckSV($handle);
say "count_after => $count_after";
