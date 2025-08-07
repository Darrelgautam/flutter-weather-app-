import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  static const String _apiKey = 'bd5e378503939ddaee76f12ad7a97608';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  Future<WeatherModel> getCurrentWeather(String cityName) async {
    final url = '$_baseUrl/weather?q=$cityName&appid=$_apiKey&units=metric';
    
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherModel.fromJson(data);
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching weather data: $e');
    }
  }

  Future<WeatherModel> getCurrentWeatherByCoordinates(double lat, double lon) async {
    final url = '$_baseUrl/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric';
    
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherModel.fromJson(data);
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching weather data: $e');
    }
  }

  Future<List<ForecastModel>> getForecast(String cityName) async {
    final url = '$_baseUrl/forecast?q=$cityName&appid=$_apiKey&units=metric';
    
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> forecastList = data['list'];
        
        return forecastList
            .map((item) => ForecastModel.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to load forecast data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching forecast data: $e');
    }
  }
}
