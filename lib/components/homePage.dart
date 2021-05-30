import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';
import 'package:weather_app/components/searchForm.dart';
import 'package:weather_app/components/weatherCard.dart';

import 'package:weather_app/helpers/weather.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Position? _position;
  String _city = '';
  int _temp = 0;
  String _icon = '04n';
  String _desc = '';
  Color _color = Colors.white;
  WeatherFetch _weatherFetch = new WeatherFetch();

  @override
  void initState() {
    super.initState();
    _getCurrentPosition();
  }

  void updateData(weatherData) {
    setState(() {
      if (weatherData != null) {
        _temp = weatherData['main']['temp'].toInt();
        _icon = weatherData['weather'][0]['icon'];
        _desc = weatherData['main']['feels_like'].toString();
        _color = _getBackgroundColor(_temp);
      } else {
        _temp = 0;
        _city = 'In the middle of nowhere';
        _icon = '04n';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Search(parentCallback: _changeCity),
            Text(_city,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                )),
            if (_city != '')
              WeatherCard(
                title: _desc,
                temperature: _temp,
                iconCode: _icon,
              ),
          ],
        ),
      ),
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0, 1.0],
              colors: [_color, Colors.white])),
    ));
  }

  void _getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    try {
      await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
          .then((Position position) {
        setState(() {
          _position = position;
        });

        _getCityAndWeather();
      });
    } catch (err) {
      print('_getCurrentPosition error: $err');
    }
  }

  void _getCityAndWeather() async {
    try {
      List<Placemark> placemark =
          await placemarkFromCoordinates(_position!.latitude, _position!.longitude);
      Placemark place = placemark[0];
      var dataDecoded =
          await _weatherFetch.getWeatherByCoords(_position!.latitude, _position!.longitude);
      updateData(dataDecoded);
      setState(() {
        _city = '${place.locality}';
      });
    } catch (err) {
      print('_getCityAndWeather error: $err');
    }
  }

  Color _getBackgroundColor(temp) {
    if (temp > 25) return Colors.orange;
    if (temp > 15) return Colors.yellow;
    if (temp <= 0) return Colors.blue;
    return Colors.white;
  }

  void _changeCity(city) async {
    try {
      var dataDecoded = await _weatherFetch.getWeatherByName(city);
      updateData(dataDecoded);
      setState(() {
        _city = city;
      });
    } catch (err) {
      print('_changeCity error: $err');
    }
  }
}
