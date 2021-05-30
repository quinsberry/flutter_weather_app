import 'package:weather_app/helpers/constants.dart';
import 'package:weather_app/helpers/fetch.dart';

class WeatherFetch {
  Future<dynamic> getWeatherByCoords(double lat, double lon) async {
    FetchHelper fetchData = new FetchHelper(
        '$weatherMapURL?lat=$lat&lon=$lon&appid=$openWeatherMapKey&units=metric');

    return fetchData.getData();
  }

  Future<dynamic> getWeatherByName(String cityName) async {
    FetchHelper fetchData = new FetchHelper(
        '$weatherMapURL?q=$cityName&appid=$openWeatherMapKey&units=metric');

    return fetchData.getData();
  }
}
