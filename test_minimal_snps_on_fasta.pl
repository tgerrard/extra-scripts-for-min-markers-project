#!/usr/bin/perl


open(MARKERSET, "$ARGV[0]");


$headfile = $ARGV[0];

open(FULLDATA, "$ARGV[1]");

open(OUT, ">predicted_kasp_genotypes.tdt");

$head = <MARKERSET>;

while(<MARKERSET>)
{
chomp;
($n, $n2, $marker, $data) = split(/\t/, $_); @data = split(//, $data); $train = @data;
$marker =~ s/Base_(\d+).*/$1/;
$markers{$marker}++;
#print "1 $marker\n";
}


while($line = <FULLDATA>)
{
chomp $line;
if($line =~ />(.*)/){$id = $1;}
else{$lookup{$id}.=$line;}
}

$n = keys %lookup;
$total = $n*($n -1)/2;


foreach $id(sort{$a<=>$b} keys %lookup)
{
$pos++;
$id2pos{$id}=$pos; 
$seq = $lookup{$id};
@seq = split(//, $seq);
foreach $marker(keys %markers){$coord = $marker-1;  $final{$id}{$marker} = $seq[$coord];}
}


#foreach $marker( keys %markers){print "\t$marker";}
#print "\n";
foreach $id1(sort {$a<=>$b} keys %final)
{
#print "$id1";
foreach $id2(sort {$a<=>$b} keys %final)
{
if($id2pos{$id2} > $id2pos{$id1}){$diff{$id1}{$id2} = 0;}
}
}





#foreach $marker( keys %markers){print "\t$marker";}
#print "\n";
foreach $id1(sort {$a<=>$b} keys %final)
{
#print "$id1";
foreach $id2(sort {$a<=>$b} keys %final)
{
if($id2pos{$id2} > $id2pos{$id1})
{
foreach $marker(keys %markers)
{
if($final{$id1}{$marker} =~ /[CAGT]/ && $final{$id2}{$marker} =~ /[CAGT]/ && $final{$id1}{$marker} ne $final{$id2}{$marker}){$diff{$id1}{$id2}=1;}
}
}
}
}

#foreach $id(keys %final){print "\t$id";}
#print "\n";


foreach $id(keys %final)
{
#print "$id";
foreach $id2(keys %final)
{
#print "\t$diff{$id}{$id2}"; 
$resolved+= $diff{$id}{$id2}; 
}
#print "\n"; 
}
$percent = 100*(int(10000* ($resolved/$total))/10000);

print "Marker file\tTest sequence file\tResolved\tTotal\tPercent\n";
print "$ARGV[0]\t$ARGV[1]\t$resolved\t$total\t$percent\n";
