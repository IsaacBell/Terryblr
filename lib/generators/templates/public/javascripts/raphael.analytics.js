Raphael.fn.drawGrid = function (x, y, w, h, wv, hv, color) {
    color = color || "#000";
    var path = ["M", x, y, "L", x + w, y, x + w, y + h, x, y + h, x, y],
        rowHeight = h / hv,
        columnWidth = w / wv;
    for (var i = 1; i < hv; i++) {
        path = path.concat(["M", x, y + i * rowHeight, "L", x + w, y + i * rowHeight]);
    }
    for (var j = 1; j < wv; j++) {
        path = path.concat(["M", x + j * columnWidth, y, "L", x + i * columnWidth, y + h]);
    }
    return this.path(path.join(",")).attr({stroke: color});
};

console.log('Defining drawTimeSeries...');
function drawTimeSeries(el) {
  var table = $(el);
  table.css({
      position: "absolute",
      left: "-9999em",
      top: "-9999em"
  }).hide();

  // Grab the data
  var labels = [],
      data = [];
  table.find("tr > td:first-child").each(function () {
      labels.push($(this).html());
  });
  table.find("tr > td:last-child").each(function () {
      data.push(parseInt($(this).html(), 10));
  });

  holder = table.prev();

  if (!holder.length) return false;

  // Draw
  var width = holder.width(),
      height = holder.height(),
      leftgutter = 0,
      bottomgutter = 30,
      topgutter = 20,
      colorhue = 196/360, //.6 || Math.random(),
      color = "hsb(" + [colorhue, 1, 0.85] + ")",
      r = Raphael(holder.attr('id'), width, height),
      txt = {font: '12px "Helvetica Neue", Arial, Helvetica, sans-serif', fill: "#fff"},
      txt1 = {font: '10px "Helvetica Neue", Arial, Helvetica, sans-serif', fill: "#fff"},
      txt2 = {font: '12px "Helvetica Neue", Arial, Helvetica, sans-serif', fill: "#000"},
      X = (width - leftgutter) / labels.length,
      max = Math.max.apply(Math, data),
      Y = (height - bottomgutter - topgutter) / max,
      units = table.find('tbody').attr('units');
  r.drawGrid(leftgutter + X * 0.5, topgutter, width - leftgutter - X, height - topgutter - bottomgutter, 10, 10, "#333");
  var path = r.path().attr({stroke: color, "stroke-width": 4, "stroke-linejoin": "round"}),
      bgp = r.path().attr({stroke: "none", gradient: [90, color, color].join("-"), opacity: 0}).moveTo(leftgutter + X * 0.5, height - bottomgutter),
      frame = r.rect(0, 0, 100, 40, 5).attr({fill: "#000", stroke: "#474747", "stroke-width": 2}).hide(),
      label = [],
      is_label_visible = false,
      leave_timer,
      blanket = r.set();
  var today = new Date;
  var m_names = new Array("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December");
  label[0] = r.text(60, 10, "0 "+units).attr(txt).hide();
  label[1] = r.text(60, 40, today.toDateString()).attr(txt1).attr({fill: color}).hide();

  for (var i = 0, ii = labels.length; i < ii; i++) {
      var y = Math.round(height - bottomgutter - Y * data[i]),
          x = Math.round(leftgutter + X * (i + 0.5)),
          lbl = labels[i],
          date = new Date(lbl.split('-')[0], lbl.split('-')[1]-1, lbl.split('-')[2]),
          t = r.text(x, height - 16, date.getDate()).attr(txt).toBack();
      bgp[(i === 0 || i === labels.length-1) ? "lineTo" : "cplineTo"](x, y, 10);
      path[i ? "moveTo" : "cplineTo"](x, y, 10);
      var dot = r.circle(x, y, 5).attr({fill: color, stroke: "#000"});
      blanket.push(r.rect(leftgutter + X * i, 0, X, height - bottomgutter).attr({stroke: "none", fill: "#fff", opacity: 0}));
      var rect = blanket[blanket.length - 1];
      (function (x, y, data, lbl, dot, date) {
          var timer, i = 0;
          $(rect.node).hover(function () {
              clearTimeout(leave_timer);
              var newcoord = {x: +x + 7.5, y: y - 19};
              if (newcoord.x + 100 > width) {
                  newcoord.x -= 114;
              }
              frame.show().animate({x: newcoord.x, y: newcoord.y}, 200 * is_label_visible);
              label[0].attr({text: data + " " + units + ((data % 10 == 1) ? "" : "s")}).show().animateWith(frame, {x: +newcoord.x + 50, y: +newcoord.y + 12}, 200 * is_label_visible);
              label[1].attr({text: date.toDateString()}).show().animateWith(frame, {x: +newcoord.x + 50, y: +newcoord.y + 27}, 200 * is_label_visible);
              dot.attr("r", 7);
              is_label_visible = true;
          }, function () {
              dot.attr("r", 5);
              leave_timer = setTimeout(function () {
                  frame.hide();
                  label[0].hide();
                  label[1].hide();
                  is_label_visible = false;
                  // r.safari();
              }, 1);
          });
      })(x, y, data[i], labels[i], dot, date);
  }
  bgp.lineTo(x, height - bottomgutter).andClose();
  frame.toFront();
  label[0].toFront();
  label[1].toFront();
  blanket.toFront();
}

function displayAnalyticsGraph() {
    drawTimeSeries("#visitors_data");
    drawTimeSeries("#tweets_data");
}

function displayCountriesGraph() {
	// Raphael Charts
	var pie_data = $("#countries_data");
  var pie_holder = $("#countries_pie");
  if (pie_data.length && pie_holder.length) {

  	var values = [],
        labels = [],
        width = pie_holder.width(),
        height = pie_holder.height(),
        x = pie_holder.width()/2,
        y = pie_holder.height()/2,
        radius = (pie_holder.height()/2) * 0.75;

    pie_data.find("tbody td").each(function (i, el) {
        values.push(parseInt($(el).text(), 10));
    });
    pie_data.find("tfoot th").each(function (i, el) {
        labels.push($(el).text());
    });
    
    Raphael(pie_holder.attr('id'), width, height).pieChart(x, y, radius, values, labels, "#fff");
  }
}

// $(document).ready(displayAnalyticsGraph) //.ready(displayCountriesGraph);