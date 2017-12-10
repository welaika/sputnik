var make_status_code_series = function() {
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
};

Highcharts.chart('status_codes_chart', {
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
    data: make_status_code_series()
  }]
});

var make_query_categories = function() {
  var queries = report_data.queries;
  var categories = [];
  for(query in queries) {
    categories.push(query);
  };

  return categories;
};

var make_query_series = function() {
  var acc = {total: [], min: [], max: []};
  var categories = make_query_categories();
  for(var i = 0; i < categories.length; i++) {
    var category = categories[i];
    acc.total.push(report_data.queries[category]);
    console.log(report_data.min_max);
    console.log(category);
    acc.min.push(report_data.min_max[category]['min']);
    acc.max.push(report_data.min_max[category]['max']);
  }
  return [{name: "total", data: acc.total},
          {name: "min", data: acc.min},
          {name: "max", data: acc.max}]
};

Highcharts.chart('queries_chart', {
  chart: {
    type: 'column'
  },
  title: {
    text: 'Queries'
  },
  xAxis: {
    categories: make_query_categories(),
    crosshair: true
  },
  yAxis: {
    min: 0,
    title: { text: "Queries" }
  },
  tooltip: {},
  plotOptions: {
    column: {
      pointPadding: 0.2,
      borderWidth: 0
    }
  },
  series: make_query_series()
});
