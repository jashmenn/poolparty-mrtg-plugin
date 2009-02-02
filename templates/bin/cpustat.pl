#!/usr/bin/perl

@line = `/usr/local/bin/sar | /usr/bin/tail -n 2 | /usr/bin/head -n 1 | /bin/sed 's/\ \ */ /g'`;

@data = split(/ /, @line[0]);
if (@data[2] eq "") {
printf "0\n";
}else {
printf ("%3.0f\n", @data[2] + 0.5);
}
printf ("%3.0f\n", (@data[3])+(@data[2])+(@data[4]+0.5));

$uptime = `/usr/bin/uptime | sed 's/\ \ */ /g'`;
@uptime = split(/,/, $uptime);
@uptime = split(/up/, @uptime[0]);
$server = `/bin/uname -n`;
printf "@uptime[1]\n";
printf $server;



