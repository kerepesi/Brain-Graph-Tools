#!/usr/bin/perl -w
#perl -w BrainDiversity.pl all_392_scale500.list-GenPreFile-1.csv 392 0 lobes distr_func
#$ARGV[0]: input prefile
#$ARGV[1]: number of graphs
#$ARGV[2]: min edges in areas
#$ARGV[3]: lobes or area
#$ARGV[4]: out1 or out2 or distr_func
$num_graph=$ARGV[1];
$step=10;
$min_edges_in_areas=$ARGV[2];

if ($ARGV[3] eq "roi") {
    open IN,"results/$ARGV[0]";
    while (<IN>) {
        chomp;
        my @split_line=split(/;/,$_);
        #&find_edge_props(@split_line);
        if ($split_line[6] eq $split_line[7]) {
            if (!exists  $y_axis{$split_line[7]}{$split_line[8]}) {
                $y_axis{$split_line[7]}{$split_line[8]}=1;
            }else {
                $y_axis{$split_line[7]}{$split_line[8]}++;
            }
        }
        if (!exists  $y_axis{"all"}{$split_line[8]}) {
            $y_axis{"all"}{$split_line[8]}=1;
        }else {
            $y_axis{"all"}{$split_line[8]}++;
        } 
    }
    close IN;
}elsif ($ARGV[3] eq "cross_roi") {
    open IN,"results/$ARGV[0]";
    while (<IN>) {
        chomp;
        my @split_line=split(/;/,$_);
        $source_lobe=$split_line[6];
        $target_lobe=$split_line[7];
        if ($source_lobe lt $target_lobe) {
            $area_pair="$source_lobe-$target_lobe";
        }else {
            $area_pair="$target_lobe-$source_lobe";
        }
        #print "$source_lobe;$target_lobe;$area_pair\n";
        if ($source_lobe ne $target_lobe) {
            if (!exists  $y_axis{$area_pair}{$split_line[8]}) {
                $y_axis{$area_pair}{$split_line[8]}=1;
            }else {
                $y_axis{$area_pair}{$split_line[8]}++;
            }
        }
        if (!exists  $y_axis{"all"}{$split_line[8]}) {
            $y_axis{"all"}{$split_line[8]}=1;
        }else {
            $y_axis{"all"}{$split_line[8]}++;
        }
    }
    close IN;
}elsif ($ARGV[3] eq "lobes") {
    open IN,"lobes.txt";
    while (<IN>) {
        chomp;
        if ($_ =~ /^(\S+)\s(\S+)/) {
            $lobe{$1}=$2;
        }
    }
    close IN;
    open IN,"results/$ARGV[0]";
    while (<IN>) {
        chomp;
        my @split_line=split(/;/,$_);
        #print "$split_line[6];",&replace_roi($split_line[6]),";$lobe{&replace_roi($split_line[6])}\n";
        $source_lobe = $lobe{&replace_roi($split_line[6])};
        $target_lobe = $lobe{&replace_roi($split_line[7])};
        if ($source_lobe eq $target_lobe) {
            if (!exists  $y_axis{$target_lobe}{$split_line[8]}) {
                $y_axis{$target_lobe}{$split_line[8]}=1;
            }else {
                $y_axis{$target_lobe}{$split_line[8]}++;
            }
        }
        if (!exists  $y_axis{"all"}{$split_line[8]}) {
            $y_axis{"all"}{$split_line[8]}=1;
        }else {
            $y_axis{"all"}{$split_line[8]}++;
        }
    }
    close IN;
}elsif ($ARGV[3] eq "cross_lobes") {
    open IN,"lobes.txt";
    while (<IN>) {
        chomp;
        if ($_ =~ /^(\S+)\s(\S+)/) {
            $lobe{$1}=$2;
        }
    }
    close IN;
    open IN,"results/$ARGV[0]";
    while (<IN>) {
        chomp;
        my @split_line=split(/;/,$_);
        $source_lobe=$lobe{&replace_roi($split_line[6])};
        $target_lobe=$lobe{&replace_roi($split_line[7])};
        if ($source_lobe lt $target_lobe) {
            $area_pair="$source_lobe-$target_lobe";
        }else {
            $area_pair="$target_lobe-$source_lobe";
        }
        #print "$source_lobe;$target_lobe;$area_pair\n";
        if ($source_lobe ne $target_lobe) {
            if (!exists  $y_axis{$area_pair}{$split_line[8]}) {
                $y_axis{$area_pair}{$split_line[8]}=1;
            }else {
                $y_axis{$area_pair}{$split_line[8]}++;
            }
        }
        if (!exists  $y_axis{"all"}{$split_line[8]}) {
            $y_axis{"all"}{$split_line[8]}=1;
        }else {
            $y_axis{"all"}{$split_line[8]}++;
        }
    }
    close IN;
}

