var make_series = function() {
 var statuses = report_data.status_codes;
 var counts = [];
 const reducer = (accumulator, currentValue) => accumulator + currentValue;
 for (code in statuses) {
   counts.push(statuses[code].length);
 }
 var total = counts.reduce(reducer);
 var series = [];
 for (code in statuses) {
   series.push({
     name: code,
     y: (statuses[code].length / total) * 100
   })
 }
 return series;
}

var series = make_series();

Highcharts.chart('pie_chart', {
  chart: {
    plotBackgroundColor: null,
    plotBorderWidth: null,
    plotShadow: false,
    type: 'pie'
  },
  title: {
    text: 'Status codes per page'
  },
  tooltip: {
    pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
  },
  plotOptions: {
    pie: {
      allowPointSelect: true,
      cursor: 'pointer',
      dataLabels: {
        enabled: true,
        format: '<b>{point.name}</b>: {point.percentage:.1f} %',
        style: {
          color: (Highcharts.theme && Highcharts.theme.contrastTextColor) || 'black'
        }
      }
    }
  },
  series: [{
    name: 'Status codes',
    colorByPoint: true,
    data: series
  }]
});
