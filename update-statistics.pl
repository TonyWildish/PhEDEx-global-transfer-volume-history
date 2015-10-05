#!/usr/bin/env perl
use strict;
use warnings;

my ($file,$year,$month,$months,$text,$h,@data,@a);
my ($g,$instance,$days);
$file = 'All-PhEDEx-transfers.csv';

$months =
{
  '01' => 31,	'02' => 28,	'03' => 31,
  '04' => 30,	'05' => 31,	'06' => 30,
  '07' => 31,	'08' => 31,	'09' => 30,
  '10' => 31,	'11' => 30,	'12' => 31
 };

-f $file || die "No file '$file', spit the dummy!\n";

open FILE, "<$file" or die "open $file: $!\n";
while ( <FILE> ) {
  chomp;
  @a = split(',',$_);
  if ( $a[1] =~ m%^"(\d\d\d\d)-(\d\d)"$% ) {
    $year = $1;
    $month = $2;
    if ( $a[0] == $months->{$month} ||
         $a[0] == 29 && $month eq '02' && !($year%4) ) {
      $a[1] =~ s%"%%g;
      $h->{$a[1]}++;
      print "Read data up to $a[1]\r";
      push @data, $_;
    } else {
      print "\nSkipping $a[1] (month is incomplete)\n";
    }
  } else {
    push @data, $_;
  }
}
close FILE;

sub fetch {
  my ($instance) = shift;
  my ($response,$d,$server,$wget);

  $server = 'https://cmsweb.cern.ch/phedex/datasvc/perl';
  $wget = 'wget --no-check-certificate -O - --quiet';
  print "Fetching data for $instance\n";

  $response = `$wget $server/$instance/transferhistorysummary`;
  $response =~ s%^[^\$]*\$VAR1%\$VAR1%s; # get rid of stuff before $VAR1
  {
    no strict 'vars';
    $d = eval($response);
  }
  exists( $d->{PHEDEX}{TRANSFERHISTORYSUMMARY} ) or die "Bad response from $instance\n";
  return $d->{PHEDEX}{TRANSFERHISTORYSUMMARY};
}

use Data::Dumper;
foreach $instance ( qw( prod debug ) ) {
  foreach ( @{fetch($instance)} ) {
    if ( exists( $h->{$_->{TIMEBIN}} ) ) {
#     print "$_->{TIMEBIN}: already there\n";
    } else {
      if ( defined($_->{SUM_GIGABYTES}) ) {
        print "New data: $_->{TIMEBIN}\n";
        $g->{$_->{TIMEBIN}}{$instance} = $_->{SUM_GIGABYTES};
      }
    }
  }
}

foreach ( sort keys %{$g} ) {
  $g->{$_}{total} = $g->{$_}{prod} + $g->{$_}{debug};
  $_ =~ m%^(\d\d\d\d)-(\d\d)$%;
  $year = $1;
  $month = $2;
  @a = localtime;
  if ( ( $year == $a[5] + 1900 ) &&
       ( $month == $a[4]+1 ) ) {
    $days = $a[3];
  } else {
    $days = $months->{$month};
  }
  $text = "$days,\"$_\",0.00,0.00,0.00,0.00,0.00,0.00," .
           $g->{$_}{prod} . ',' .
           $g->{$_}{debug} . ',' .
           $g->{$_}{total};
  push @data, $text;
}

open FILE, ">$file.new" or die "open $file.new: $!\n";
foreach ( @data ) { print FILE $_,"\n"; }
close FILE;
print "All done!\n";
