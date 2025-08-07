import 'dart:ui'; // Needed for ImageFilter.blur

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';
import '../widgets/weather_card.dart';
import '../widgets/forecast_card.dart';
import '../widgets/weather_details.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();
  final TextEditingController _cityController = TextEditingController();

  WeatherModel? _currentWeather;
  List<ForecastModel> _forecast = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _getCurrentLocationWeather();
  }

  Future<void> _getCurrentLocationWeather() async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      Position? position = await _locationService.getCurrentLocation();
      if (position != null) {
        await _fetchWeather(
          lat: position.latitude,
          lon: position.longitude,
        );
      } else {
        await _fetchWeather(cityName: 'London');
      }
    } catch (e) {
      setState(() {
        _error = "Failed to fetch weather data. Please try again.";
        _isLoading = false;
      });
    }
  }

  Future<void> _getWeatherByCity(String cityName) async {
    if (cityName.isEmpty) return;
    _cityController.clear();
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _fetchWeather(cityName: cityName);
    } catch (e) {
      setState(() {
        _error = "Could not find weather for '$cityName'.";
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchWeather({String? cityName, double? lat, double? lon}) async {
    try {
      final weather = cityName != null
          ? await _weatherService.getCurrentWeather(cityName)
          : await _weatherService.getCurrentWeatherByCoordinates(lat!, lon!);

      final forecast = await _weatherService.getForecast(weather.cityName);

      setState(() {
        _currentWeather = weather;
        _forecast = forecast.take(5).toList();
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      rethrow;
    }
  }

  // UPDATED: Changed to a static black and red gradient
  LinearGradient _getWeatherGradient() {
    return LinearGradient(
      colors: [
        Colors.black,
        Colors.red.shade900,
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  Widget _buildGlassmorphicContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.0,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(gradient: _getWeatherGradient()),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _getCurrentLocationWeather,
            backgroundColor: Colors.grey.shade900,
            color: Colors.red,
            child: CustomScrollView(
              // FIX: Using CustomScrollView with conditional slivers to prevent overflow
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _cityController,
                            decoration: InputDecoration(
                              hintText: 'Search for a city...',
                              filled: true,
                              fillColor: Colors.black.withOpacity(0.4),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon:
                                  const Icon(Icons.search, color: Colors.white70),
                              hintStyle: const TextStyle(color: Colors.white70),
                            ),
                            style: const TextStyle(color: Colors.white),
                            onSubmitted: _getWeatherByCity,
                          ),
                        ),
                        const SizedBox(width: 10),
                        CircleAvatar(
                          backgroundColor: Colors.black.withOpacity(0.4),
                          child: IconButton(
                            onPressed: _getCurrentLocationWeather,
                            icon: const Icon(Icons.my_location, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isLoading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  )
                else if (_error != null)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: _buildErrorWidget(),
                    ),
                  )
                else if (_currentWeather != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: _buildWeatherContent(),
                    ),
                  )
                else
                  const SliverFillRemaining(
                    hasScrollBody: false,
                     child: Center(
                        child: Text(
                      'Search for a city to begin.',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                      textAlign: TextAlign.center,
                    )),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherContent() {
    return Column(
      children: [
        WeatherCard(weather: _currentWeather!),
        const SizedBox(height: 24),
        _buildGlassmorphicContainer(
          child: WeatherDetails(weather: _currentWeather!),
        ),
        const SizedBox(height: 24),
        if (_forecast.isNotEmpty) ...[
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '5-Day Forecast',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _forecast.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: _buildGlassmorphicContainer(
                      child: ForecastCard(forecast: _forecast[index])),
                );
              },
            ),
          ),
        ],
        const SizedBox(height: 20), // Padding at the bottom
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.wifi_off_rounded, color: Colors.white70, size: 80),
        const SizedBox(height: 20),
        Text(
          _error ?? 'An unknown error occurred.',
          style: const TextStyle(color: Colors.white, fontSize: 18),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _getCurrentLocationWeather,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.9),
            // UPDATED: Button color to match the theme
            foregroundColor: Colors.red.shade900,
          ),
          child: const Text('Retry'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }
}