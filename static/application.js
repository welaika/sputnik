var get_report_target = function() {
 var statuses = report_data.status_codes;
 for (code in statuses) {
   var url = statuses[code].length && statuses[code][0];
   var link = document.createElement('a');
   link.href = url;
   return link.protocol + '//' + link.hostname;
 }
 return null;
};

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

var report_target = get_report_target();
if (report_target) {
  var header = document.getElementById("header");
  header.innerHTML = header.innerHTML + ' for ' + report_target;
}

Highcharts.theme = {
    colors: ['#2980b9', '#50B432', '#ED561B', '#DDDF00', '#24CBE5', '#64E572', '#FF9655', '#e67e22', '#6AF9C4'],
    chart: {
        backgroundColor: {
            color: 'white',
            stops: [
                [0, 'rgb(255, 255, 255)'],
                [1, 'rgb(240, 240, 255)']
            ]
        },
    },
    title: {
        style: {
            color: '#2c3e50',
            font: 'bold 16px "Trebuchet MS", Verdana, sans-serif'
        }
    },
    subtitle: {
        style: {
            color: '#2c3e50',
            font: 'bold 12px "Trebuchet MS", Verdana, sans-serif'
        }
    },
    labels: {
      style: {
        color: '#2c3e50'
      }
    },
    legend: {
        itemStyle: {
            font: '9pt Trebuchet MS, Verdana, sans-serif',
            color: '#2c3e50'
        },
        itemHoverStyle:{
            color: 'gray'
        }
    }
};

// Apply the theme
Highcharts.setOptions(Highcharts.theme);

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
          color: 'black'
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
