import 'package:flutter/material.dart';
import 'package:firebase_admob/firebase_admob.dart';

class Information extends StatefulWidget {
  @override
  _InformationState createState() => _InformationState();
}

class _InformationState extends State<Information> {

  BannerAd _bannerAd;

  static final MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    keywords: <String>['flutterio', 'beautiful apps'],
    contentUrl: 'https://flutter.io',// or MobileAdGender.female, MobileAdGender.unknown
    testDevices: <String>[], // Android emulators are considered test devices
  );

  BannerAd createBannerAd(){
    return BannerAd(
      adUnitId: 'ca-app-pub-9779348411183591/6891078650',
      size: AdSize.smartBanner,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("BannerAd event is $event");
      },
    );
  }

  @override
  void initState() {
    FirebaseAdMob.instance.initialize(appId: 'ca-app-pub-9779348411183591~9130229189');
    _bannerAd = createBannerAd()..load()..show();
    super.initState();
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Rules to Reduce Risks",style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0)),
      ),
      body: ListView(
        children: <Widget>[
          Column(
            children: <Widget>[
              new Image.asset("images/info.png"),
            ],
          ),
        ],
      ),
    );
  }
}

