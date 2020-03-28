import 'package:flutter/material.dart';
import 'package:flutter_app_cva/ui/MapScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';

class TutorialScreen extends StatefulWidget{

  TutorialScreen({Key key}) : super(key: key);

  @override
  TutorialScreenState createState() => new TutorialScreenState();
}

class TutorialScreenState extends State<TutorialScreen>{

  SharedPreferences sharedPrefs;
  List<Slide> slides = new List();

  @override
  void initState() {
    super.initState();

    slides.add(
      new Slide(
        title: "BEFORE YOU GET START CHECK THESE INFORMATIONS",
        maxLineTitle: 3,
        styleTitle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        description: "Wash hands frequently with soap and water or use a sanister gel",
        pathImage: "images/image1.png",
        backgroundColor: Color(0xff203152),
      ),
    );
    slides.add(
      new Slide(
        title: "CVA",
        maxLineTitle: 3,
        styleTitle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        description: "Catch coughs and sneezes with disposable tissues",
        pathImage: "images/image2.png",
        backgroundColor: Color(0xff203152),
      ),
    );
    slides.add(
      new Slide(
        title: "CVA",
        maxLineTitle: 3,
        styleTitle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        description:
        "Throw away used tissues",
        pathImage: "images/image3.png",
        backgroundColor: Color(0xff203152),
      ),
    );
    slides.add(
      new Slide(
        title: "CVA",
        maxLineTitle: 3,
        styleTitle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        description:
        "If you don't have a tissue use your sleeve",
        pathImage: "images/image4.png",
        backgroundColor: Color(0xff203152),
      ),
    );
    slides.add(
      new Slide(
        title: "CVA",
        maxLineTitle: 3,
        styleTitle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        description:
        "Avoid touching your eyes, nose and mouth with unwashed hands",
        pathImage: "images/image5.png",
        backgroundColor: Color(0xff203152),
      ),
    );
    slides.add(
      new Slide(
        title: "CVA",
        maxLineTitle: 3,
        styleTitle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        description:
        "Avoid close contact with people who are unwell",
        pathImage: "images/image6.png",
        backgroundColor: Color(0xff203152),
      ),
    );
  }

  void onDonePress() {
    addStringToSF();
    Navigator.push(context, new MaterialPageRoute(builder: (context) => new MapScreen()));
  }

  Future<bool> _getPrefs() async{
    sharedPrefs = await SharedPreferences.getInstance();
    return sharedPrefs.getBool('checkbox');
  }

  addStringToSF() async {
    sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setBool('checkbox', true);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getPrefs(),
      builder: (context, snapshot){
        return snapshot.hasData
          ? MapScreen() : IntroSlider(
        slides: this.slides,
        onDonePress: this.onDonePress,
        );
      },
    );
  }
}