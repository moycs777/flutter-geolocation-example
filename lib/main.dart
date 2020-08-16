import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.blue,

        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);


  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  Position _currentPosition;
  String _currentAddress;
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  final locationOptions = LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 1);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_currentPosition != null)
              Text(
                  "LAT: ${_currentPosition.latitude}, LNG: ${_currentPosition.longitude} "),
            if(_currentAddress != null) Text(" address: ${_currentAddress}"),
            FlatButton(
              child: Text("!Get location"),
              onPressed: () {
                print("get current location");
                _getCurrentLocation();
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _listenToLocationChange();
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  _listenToLocationChange(){
    print("_listenToLocationChange");
    StreamSubscription<Position> positionStream = geolocator.getPositionStream(locationOptions).listen(
    (Position position) {
        print(position == null ? 'Unknown' : position.latitude.toString() + ', ' + position.longitude.toString());
    });
  }

  _getCurrentLocation() async {

    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });

      _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    print("_getAddressFromLatLng");
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];
      print(place);
      setState(() {
        _currentAddress =
            "${place.thoroughfare}, ${place.subThoroughfare}, ${place.locality}, ${place.subLocality}, ${place.postalCode},  "
                "${place.administrativeArea}, ${place.subAdministrativeArea}, ${place.country}, ";
      });
    } catch (e) {
      print(e);
    }
  }

}
