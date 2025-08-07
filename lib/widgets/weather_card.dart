import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class WeatherCard extends StatelessWidget {
  final WeatherModel weather;

  const WeatherCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // City Name and Country
          Text(
            '${weather.cityName}, ${weather.country}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          // Weather Icon and Temperature
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                weather.iconUrl,
                width: 80,
                height: 80,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.wb_sunny,
                    size: 80,
                    color: Colors.white,
                  );
                },
              ),
              const SizedBox(width: 16),
              Text(
                '${weather.temperature.round()}°C',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Weather Description
          Text(
            weather.description.toUpperCase(),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          
          // Feels Like Temperature
          Text(
            'Feels like ${weather.feelsLike.round()}°C',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
