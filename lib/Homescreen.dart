import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? temp;

  String location = 'Jonggol';
  String weather = 'thunderstorm';

  //membuat var untuk kode loc nya
  int woeid = 44418;
  String errorMessage = '';

  //var untuk menampung gambar iconya
  String abbreviation = '';

  //membuat var list untuk menampung data list min dan max dan juga icon semalma 7 hari
  var minTemperatureForecast = List.filled(7, 0);
  var maxTemperatureFOrecast = List.filled(7, 0);
  var abbreviationForecast = List.filled(7, ' ');

  //masukan link url api untuk search
  String searchApiUrl = 'https://www.metaweather.com/api/location/search/?query=';

  //masukan link url api untuk data location
  String searchLocation = 'https://www.metaweather.com/api/location/';


  @override
  void initState() {
    getLocation();
    getSevenDays();
    super.initState();
  }

  Future<void> getLocation() async {
    var locationApiResult = await http.get(
        Uri.parse(searchLocation + woeid.toString()));
    var result = jsonDecode(locationApiResult.body);
    var consolidatedWeather = result["consolidated_weather"];
    var data = consolidatedWeather[0];

    setState(() {
      temp = data['the_temp'].round();
      weather = data['weather_state_name'].replaceAll(' ', '').toLowerCase();
      abbreviation = data['weather_state_abbr'];
    });
  }

  Future<void> getSearch(String input) async {
    try {
      var searchResult = await http.get(Uri.parse(searchApiUrl + input));
      var result = jsonDecode(searchResult.body)[0];

      setState(() {
        location = result['title'];
        woeid = result['woeid'];
        errorMessage = '';
      });
    } catch (error) {
      setState(() {
        errorMessage =
        'Sorry, we dont have information of the city youve searched';
      });
    }
  }

  Future<void> getSevenDays() async {
    var today = DateTime.now();
    for(var i = 0; i < 7; i++){
      var sevenDaysResult = await http.get(Uri.parse(searchLocation + woeid.toString() + '/' + DateFormat('y/M/d').format(today.add(Duration(days: i + 1))).toString()));
      var result = jsonDecode(sevenDaysResult.body);
      var data = result[0];

      setState(() {
        minTemperatureForecast[i] = data['min_temp'].round();
        maxTemperatureFOrecast[i] = data['max_temp'].round();
        abbreviationForecast[i] = data['weather_state_abbr'];
      });
    }
  }

    //buat function untuk ,enerima inputan di search bar
  Future<void> onTextFieldSubmitted(String input) async {
      await getLocation();
      await getSearch(input);
      await getSevenDays();
    }

    @override
    Widget build(BuildContext context) {
      return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('asset/$weather.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.6), BlendMode.dstATop)
            )
        ), child: temp == null ? const Center(child: CircularProgressIndicator())
         : Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 100),
          child: Column(
            children: [
              // menampilkan item, temperature, dan location. vvvv
              Column(
                children: [
                  Center(
                    child: Image.network(
                        'https://www.metaweather.com/static/img/weather/png/' + abbreviation + '.png',
                        width: 100),
                  ),
                  Center(
                    child: Text(temp.toString() + '°C', style: const TextStyle(
                        color: Colors.white, fontSize: 60
                    ),
                    ),
                  ),
                  Center(
                    child: Text(location, style: const TextStyle(
                        color: Colors.white, fontSize: 60
                    ),
                    ),
                  )
                ],
              ),
              //untuk menampilkan widget data selama 7 hari
              Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for(var i = 0 ; i < 7 ; i++)
                          forecastElement(
                              i + 1,
                              abbreviationForecast[i],
                              maxTemperatureFOrecast[i],
                              minTemperatureForecast[i])
                      ],
                    ),
                  ),
              ),
              // membuat search bar
              Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Column(
                  children: [
                    SizedBox(
                      width: 300,
                      child: TextField(
                        onSubmitted: (String input) {
                          onTextFieldSubmitted(input);
                        },
                        style: const TextStyle(
                            color: Colors.white, fontSize: 25
                        ),
                        decoration: const InputDecoration(
                            hintText: 'Search a location...',
                            hintStyle: TextStyle(
                                color: Colors.white, fontSize: 18
                            ),
                            prefixIcon: Icon(Icons.search, color: Colors.white,)
                        ),
                      ),
                    ),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 15
                      ),
                    ),
                    )
                  ],
                ),)
            ],
          ),
        ),
      ),
      );
    }

    Widget forecastElement(daysFromNow, abbreviation, maxTemp, minTemp){
      var now = DateTime.now();
      var oneDayFromNow = now.add(Duration(days: daysFromNow));
      return Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Container(
          decoration: BoxDecoration(
            color: const Color.fromRGBO(205, 212, 228, 0.3),
            borderRadius: BorderRadius.circular(10)
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(DateFormat.E().format(oneDayFromNow),
                  style: const TextStyle(color: Colors.white, fontSize: 25),
                ),
                Text(DateFormat.MMMd().format(oneDayFromNow),
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
                Padding(padding: const EdgeInsets.symmetric(vertical: 16),
                child: Image.network(
                  'https://www.metaweather.com/static/img/weather/png/' + abbreviation + '.png',
                  width: 50,
                ),
                ),
                Text('High ' + maxTemp.toString() + '°C',
                style: const TextStyle(color: Colors.white, fontSize: 20),),
                Text('Low ' + minTemp.toString() + '°C',
                  style: const TextStyle(color: Colors.white, fontSize: 20),),
              ],
            ),
          ),
      ),
      );
  }
}
