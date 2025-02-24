import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherHomePage extends StatefulWidget {
  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {

  //use map because we need to show single Data Object

  Map<String, dynamic>? _weatherData;

  
  bool isLoading = false;
  String? _errorMsg;
  TextEditingController _cityController = TextEditingController();
  final String _apiKey = '3fe9dcd7530447988af145451252202';

  fetchData(String city) async {
    setState(() {
      isLoading = true;
      _errorMsg = null;
    });

    final searchCity = city.isEmpty ? "New Delhi" : city;

    final url = Uri.parse(
        'http://api.weatherapi.com/v1/current.json?key=$_apiKey&q=$searchCity');

    try {
      var response = await http.get(url);
      var data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          _weatherData = data;
        });
      } else {
        setState(() {
          _errorMsg = "City not found";
        });
      }
    } catch (e) {
      setState(() {
        _errorMsg = "failed to fetch data";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  //show details

  Widget _buildWeatherInfo() {
    if (isLoading) {
      return CircularProgressIndicator();
    } else if (_errorMsg != null) {
      return Center(
        child: Text(_errorMsg!),
      );
    } else if (_weatherData == null) {
      return Center(
        child: Text(
          "Enter City to get Weather Data",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );
    } else {
      return Column(
        children: [
          Text(
            _weatherData!["location"]["name"],
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          Text(
            _weatherData!["location"]["region"],
            style: const TextStyle(
                color: Colors.grey, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 10,
          ),
          Image.network(
              "https:${_weatherData!["current"]["condition"]["icon"]}"),
          Text(
            "${_weatherData!["current"]["temp_c"]}°C,",
            style: const TextStyle(fontSize: 48),
          ),
          Text(
            _weatherData!['current']['condition']['text'],
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 5),
          Text('Wind: ${_weatherData!['current']['wind_kph']} km/h'),
          Text('Humidity: ${_weatherData!['current']['humidity']}%'),
        ],
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData("New Delhi");
  }

  //change background according to temperature

  Color _getBackgroundColor(double temp) {
    if (temp < 15) {
      return Colors.lightBlue.shade200; // Cold
    } else if (temp >= 15 && temp <= 30) {
      return Colors.green.shade200; // Moderate
    } else {
      return Colors.orange.shade200; // Hot
    }
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor = _getBackgroundColor(_weatherData?["current"]["temp_c"]??25);

    return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: Text("Weather App"),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _cityController,
                  decoration: InputDecoration(
                      labelText: "Enter City",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          fetchData(_cityController.text.toString());
                        },
                      )),
                ),
                SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                    onPressed: () {
                      fetchData(_cityController.text.toString());
                    },
                    child: Text("Check")),
                SizedBox(
                  height: 15,
                ),
                _buildWeatherInfo(),
              ],
            ),
          ),
        ));
  }
}
