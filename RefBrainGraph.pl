#!/usr/bin/perl -w
#Typical running command: 
#perl -w RefBrainGraph.pl -MinC 48 -MinStr 0 -StrMerge avg -Out graphml -Project 2.0 > out

use Getopt::Long;

my $min_common_edge=0;
my $min_strength=0;
my $strength_merge="med";
my $strength_column=0;
my $output_type="csv";
my $project="1.0";
my $usage = qq~
    Options:
        -MinC: This number k means that only the edges are displayed which are in at least k connectomes. Default: 0
        -MinStr: Only the edges are displayed whose median (or mean) strengths are at least the specified value. Default: 0
        -StrMerge: The type of merge of edge strength. Default: avg
        -Out: graphml: Graphml output. Default: csv
        -Project: project 2.0 (500 graph), only male: 2.0-M, only female: 2.0-F, 6 graph project (default): 1.0
        -h: print help;
~;

GetOptions ( 
        'MinC=i'=>\$min_common_edge,
        'MinStr=f'=>\$min_strength,
        'StrMerge=s'=>\$strength_merge,
        'Out=s'=>\$output_type,
        'Help'=>\$help,
        'Project=s'=>\$project 
) || die "Invalid command line options\n";
die $usage if $help;

if ($project eq "2.0") {
    $input_file="Pre100-1-".$strength_merge.".csv";
}elsif ($project eq "2.0-M") {
    $input_file="Pre100-M-1-".$strength_merge.".csv";
}elsif ($project eq "2.0-F") {
    $input_file="Pre100-F-1-".$strength_merge.".csv";
}else {
    $input_file="Pre-1-".$strength_merge.".csv";
}
if ($strength_merge eq "med") {
    $strength_column=9;
}elsif ($strength_merge eq "avg") {
    $strength_column=10;
}
my $graphs_column=8;
if ($output_type eq "csv") {
    &out_csv();
} elsif ($output_type eq "graphml") {
    if ($project eq "1.0") {
        &out_graphml_1_0();
    }else {
        &out_graphml_2_0()
    }
}

########################################################################

sub out_csv {
    my %connected=();
    print"id_node1;id_node2;name_node1;name_node2;parent_id_node1;parent_id_node2;parent_name_node1;parent_name_node2;minimum_edge_confidence;median;average;\n";
    open (IN, "$input_file") or die "Could not open $input_file";
    while (<IN>) {
        chop;
        my @input_line = split /;/;
        if ($input_line[$strength_column]>=$min_strength) {
			if ($input_line[$graphs_column]>=$min_common_edge) {
				if ( (!exists $connected{$input_line[0]}{$input_line[1]}) && (!exists $connected{$input_line[1]}{$input_line[0]}) ) {
					print "$_\n";
					$connected{$input_line[0]}{$input_line[1]}=1;
				}
			}
        } else {
			last;
		}
    }
    close IN;
}

sub out_graphml_1_0 {
    system("head -6009 subjectA1.graphml");
    my %strength=();
    open (IN, "$input_file") or die "Could not open $input_file";
    while (<IN>) {
        chop;
        my @input_line = split /;/;
        if ($input_line[$strength_column]>=$min_strength) {
			if ($input_line[$graphs_column]>=$min_common_edge) {
                $strength{$input_line[0]}{$input_line[1]}=$input_line[$strength_column];
			}
        } else {
			last;
		}
    }
    close IN;
    foreach my $source (sort { $a <=> $b } keys %strength ) {
        foreach my $target (sort { $a <=> $b } keys %{$strength{$source}} ) {
            printf(qq~<edge id="e%d_%d" source="n%d" target="n%d">\n~,$source,$target,$source,$target);
            printf(qq~    <data key="de_strength">%f</data>\n~,$strength{$source}{$target});
            print(qq~</edge>\n~);
        }
    }
    print(qq~</graph>\n~); 
    print(qq~</graphml>\n~);
}


sub out_graphml_2_0 {
    print(qq~<?xml version="1.0" encoding="utf-8"?><graphml xmlns="http://graphml.graphdrawing.org/xmlns" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://graphml.graphdrawing.org/xmlns http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd">\n~);
    print(qq~<key attr.name="number_of_fiber_per_fiber_length_mean" attr.type="double" for="edge" id="d14" />\n~);
    print(qq~<key attr.name="dn_hemisphere" attr.type="string" for="node" id="d7" />\n~);
    print(qq~<key attr.name="dn_name" attr.type="string" for="node" id="d6" />\n~);
    print(qq~<key attr.name="dn_fsname" attr.type="string" for="node" id="d5" />\n~);
    print(qq~<key attr.name="dn_region" attr.type="string" for="node" id="d4" />\n~);
    print(qq~<graph edgedefault="undirected">\n~);
    open (IN, "100307_connectome_scale500.graphml");
    while (<IN>) {
        if (($_=~/<node id=/)||($_=~/<data key="d4"/)||($_=~/<data key="d5"/)||($_=~/<data key="d6"/)||($_=~/<data key="d7"/)||($_=~/<\/node>/)) {
            print $_;
        }
    }
    open (IN, "$input_file") or die "Could not open $input_file";
    while (<IN>) {
        chop;
        my @input_line = split /;/;
        if ($input_line[$strength_column]>=$min_strength) {
			if ($input_line[$graphs_column]>=$min_common_edge) {
                $strength{$input_line[0]}{$input_line[1]}=$input_line[$strength_column];
			}
        } else {
			last;
		}
    }
    close IN;
    foreach my $source (sort { $a <=> $b } keys %strength ) {
        foreach my $target (sort { $a <=> $b } keys %{$strength{$source}} ) {
            printf(qq~<edge source="%d" target="%d">\n~,$source,$target);
            printf(qq~  <data key="d14">%f</data>\n~,$strength{$source}{$target});
            print(qq~</edge>\n~);
        }
    }
    print(qq~</graph>\n~);
    print(qq~</graphml>\n~);
}
