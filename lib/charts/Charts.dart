import 'dart:async';
import 'dart:convert';
import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_cva/classes/WeeklyData.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:http/http.dart' as http;

class Chart extends StatefulWidget {
  final Widget child;
  final extra;

  Chart({Key key, this.child, this.extra}) : super(key: key);

  _ChartState createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  List data;
  List<Week> weeklyData;
  List<Week> tempWeeklyData;
  List<charts.Series<Results, String>> _seriesData;

  var cases, recover, deaths;

  @override
  void initState() {
    super.initState();
    cases = widget.extra[0].confirmed;
    recover = widget.extra[0].recover;
    deaths = widget.extra[0].death;
    _seriesData = List<charts.Series<Results, String>>();
    getData();
  }

  Future<String> getData() async {
    var response = await http.get(
        Uri.encodeFull(
            "https://coronavirus-tracker-api.herokuapp.com/v2/locations?country_code=" +
                "${widget.extra[0].code}" +
                "&timelines=true"),
        headers: {"Accept": "application/json"});

    this.setState(() {
      var res = json.decode(response.body);
      data = res['locations'];
    });
    getWeeklyData();
    return "Success!";
  }

  void getWeeklyData() {
    var date = DateTime.now();
    var day = date.day - 1;
    var month = date.month;
    var year = date.year;

    weeklyData = List<Week>();
    tempWeeklyData = List<Week>();

    var realDate = year.toString() + "-" +
        (month < 10 ? "0" + month.toString() : month.toString()) + "-" +
        (day < 10 ? "0" + day.toString() : day.toString()) + "T00:00:00Z";

    if(data[0]['timelines']['confirmed']['timeline'][realDate] == null){
      setState(() {
        day = day - 1;
        realDate = year.toString() + "-" +
            (month < 10 ? "0" + month.toString() : month.toString()) + "-" +
            (day < 10 ? "0" + day.toString() : day.toString()) + "T00:00:00Z";
      });
    }

    List tempDates = [
      "2020-01-22T00:00:00Z",
      "2020-02-01T00:00:00Z",
      "2020-03-01T00:00:00Z",
      realDate
    ];


    if(data.length > 1){
      for (int i = 0; i < data.length; i++) {
        var timelinesData = data[i]['timelines'];
        var timelineConfirmed = timelinesData['confirmed']['timeline'];
        var timelineDeaths = timelinesData['deaths']['timeline'];
        var timelineRecovered = timelinesData['recovered']['timeline'];
        for (int j = 0; j < tempDates.length; j++) {
          tempWeeklyData.add(new Week(tempDates[j].toString().substring(0,10), timelineConfirmed[tempDates[j]], timelineDeaths[tempDates[j]], timelineRecovered[tempDates[j]]));
        }
      }
      for(int k = 0; k < tempDates.length; k++){
        var sumC = 0;
        var sumD = 0;
        var sumR = 0;
        for(int l = k; l < (data.length * tempDates.length); l += 4){
          sumC += tempWeeklyData[l].confirmed;
          sumD += tempWeeklyData[l].death;
          sumR += tempWeeklyData[l].recover;
        }
        var tempString = tempDates[k].toString().substring(0,10);
        var realDate = tempString.substring(5,7) + "/" + tempString.substring(8,10) + "/" + tempString.substring(0,2);
        weeklyData.add(new Week(realDate, sumC, sumD, sumR));
      }
    }else{
      var timelinesData = data[0]['timelines'];
      var timelineConfirmed = timelinesData['confirmed']['timeline'];
      var timelineDeaths = timelinesData['deaths']['timeline'];
      var timelineRecovered = timelinesData['recovered']['timeline'];
      for (int j = 0; j < tempDates.length; j++) {
        var tempString = tempDates[j].toString().substring(0,10);
        var realDate = tempString.substring(5,7) + "/" + tempString.substring(8,10) + "/" + tempString.substring(0,2);
        weeklyData.add(new Week(
            realDate,
            timelineConfirmed[tempDates[j]], timelineDeaths[tempDates[j]],
            timelineRecovered[tempDates[j]]));
      }
    }

    var data1 = [
      new Results(weeklyData[0].date, weeklyData[0].confirmed),
      new Results(weeklyData[1].date, weeklyData[1].confirmed),
      new Results(weeklyData[2].date, weeklyData[2].confirmed),
      new Results(weeklyData[3].date, weeklyData[3].confirmed)
    ];
    var data2 = [
      new Results(weeklyData[0].date, weeklyData[0].recover),
      new Results(weeklyData[1].date, weeklyData[1].recover),
      new Results(weeklyData[2].date, weeklyData[2].recover),
      new Results(weeklyData[3].date, weeklyData[3].recover)
    ];
    var data3 = [
      new Results(weeklyData[0].date, weeklyData[0].death),
      new Results(weeklyData[1].date, weeklyData[1].death),
      new Results(weeklyData[2].date, weeklyData[2].death),
      new Results(weeklyData[3].date, weeklyData[3].death)
    ];

    _seriesData.add(
      charts.Series(
        domainFn: (Results pollution, _) => pollution.date,
        measureFn: (Results pollution, _) => pollution.sum,
        id: '1',
        data: data1,
        colorFn: (_, __) => charts.MaterialPalette.gray.shadeDefault,

      ),
    );
    _seriesData.add(
      charts.Series(
          domainFn: (Results pollution, _) => pollution.date,
          measureFn: (Results pollution, _) => pollution.sum,
          id: '2',
          data: data2,
          colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault
      ),
    );
    _seriesData.add(
      charts.Series(
          domainFn: (Results pollution, _) => pollution.date,
          measureFn: (Results pollution, _) => pollution.sum,
          id: '3',
          data: data3,
          colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
      ),
    );
  }

  _onSelectionChanged(charts.SelectionModel model) {
    final selectedDatum = model.selectedDatum;
    var indexData = selectedDatum[0].index;
    setState(() {
      cases = weeklyData[indexData].confirmed.toString();
      recover = weeklyData[indexData].recover.toString();
      deaths = weeklyData[indexData].death.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            title: Text(widget.extra[0].name,
                style:
                    new TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0)),
          ),
          body: weeklyData != null ?
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Container(
              child: Center(
                child: Column(
                  children: <Widget>[
                    Material(
                      borderRadius: BorderRadius.circular(10),
                      elevation: 10,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            height: 85,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 25, right: 25, top: 5),
                              child: Column(
                                children: <Widget>[
                                  Text("Last Updated: " + weeklyData[3].date.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15), textAlign: TextAlign.center),
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Column(
                                        children: <Widget>[
                                          Text("CASES", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                                          SizedBox(height: 10),
                                          Text(cases, style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold),)
                                        ],
                                      ),
                                      Column(
                                        children: <Widget>[
                                          Text("RECOVERED", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                                          SizedBox(height: 10),
                                          Text(recover, style: TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.bold),)
                                        ],
                                      ),
                                      Column(
                                        children: <Widget>[
                                          Text("DEATHS", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                                          SizedBox(height: 10),
                                          Text(deaths, style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold),)
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            )
                        ),
                      ),
                    ),
                    SizedBox(height: 10.0,),
                    Expanded(
                      child: charts.BarChart(
                        _seriesData,
                        animate: true,
                        barGroupingType: charts.BarGroupingType.grouped,
                        animationDuration: Duration(seconds: 2),
                        selectionModels: [
                          SelectionModelConfig(
                            changedListener: _onSelectionChanged
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ) :
          Center(
              child: CircularProgressIndicator()
          ),
      )
    );
  }
}

class Results {
  String date;
  int sum;
  Results(this.date, this.sum);
}
