import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class ForecastCard extends StatelessWidget {
  final ForecastModel forecast;

  const ForecastCard({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Time
          Text(
            _formatTime(forecast.dateTime),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          
          // Weather Icon
          Image.network(
            forecast.iconUrl,
            width: 32,
            height: 32,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.wb_sunny,
                size: 32,
                color: Colors.white,
              );
            },
          ),
          const SizedBox(height: 8),
          
          // Temperature
          Text(
            '${forecast.temperature.round()}°',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$displayHour $period';
  }
}
