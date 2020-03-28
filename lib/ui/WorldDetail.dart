import 'package:flutter/material.dart';
import 'package:flutter_app_cva/charts/Charts.dart';
import 'package:flutter_app_cva/classes/Country.dart';

class World extends StatefulWidget {

  final data, dConfirmed, dRecover, dDeath;

  World({this.data, this.dConfirmed, this.dRecover, this.dDeath});

  @override
  _WorldState createState() => _WorldState();
}

class _WorldState extends State<World> {
  // final formKey = new GlobalKey<FormState>();
  // final key = new GlobalKey<ScaffoldState>();
  final TextEditingController _filter = new TextEditingController();
  final FocusNode _filterFocus = FocusNode();

  List<Country> _country;
  String _searchText = "";
  List names = new List();
  List filteredNames = new List();
  Icon _searchIcon = new Icon(Icons.search);
  Widget _appBarTitle = new Text('Country Detail', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0));

  _WorldState() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _searchText = "";
          filteredNames = names;
        });
      } else {
        setState(() {
          _searchText = _filter.text;
        });
      }
    });
  }

  @override
  void initState() {
    this._getNames();
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildBar(context),
      body: Container(
        child: _buildList(),
      ),
      resizeToAvoidBottomPadding: false,
    );
  }

  Widget _buildBar(BuildContext context) {
    return new AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            FocusScope.of(context).requestFocus(new FocusNode()); //remove focus
            WidgetsBinding.instance.addPostFrameCallback((_) => _filter.clear());
            Navigator.of(context).pop();
          }
      ),
      centerTitle: true,
      title: _appBarTitle,
      actions: <Widget>[
        new IconButton(
          icon: _searchIcon,
          onPressed: _searchPressed,
        )
      ],
    );
  }

  Widget _buildList() {
    if (_searchText.isNotEmpty) {
      List tempList = new List();
      for (int i = 0; i < filteredNames.length; i++) {
        if (filteredNames[i].toLowerCase().contains(_searchText.toLowerCase())) {
          tempList.add(filteredNames[i]);
        }
      }
      filteredNames = tempList;
    }
    return ListView.builder(
      itemCount: names == null ? 0 : filteredNames.length,
      itemBuilder: (BuildContext context, int index) {
        return new ListTile(
          title: Text(filteredNames[index]),
          onTap: () {
            _getAllData(filteredNames[index]);
          },
        );
      },
    );
  }

  void _getAllData(country){
    int sumConfirmed = 0;
    int sumRecoverd = 0;
    int sumDeaths = 0;
    String countryCode = "";
    _country = new List<Country>();
    for(int i=0; i<widget.dRecover.length; i++){
      var tempCD = widget.dRecover[i]['country'];
      var tempCDL = widget.dConfirmed[i]['latest'];
      var tempRDL = widget.dRecover[i]['latest'];
      var tempDDL = widget.dDeath[i]['latest'];
      if(tempCD == country){
        countryCode = widget.dConfirmed[i]['country_code'];
        sumConfirmed = sumConfirmed + tempCDL;
        sumRecoverd = sumRecoverd + tempRDL;
        sumDeaths = sumDeaths + tempDDL;
      }
    }
    //print(country + " " + sumConfirmed.toString() + " " + sumRecoverd.toString() + " " + sumDeaths.toString());
    _country.add(new Country(country, countryCode, sumConfirmed.toString(), sumRecoverd.toString(), sumDeaths.toString()));
    WidgetsBinding.instance.addPostFrameCallback((_) => _filter.clear());
    this._searchIcon = new Icon(Icons.close);
    _searchPressed();
    Navigator.push(context, new MaterialPageRoute(builder: (context) => new Chart(extra: _country)));
  }

  void _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = new Icon(Icons.close);
        this._appBarTitle = new TextField(
          autofocus: true,
          controller: _filter,
          focusNode: _filterFocus,
          textInputAction: TextInputAction.done,
          decoration: new InputDecoration(
              labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15.0),
              hintText: 'Search country',
              hintStyle: TextStyle(color: Colors.white)
          ),
        );
      } else {
        this._searchIcon = new Icon(Icons.search);
        this._appBarTitle = new Text('Country Detail', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0));
        filteredNames = names;
        _filter.clear();
      }
    });
  }

  void _getNames() async {
    List tempList = new List();
    tempList = widget.data;
    setState(() {
      names = tempList;
      filteredNames = names;
    });
  }
}