$num_areas=0;
$area_id{"all"}=1;
$j=1;
foreach my $area (keys %y_axis) {
    $j++;
    $area_id{$area}=$j;
    $num_areas++;
    $edges_in_area{$area}=0;
    foreach my $x_axis (keys %{$y_axis{$area}}) {
        $edges_in_area{$area}+=$y_axis{$area}{$x_axis};
    }
}
open(OUT, ">", "results/edges_per_$ARGV[3]-$ARGV[1].csv");
print "results/edges_per_$ARGV[3]-$ARGV[1].csv\n";
foreach my $area (sort { $edges_in_area{$b} <=> $edges_in_area{$a} } keys %edges_in_area) {
    print OUT "'$area',$edges_in_area{$area}\n";
}
close OUT;
if ($ARGV[4] eq "out1") {
    $out{0}{0}="o";
    $out{1}{0}=0;
    for (my $i=1;$i<=$step;$i++) {
        $out{$i+1}{0}=$i*(1/$step);
    }
    foreach my $area (keys %y_axis) {
        if ($edges_in_area{$area}>=$min_edges_in_areas) {
            $out{0}{$area_id{$area}}=$area;
            for (my $i=0;$i<=$step;$i++) {
                $final_y[$i]=0;
            }
            foreach my $x_axis (sort { $b <=> $a } keys %{$y_axis{$area}} ) {
                for (my $i=1;$i<=$step;$i++) {
                    if ($x_axis >= $i*($num_graph/$step)) {
                        $final_y[$i]+=$y_axis{$area}{$x_axis};
                    }
                }
                $final_y[0]+=$y_axis{$area}{$x_axis};
            }
            for (my $i=0;$i<=$step;$i++) {
                $out{$i+1}{$area_id{$area}}=$final_y[$i]/$edges_in_area{$area};
            }
        }
    }
}elsif ($ARGV[4] eq "out2") {
    $out{0}{0}="o";
    $out{1}{0}=0;
    for (my $i=1;$i<=$num_graph;$i++) {
        $out{$i}{0}=$i;
    }
    foreach my $area (keys %y_axis) {
        if ($edges_in_area{$area}>=$min_edges_in_areas) {
            $out{0}{$area_id{$area}}=$area;
            for (my $i=1;$i<=$num_graph;$i++) {
                if (exists $y_axis{$area}{$i}) {
                    $out{$i}{$area_id{$area}}=$y_axis{$area}{$i}/$edges_in_area{$area};
                }else {
                    $out{$i}{$area_id{$area}}=0;
                }

            }
        }
    }
}elsif ($ARGV[4] eq "distr_func") {
    $out{0}{0}="o";
    for (my $i=1;$i<=$step;$i++) {
        $out{$i+1}{0}=$i*(1/$step);
    }
    $out{$step+2}{0}="'EV'";
    foreach my $area (keys %y_axis) {
        if ($edges_in_area{$area}>=$min_edges_in_areas) {
            $out{0}{$area_id{$area}}=$area;
            for (my $i=0;$i<=$step;$i++) {
                $final_y[$i]=0;
            }
            $out{$step+2}{$area_id{$area}}=0;
            foreach my $x_axis (sort { $b <=> $a } keys %{$y_axis{$area}} ) {
                for (my $i=1;$i<=$step;$i++) {
                    if ($x_axis <= $i*($num_graph/$step)) {
                        $final_y[$i]+=$y_axis{$area}{$x_axis};
                    }
                }
                $out{$step+2}{$area_id{$area}}+=($x_axis*$y_axis{$area}{$x_axis})/$edges_in_area{$area};
                $final_y[0]+=$y_axis{$area}{$x_axis};
            }
            #print "$area,$out{$step+2}{$area_id{$area}}\n";
            for (my $i=1;$i<=$step;$i++) {
                $out{$i+1}{$area_id{$area}}=$final_y[$i]/$edges_in_area{$area};
            }
        }
    }
}elsif ($ARGV[4] eq "prob_dist") {
    $out{0}{0}="o";
    for (my $i=1;$i<=$num_graph;$i++) {
        $out{$i+1}{0}=$i;
    }
    foreach my $area (keys %y_axis) {
        if ($edges_in_area{$area}>=$min_edges_in_areas) {
            $out{0}{$area_id{$area}}=$area;
            for (my $i=0;$i<=$num_graph;$i++) {
                $final_y[$i]=0;
            }
            foreach my $x_axis (sort { $b <=> $a } keys %{$y_axis{$area}} ) {
                $final_y[$x_axis]+=$y_axis{$area}{$x_axis};
            }
            for (my $i=1;$i<=$num_graph;$i++) {
                $out{$i+1}{$area_id{$area}}=$final_y[$i]/$edges_in_area{$area};
            }
        }
    }
}
open(OUT, ">", "results/$ARGV[0]-BrainDiversity-$ARGV[1]-$ARGV[2]-$ARGV[3]-$ARGV[4].html");
print "results/$ARGV[0]-BrainDiversity-$ARGV[1]-$ARGV[2]-$ARGV[3]-$ARGV[4].html\n";
printf OUT qq~ <html>
  <head>
    <script type="text/javascript"
          src="https://www.google.com/jsapi?autoload={
            'modules':[{
              'name':'visualization',
              'version':'1',
              'packages':['corechart']
            }]
          }"></script>

    <script type="text/javascript">
      google.setOnLoadCallback(drawChart);

      function drawChart() {
        var data = google.visualization.arrayToDataTable([
~;
$first_row=1;
foreach my $row (sort { $a <=> $b } keys %out ) {
    if ($row<$step+2) {
        $first_col=1;
        foreach my $column (sort { $a <=> $b } keys %{$out{$row}} ) {
            if ($first_col) {
                print OUT "['$out{$row}{$column}'";
                $first_col=0;
            }elsif ($first_row) {
                print OUT ",'$out{$row}{$column}'";
            }else {
                printf(OUT ",%.4f",$out{$row}{$column});
            }
        }
        print OUT "],\n";
        $first_row=0;
    }
}
printf(OUT qq~       ]);    
    var options = {
          title: 'results/$ARGV[0]-BrainDiversity-$ARGV[1]-$ARGV[2]-$ARGV[3]-$ARGV[4].html',
          legend: { position: 'right' },
          vAxis: { logScale: false }
        };
~);
print OUT "var chart = new google.visualization.LineChart(document.getElementById('curve_chart'));";
#print OUT "var chart = new google.visualization.SteppedAreaChart(document.getElementById('curve_chart'));\n";
printf(OUT qq~ chart.draw(data, options);
      }
    </script>
  </head>
  <body>
    <div id="curve_chart" style="width: 1200px; height: 800px"></div>
  </body>
</html> 
~);
close OUT;
open(OUT, ">", "results/$ARGV[0]-BrainDiversity-$ARGV[1]-$ARGV[2]-$ARGV[3]-$ARGV[4].csv");
print "results/$ARGV[0]-BrainDiversity-$ARGV[1]-$ARGV[2]-$ARGV[3]-$ARGV[4].csv\n";
$first_row=1;
$out{0}{0}="x";
foreach my $row (sort { $a <=> $b } keys %out ) {
        $first_column=1;
        foreach my $column (sort { $a <=> $b } keys %{$out{$row}} ) {
            if ($first_column==0) {
                print OUT ",";
            }
            if ($first_row) {
                print OUT "'$out{$row}{$column}'";
            }else {
                if ($first_column) {
                    printf(OUT "%s",$out{$row}{$column});
                }else {
                    printf(OUT "%.4f",$out{$row}{$column});
                }
            }
            $first_column=0;
        }
        print OUT "\n";
        $first_row=0;
}
close OUT;
####################################
sub replace_roi {
    my $replaced=$_[0];
    $replaced =~ s/Left-//;
    $replaced =~ s/Right-//;
    $replaced =~ s/ctx-rh-//;
    $replaced =~ s/ctx-lh-//;
    $replaced =~ s/-//;
    $replaced=lc $replaced;
    return $replaced;
}
sub find_edge_props {
    if (exists $connect{$_[0]}{$_[1]}) {
        print "double: $_[0];$_[1]\n";
    }
    if (exists $connect{$_[1]}{$_[0]}) {
        print "backward: $_[0];$_[1]\n";
    }
    $connect{$_[0]}{$_[1]}=1;
    if ($_[0]==$_[1]) {
        print "loop: $_[0];$_[1]\n";
    }
}
