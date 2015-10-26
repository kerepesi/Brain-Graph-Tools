#!/usr/bin/perl -w

#$ARGV[0]: minimal common edge;
#$ARGV[1]: 100 or 6 study
#$ARGV[2]: list of input graphs
#$ARGV[3]: dir of input graphs
#Typical running command: 
#perl GenPreFile.pl 1 100 all-connectome_scale500.graphml.txt 100BrainGraph

my %connected=();
my %weight=();
my %node_name=();
my %p_node_name=();
my @weight_array=();

open (IN, "Nodes-$ARGV[1].csv");
while (<IN>) {
    chop;
    if ($_ =~ /(.+);(.+);(.+);(.+)/) {
    $node_name{$1}=$2;
    $p_node_id{$1}=$3;
    $p_node_name{$1}=$4;
    }
}
close IN;
open (IN, "$ARGV[2]");
while (<IN>) {
    if ($ARGV[1] == 100) {
        &readfile100($_);
    }else {
        &readfile($_);
    }
}
close IN;
open OUT,">","results/$ARGV[2]-GenPreFile-$ARGV[0].csv";
foreach my $source (sort { $a <=> $b } keys %connected ) {
    foreach my $target (sort { $a <=> $b } keys %{$connected{$source}} ) {
        if ($connected{$source}{$target}>=$ARGV[0]) {
            print OUT "$source;$target;$node_name{$source};$node_name{$target};$p_node_id{$source};$p_node_id{$target};$p_node_name{$source};$p_node_name{$target};$connected{$source}{$target};";
            foreach my $graph (keys %{$weight{$source}{$target}}) {
                push(@weight_array,$weight{$source}{$target}{$graph});
            }
            printf OUT "%f;%f;\n",&median(@weight_array),&average(@weight_array);
            @weight_array=();
        }
    }
}
close OUT;
system "sort results/$ARGV[2]-GenPreFile-$ARGV[0].csv -t ';' -k 10 -n -r > results/$ARGV[2]-GenPreFile-$ARGV[0]-sorted-med.csv";
system "sort results/$ARGV[2]-GenPreFile-$ARGV[0].csv -t ';' -k 11 -n -r > results/$ARGV[2]-GenPreFile-$ARGV[0]-sorted-avg.csv";
print "results/$ARGV[2]-GenPreFile-$ARGV[0].csv\n";
print "results/$ARGV[2]-GenPreFile-$ARGV[0]-sorted-med.csv\n";
print "results/$ARGV[2]-GenPreFile-$ARGV[0]-sorted-avg.csv\n";
#################################################
sub readfile {
    open (IN2, $_[0]);
    my $actual_graph=$_[0];
    while (<IN2>) {
            chomp;
            if ($_ =~ /source="n(.+)" target="n(.+)"/) {
                $connected{$1}{$2}++;
                $last_source=$1;
                $last_target=$2;
            } elsif ($_=~ /"de_strength">(\d\.\d+)/) {
                $weight{$last_source}{$last_target}{$actual_graph}=$1;
            }
    }
    close IN2;
}
sub readfile100 {
    my $flm_id=0;
    my $nof_id=0;
    my $key_section=1;
    open (IN2, "$ARGV[3]/$_[0]");
    my $actual_graph=$_[0];
    while (<IN2>) {
            chomp;
            if ($key_section) {
                if ($_ =~ /<node id=/ ) {
                    $key_section = 0;
                }elsif ($_ =~ /"fiber_length_mean".+id="d(\d+)"/ ) {
                    $flm_id=$1;
                }elsif ($_ =~ /"number_of_fibers".+id="d(\d+)"/ ) {
                    $nof_id=$1;
                }
            }
            if ($_ =~ /source="(\d+)" target="(\d+)"/) {
                $connected{$1}{$2}++;
                $last_source=$1;
                $last_target=$2;                
            }elsif ($_ =~ /<data key="d(\d+)">(\S+)</) {
                if ($1 == $flm_id) {
                    $last_flm = $2;
                }elsif ($1 == $nof_id) {
                    $last_nof = $2;
                }
            }elsif ($_=~ /<\/edge>/) {
                $weight{$last_source}{$last_target}{$actual_graph}=$last_nof/$last_flm;
            }
    }
    close IN2;
}
sub median {
    my @values = sort {$a <=> $b} @_;
    my $num_values = @values;
    if($num_values % 2) {
        return $values[int($num_values/2)];
    }
    else {
        return ($values[int($num_values/2)-1] + $values[int($num_values/2)])/2;
    }
}
sub average {
    my $sum;
    my $num_values=@_; 
    foreach (@_) { 
        $sum += $_; 
    }
    return $sum/$num_values;
}
