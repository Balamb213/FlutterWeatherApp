import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailsScreen extends StatelessWidget {
  final Map<String, dynamic> weatherData;
  const DetailsScreen({Key? key, required this.weatherData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(weatherData['location']['name']),
      ),
      body: Column(
        children: [
          Image.network(
            'https:${weatherData['current']['condition']['icon']}',
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Min: ${weatherData['forecast']['forecastday'][0]['day']['mintemp_c']}°C / Max: ${weatherData['forecast']['forecastday'][0]['day']['maxtemp_c']}°C',
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 7,
              itemBuilder: (context, index) {
                // Parse the date string to DateTime
                DateTime date = DateTime.parse(
                    weatherData['forecast']['forecastday'][index]['date']);

                //Get the day name from the DateTime object
                String dayName = DateFormat('EEEE').format(date);

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ListTile(
                      title: Text(
                        dayName,
                        textAlign: TextAlign.left,
                      ),
                      trailing: Text(
                        'Min: ${weatherData['forecast']['forecastday'][index]['day']['mintemp_c']}°C / Max: ${weatherData['forecast']['forecastday'][index]['day']['maxtemp_c']}°C',
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
