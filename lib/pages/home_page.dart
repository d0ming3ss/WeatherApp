import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:weather/weather.dart';
import 'package:weatherapp/consts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final WeatherFactory _wf = WeatherFactory(OPEN_WEATHER_API_KEY);
  final TextEditingController _cityController = TextEditingController();
  Weather? _weather;
  String _currentCity = "Wrocław";

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  void _fetchWeather() {
    _wf.currentWeatherByCityName(_currentCity).then((w) {
      setState(() {
        _weather = w;
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to download weather data")),
      );
    });
  }

  String _getLottieAsset(String? weatherMain) {
    if (weatherMain == null) {
      return 'assets/sunny_cloud.json';
    }
    switch (weatherMain.toLowerCase()) {
      case 'clouds':
        return 'assets/cloud.json';
      case 'clear':
        return 'assets/sunny.json';
      case 'light rain':
      case 'rain':
      case 'shower rain':
      case 'drizzle':
        return 'assets/sunny_rain.json';
      case 'thunderstorm':
        return 'assets/thunder.json';
      case 'snow':
        return 'assets/snow.json';
      case 'mist':
      case 'fog':
      case 'haze':
      case 'dust':
      case 'smoke':
        return 'assets/mist_wind.json';
      default:
        return 'assets/sunny_cloud.json';
    }
  }

  Color _getBackgroundColor(String? weatherMain) {
    if (weatherMain == null) {
      return const Color.fromARGB(255, 161, 161, 161);
    }
    switch (weatherMain.toLowerCase()) {
      case 'clear':
        return const Color.fromARGB(255, 255, 165, 0);
      case 'clouds':
        return const Color.fromARGB(255, 128, 128, 128);
      case 'rain':
      case 'light rain':
      case 'shower rain':
      case 'drizzle':
        return const Color.fromARGB(255, 0, 119, 182);
      case 'thunderstorm':
        return const Color.fromARGB(255, 46, 139, 87);
      case 'snow':
        return const Color.fromARGB(255, 255, 255, 255);
      case 'mist':
      case 'fog':
      case 'haze':
      case 'dust':
      case 'smoke':
        return const Color.fromARGB(255, 184, 162, 217);
      default:
        return const Color.fromARGB(255, 161, 161, 161);
    }
  }

  @override
  Widget build(BuildContext context) {
    String? weatherMain = _weather?.weatherMain;
    return Scaffold(
      backgroundColor: _getBackgroundColor(weatherMain),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.7,
                  child: TextField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: "Enter the city name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _currentCity = _cityController.text.isEmpty
                          ? "Wrocław"
                          : _cityController.text;
                    });
                    _fetchWeather();
                  },
                  icon: const Icon(Icons.arrow_forward,
                      size: 30, color: Colors.black),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildUI(),
          ),
        ],
      ),
    );
  }

  Widget _buildUI() {
    if (_weather == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      height: MediaQuery.sizeOf(context).height,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _locationHeader(),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.05,
          ),
          _dateTimeInfo(),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.03,
          ),
          _weatherIcon(),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.02,
          ),
          _currentTemperature(),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.02,
          ),
          _extraInfo(),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.02,
          ),
        ],
      ),
    );
  }

  Widget _locationHeader() {
    return Text(_weather?.areaName ?? "",
        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w500));
  }

  Widget _dateTimeInfo() {
    DateTime now = DateTime.now();
    return Column(
      children: [
        Text(DateFormat("h:mm a").format(now),
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(DateFormat("EEEE").format(now),
                style: const TextStyle(fontWeight: FontWeight.w600)),
            Text("  ${DateFormat("d.M.y").format(now)}",
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        )
      ],
    );
  }

  Widget _weatherIcon() {
    String? weatherMain = _weather?.weatherMain;
    String lottieAsset = _getLottieAsset(weatherMain);

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.25,
          child: Lottie.asset(lottieAsset),
        ),
        Text(_weather?.weatherDescription ?? "",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _currentTemperature() {
    return Text("${_weather?.temperature?.celsius?.round()}° C",
        style: const TextStyle(fontSize: 75, fontWeight: FontWeight.w700));
  }

  Widget _extraInfo() {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.20,
      width: MediaQuery.sizeOf(context).width * 0.8,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(179, 14, 2, 0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Max: ${_weather?.tempMax?.celsius?.round()}° C",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500)),
              Text("Min: ${_weather?.tempMin?.celsius?.round()}° C",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500))
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Wind: ${_weather?.windSpeed?.round()} m/s",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500)),
              Text("Humidity: ${_weather?.humidity?.round()} %",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500))
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Pressure: ${_weather?.pressure} hPa",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}
