#!/usr/bin/perl


#Set a minumum frequency for the minor allele so you don't bother outputting SNP positions with only a single representative of the minor alleys (likely to be a sequencing error)
$min_minor = 2;



#The input file name is captured as the first command line argument
$file = $ARGV[0];
chomp $file;
open(IN, "$file");


#The output file will have _genotypes.csv appended to the infield name and will be in comma separated format.
$out = "${file}_genotypes.csv";
open(OUT, ">$out");

print OUT "code";


#While loop to read the input FASTA file
while(<IN>)
{
chomp;

#If you encounter a ">" this will be a sequence name line so print out whatever comes after ">" to the output file header
if(/>(.*)/)
  {
  $id = $1;  print OUT "\,$id";
  $j++;
  }

#Otherwise this must be a sequence, in which case split it into an array
else
 {
 @seq_array = split(//,$_);
 
#Now go through that array and make hash, keyed by the current sequence position and add the genotype of the current variety to that string.
$i = 0;
 foreach $base(@seq_array){$genotypes{$i}.=$base; $i++;}
 }
}

#All done reading the input
close IN;
print OUT "\n";

#Print some basic stats to the screen
$n = keys %genotypes;
print "Loaded $n  genotypes from $j sequences\n";

#Now work through every sequence position and analyse the base content from all the varieties at this spot. 
foreach $pos(sort {$a<=>$b} keys %genotypes)
{
%bases = ();
%ordered =();
@ary = ();

#The $genoype variable will contain the concatenated bases from all varieties at the current position
$genotype = $genotypes{$pos};

#Split this string into an array
@bases = split(//, $genotype);

#Now make a hash of all the bases in the array and increment (++) the count of each as it's encountered, as long as it's either a c,a,t or g - ambiguities and gaps won't count
foreach $base(@bases){if($base =~ /[catg]/i){$bases{$base}++;}}

#Make another hash, ordered by the base frequency so we can go on to find the two most common alleles
foreach $base (keys %bases)
  { 
  $n = $bases{$base};
  #Add the current base to this count in a 2D arrat- this is necessary in case we have a tie for allele frequency between the first two bases 
  $ordered{$n}{$base}++;
  push @ary, $n;
  }

#Prepare an array sorted by the lowest to highest allele frequencies so we can then take the last two entries as being the major and minor alleles 
@ary = sort({$a<=>$b} @ary);
$i = 0;

$alleles_count = keys %bases;

#Ignore all monomorphic positions now and only look at those with at least two alleles.
if($alleles_count >1)
{
#Ignore the 3rd most frequent allele onwards as we're normally only interested in bi-allelic SNPs.
while($i < 2)
  {
  #Get the last entry from this sorted array, so the biggest allele count first, then the second biggest
  $n = pop @ary;
  $ref = $ordered{$n};
  %hash = %$ref;
  
  #Find all the alleles with this count: there will only be one per pass unless the two most common alleles are tied for count
  foreach $base(keys %hash)
     {
      #Substitute the most common base with "0" and the next with "1"
     $genotype =~ s/$base/$i/g;
     if($i == 1){$minor = $n;}  
     $i++;
     }

  }
#Finally, substitute anything not already converted to ) or 1 with an x so it will be ignored
$genotype =~ s/[^01]/x/g;
@genotype = split(//, $genotype);
$genotype = join("\,", @genotype);
#$position is $pos +1 so that the sequence positions start with 1 rather than zero.
$position = $pos+1;

#Check this row meets the minor allele frequency cutoff and if so, print it out.
if($minor > $min_minor){print OUT "$position\,$genotype\n";}
}
}
