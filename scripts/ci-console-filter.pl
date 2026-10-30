#!/usr/bin/env perl
# Console view of a CI log: drops high-volume lines whose full copy is archived, then reports what it dropped.
# Usage: <cmd> 2>&1 | tee <full log> | perl scripts/ci-console-filter.pl <archived path>
use strict;
use warnings;

$| = 1;
my $archive = shift // 'ci-logs/';
# Whole lines only; non-2xx Dio status lines and failed Gradle tasks stay visible.
my @rules = (
    [getx     => qr/dart\.developer\.log \{message: .*, name: GETX, level: 0\}$/],
    [dio      => qr/^(?:\*\*\* (?:Request|Response) \*\*\*$|(?:uri|method|responseType|followRedirects|persistentConnection|connectTimeout|sendTimeout|receiveTimeout|receiveDataWhenStatusError|extra): |statusCode: 2\d\d$|headers:$|data:$| (?:accept(?:-[a-z]+)?|authorization|cache-control|connection|content-[a-z-]+|access-control-[a-z-]+|date|etag|expires|host|location|origin|pragma|referer|server|set-cookie|transfer-encoding|user-agent|vary|www-authenticate|x-[a-z-]+): |\{using: \[)/],
    [gradle   => qr/^\s*: > Task (?!.*FAILED)/],
    [dwds     => qr/Loaded debug metadata/],
    [teardown => qr/PatrolBinding: tearDown\(\): count/],
);
my %dropped;
my $last_blank = 0;
LINE: while (my $line = <STDIN>) {
    for my $rule (@rules) {
        if ($line =~ $rule->[1]) {
            $dropped{$rule->[0]}++;
            next LINE;
        }
    }
    # Dropped Dio blocks leave runs of blank lines; keep one.
    my $blank = $line =~ /^\s*$/ ? 1 : 0;
    if ($blank && $last_blank) {
        $dropped{blank}++;
        next LINE;
    }
    $last_blank = $blank;
    print $line;
}
my $total = 0;
$total += $_ for values %dropped;
print "[console-filter] dropped $total lines (",
    join(', ', map { "$_=" . ($dropped{$_} // 0) } qw(getx dio gradle dwds teardown blank)),
    "); full log: $archive\n";
