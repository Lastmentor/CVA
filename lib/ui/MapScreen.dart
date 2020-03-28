import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_app_cva/classes/Locations.dart';
import 'package:flutter_app_cva/ui/Information.dart';
import 'package:flutter_app_cva/ui/Symptoms.dart';
import 'package:flutter_app_cva/ui/WorldDetail.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_app_cva/gist/Gist.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {

  List data;
  List dataDeath;
  List dataRecover;
  List<Marker> markers = [];
  List<Locations> locations;
  bool checkUpload = false;
  var dataLatest;
  var deaths = "-";
  var cases = "-";
  var recover = "-";
  var title = "?";

  Future<String> getData() async {
    var response = await http.get(
        Uri.encodeFull("https://coronavirus-tracker-api.herokuapp.com/all"),
        headers: {
          "Accept": "application/json"
        }
    );

    this.setState(() {
      var res  = json.decode(response.body);
      dataLatest = res['latest'];
      data = res['confirmed']['locations'];
      dataDeath = res['deaths']['locations'];
      dataRecover = res['recovered']['locations'];
    });
    print(data.length.toString() + "/" + dataDeath.length.toString() + "/" + dataRecover.length.toString());
    updateState();
    getLocations();
    return "Success!";
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return new Future(() => false);
      },
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Container(
                child: dataRecover != null
                    ? Stack(
                  children: <Widget>[
                    GoogleMap(
                        initialCameraPosition: CameraPosition(target: LatLng(45.811328, 15.975862), zoom: 4),
                        markers: markers.toSet(),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15.0, right: 15, bottom: 10),
                        child: Material(
                          borderRadius: BorderRadius.circular(15),
                          elevation: 12,
                          child: Container(
                              height: 145,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 25, right: 25, top: 20),
                                child: Column(
                                  children: <Widget>[
                                    Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                                    SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Column(
                                          children: <Widget>[
                                            Text("CASES", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                                            SizedBox(height: 10),
                                            Text(cases, style: TextStyle(color: Colors.orange, fontSize: 15, fontWeight: FontWeight.bold),)
                                          ],
                                        ),
                                        Column(
                                          children: <Widget>[
                                            Text("RECOVERED", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                                            SizedBox(height: 10),
                                            Text(recover, style: TextStyle(color: Colors.green, fontSize: 15, fontWeight: FontWeight.bold),)
                                          ],
                                        ),
                                        Column(
                                          children: <Widget>[
                                            Text("DEATHS", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                                            SizedBox(height: 10),
                                            Text(deaths, style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold),)
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
                    ),
                    // World Icon
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 35.0, right: 10.0),
                        child: GestureDetector(
                          onTap: () {
                            updateState();
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              image: DecorationImage(
                                  image: AssetImage("images/world.png"),
                                  fit: BoxFit.cover
                              )
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Info Page
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 103.0, right: 10.0),
                        child: GestureDetector(
                          onTap: () {
                            infoPage();
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage("images/error.png"),
                                    fit: BoxFit.cover
                                )
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Check List
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 172.0, right: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            symptomsPage();
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                image: DecorationImage(
                                    image: AssetImage("images/test.png"),
                                    fit: BoxFit.cover
                                )
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
                    : Stack(
                  children: <Widget>[
                    GoogleMap(
                        initialCameraPosition:
                        CameraPosition(target: LatLng(45.811328, 15.975862), zoom: 4)
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(),
                    )
                  ],
                )
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  void updateState(){
    setState(() {
      title = "Worldwide";
      cases = dataLatest['confirmed'].toString();
      recover = dataLatest['recovered'].toString();
      deaths = dataLatest['deaths'].toString();
    });
  }

  void infoPage(){
    Navigator.push(context, new MaterialPageRoute(builder: (context) => new Information()));
  }

  void symptomsPage(){
    Navigator.push(context, new MaterialPageRoute(builder: (context) => new Symptoms()));
  }

  void getLocations(){
    locations = new List<Locations>();
    for(int i=0; i<dataRecover.length; i++){
      var tempCoordinates = data[i]['coordinates'];
      var tempDeaths = dataDeath[i]['latest'];
      var tempRecovers = dataRecover[i]['latest'];
      locations.add(new Locations(i.toString(), tempCoordinates['lat'], tempCoordinates['long'], data[i]['country'], data[i]['latest'], tempDeaths, tempRecovers, data[i]['province']));
    }
    markerGenerator();
  }

  void seperateData(){
    List seperateData = new List();
    for(int i=0; i<dataRecover.length; i++){
      var tempData = data[i]['country'];
      if(!seperateData.contains(tempData)){
        seperateData.add(tempData);
      }
    }
    seperateData.sort((a, b) => a.toString().compareTo(b.toString()));
    Navigator.push(context, new MaterialPageRoute(builder: (context) => new World(data: seperateData, dConfirmed: data, dRecover: dataRecover, dDeath: dataDeath)));
  }

  void markerGenerator(){
    MarkerGenerator(markerWidgets(), (bitmaps) {
      setState(() {
        markers = mapBitmapsToMarkers(bitmaps);
      });
    }).generate(context);
  }

  List<Marker> mapBitmapsToMarkers(List<Uint8List> bitmaps) {
    List<Marker> markersList = [];
    bitmaps.asMap().forEach((i, bmp) {
      final loc = locations[i];
      if(loc.latestCases != 0){
        markersList.add(Marker(
            markerId: MarkerId(loc.id),
            infoWindow: InfoWindow(title: loc.province != "" ? loc.province : loc.country),
            position: LatLng(double.parse(loc.lat), double.parse(loc.long)),
            icon: BitmapDescriptor.fromBytes(bmp),
            onTap: () {
              setState(() {
                cases = loc.latestCases.toString();
                deaths = loc.latestDeaths.toString();
                recover = loc.latestRecovers.toString();
                title = loc.province != "" ? loc.province + "/" + loc.country : loc.country;
              });
            }));
        }
    });
    return markersList;
  }

  Widget _getMarkerWidget(String id) {

    var temp = locations[int.parse(id)].latestCases;
    var tempWidth = 40.0;
    var tempHeight = 40.0;
    var color;

    if(temp < 10){
      setState(() {
        tempWidth = 40.0;
        tempHeight = 40.0;
        color = Color(0xFFFA8072);
      });
    }
    else if(temp >= 10 && temp < 100){
      setState(() {
        tempWidth = 48.0;
        tempHeight = 48.0;
        color = Color(0xFFff4d4d);
      });
    }
    else if(temp >= 100 && temp < 1000){
      setState(() {
        tempWidth = 56.0;
        tempHeight = 56.0;
        color = Color(0xFFff3333);
      });
    }
    else if(temp >= 1000 && temp < 10000){
      setState(() {
        tempWidth = 64.0;
        tempHeight = 64.0;
        color = Color(0xFFff1a1a);
      });
    }
    else if(temp >= 10000 && temp < 100000){
      setState(() {
        tempWidth = 72.0;
        tempHeight = 72.0;
        color = Color(0xFFb30000);
      });
    }
    else if(temp >= 100000 && temp < 1000000){
      setState(() {
        tempWidth = 80.0;
        tempHeight = 80.0;
        color = Color(0xFFb30000);
      });
    }

    return Container(
      width: tempWidth,
      height: tempHeight,
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white,
            width: 2
          ),
          borderRadius: BorderRadius.circular((tempHeight / 2.0)),
          color: color
      ),
      child: Center(
        child: Text(temp.toString(), style: TextStyle(color: Colors.white)),
      ),
    );
  }

  List<Widget> markerWidgets() {
    return locations.map((c) => _getMarkerWidget(c.id)).toList();
  }
}