import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/constants.dart';
import 'dart:convert';
import 'details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> cities = [Constants.defaultCity]; // Default city
  final apiKey = Constants.weatherApiKey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Constants.appTitile),
      ),
      body: ListView.builder(
        itemCount: cities.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              _navigateToDetailsScreen(
                  cities[index]); // Navigate to details screen
            },
            child: Padding(
              padding: const EdgeInsets.all(
                  8.0), // Add padding between each city container
              child: Container(
                decoration: BoxDecoration(
                  border:
                      Border.all(color: Colors.grey), // Add rectangular border
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(cities[index]), // City name aligns to the left
                      FutureBuilder(
                        future: fetchWeatherData(cities[index]),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return const Text(Constants.loadDataError);
                          } else if (snapshot.hasData) {
                            // Access data safely
                            final weatherData =
                                snapshot.data as Map<String, dynamic>;
                            final forecastWeather = weatherData['forecast']
                                ['forecast']['forecastday'][0]['day'];
                            // This is to easily access the attributes inside weatherData object
                            return Text(
                                'Min: ${forecastWeather['mintemp_c']}°C / Max: ${forecastWeather['maxtemp_c']}°C');
                          } else {
                            return const Text(Constants.noData);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addCity();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Method to add new city
  void _addCity() async {
    String newCity = '';
    // Show a dialog to get user input for new city
    newCity = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(Constants.addCity),
          content: TextField(
            decoration: const InputDecoration(labelText: Constants.enterCity),
            onChanged: (value) {
              newCity = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(Constants.cancelCta),
            ),
            TextButton(
              onPressed: () async {
                if (newCity.isNotEmpty) {
                  // Add the new city to the list
                  setState(() {
                    cities.add(newCity);
                  });
                  Navigator.of(context)
                      .pop(newCity); // Close the dialog and return new city
                  // If a new city was added, fetch its weather data
                  fetchWeatherData(newCity);
                } else {
                  // Show an alert dialog to enter a city name
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text(Constants.cityNameAlert),
                        content: const Text(Constants.cityValidationAlert),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text(Constants.validationAlertCta),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: const Text(Constants.addCta),
            ),
          ],
        );
      },
    );
  }

  Future<void> _navigateToDetailsScreen(String city) async {
    // Fetch weather data for the selected city
    Map<String, dynamic> weatherData = await fetchWeatherData(city);
    // Navigate to the details screen and pass the weather data

    // ignore: use_build_context_synchronously
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DetailsScreen(weatherData: weatherData['forecast']),
      ),
    );
  }

  Future<Map<String, dynamic>> fetchWeatherData(String city) async {
    const String baseUrl = Constants.baseUrl;
    final forecastResponse =
        await http.get(Uri.parse('$baseUrl?key=$apiKey&q=$city&days=7'));

    if (forecastResponse.statusCode == 200) {
      final forecastData = json.decode(forecastResponse.body);
      return {'forecast': forecastData};
    } else {
      throw Exception(Constants.weatherApiError);
    }
  }
}
