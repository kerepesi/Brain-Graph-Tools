#!/usr/bin/perl -w
#$ARGV[0]: input file
#$ARGV[1]: number of graphs
#$ARGV[2]: number of nodes
#run: perl -w BrainEvolution.pl results/all_96_scale500.list-GenPreFile-1.csv 96 1015
system "sort $ARGV[0] -t ';' -k 9 -n -r > $ARGV[0]-sorted-common.csv";
print "$ARGV[0]-sorted-common.csv\n";
for ($i=1;$i<=$ARGV[1];$i++) {
    $new_isolated_edges[$i]=0;
    $new_edges[$i]=0;
}
for ($i=0;$i<=$ARGV[2];$i++) {
    $covered[$i]=0;
}
$first=1;
open IN,"$ARGV[0]-sorted-common.csv";
while (<IN>) {
    chomp;
    my @split_line=split(/;/,$_);
    if ($first) {
        $actual_common=$split_line[8];
        $first=0;
    }
    if ($actual_common != $split_line[8]) {
        foreach $source (keys %is_actual_edge) {
            foreach $target (keys %{$is_actual_edge{$source}}) {
                if (($covered[$source]==1) && ($covered[$target]==1)) {
                    $new_isolated_edges[$actual_common]++;
                }
                $new_edges[$actual_common]++;
            }
        }
        %is_actual_edge=();
        $actual_common=$split_line[8];
    }
    $covered[$split_line[0]]++;
    $covered[$split_line[1]]++;
    $is_actual_edge{$split_line[0]}{$split_line[1]}=1;
}
close IN;
foreach $source (keys %is_actual_edge) {
        foreach $target (keys %{$is_actual_edge{$source}}) {
            if (($covered[$source]==1) && ($covered[$target]==1)) {
                $new_isolated_edges[$actual_common]++;
            }
            $new_edges[$actual_common]++;
        }
}

open OUT,">","$ARGV[0]-sorted-common.csv-BrainEvolution.csv";
print "$ARGV[0]-sorted-common.csv-BrainEvolution.csv\n";
print OUT "Step;New edges;Proportion of new isolated edges\n";
for ($i=$ARGV[1];$i>=1;$i--) {
    if ($new_edges[$i]>0) { 
        $proportion[$i]=$new_isolated_edges[$i]/$new_edges[$i];
    }else {
        $proportion[$i]=0;
    }
    printf OUT "%.0f;%.0f;%.2f\n",$ARGV[1]-$i,$new_edges[$i],$proportion[$i];
}
close OUT;

open OUT,">","$ARGV[0]-sorted-common.csv-BrainEvolution.html";
print "$ARGV[0]-sorted-common.csv-BrainEvolution.html\n";
printf OUT qq~<html>
<head>
  <script type="text/javascript" src="https://www.google.com/jsapi"></script>
  <script type="text/javascript">
    google.load('visualization', '1.1', {packages: ['line']});
    google.setOnLoadCallback(drawChart);

    function drawChart() {

      var data = new google.visualization.DataTable();
      data.addColumn('number', 'Step');
      data.addColumn('number', 'Proportion of new isolated edges');

      data.addRows([    ~;
for ($i=$ARGV[1];$i>=1;$i--) {
    printf OUT "[%.0f,%.2f],\n",$ARGV[1]-$i,$proportion[$i];
}
printf OUT qq~ ]);

      var options = {
        hAxis : {direction: -1},
        chart: {
          title: 'Brain diversity evolution',
        },
        width: 900,
        height: 500
      };

      var chart = new google.charts.Line(document.getElementById('linechart_material'));

      chart.draw(data, options);
    }
  </script>
</head>
<body>
  <div id="linechart_material"></div>
</body>
</html>  ~;
close OUT;

