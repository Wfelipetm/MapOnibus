import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationTracker extends StatefulWidget {
  final Function(LatLng) onLocationUpdate;

  LocationTracker({required this.onLocationUpdate});

  @override
  _LocationTrackerState createState() => _LocationTrackerState();
}

class _LocationTrackerState extends State<LocationTracker> {
  Position? _currentPosition;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      Duration(seconds: 1),
      (Timer t) =>
          _getCurrentLocation(), // Atualiza a localização automaticamente a cada 1 segundo.
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (_currentPosition != null)
            Text(
              'Latitude: ${_currentPosition!.latitude}\nLongitude: ${_currentPosition!.longitude}',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  _getCurrentLocation() async {
    try {
      print('Obtendo localização atual...');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print('Localização obtida: $position');

      setState(() {
        _currentPosition = position;
      });

      widget.onLocationUpdate(LatLng(position.latitude, position.longitude));

      print('Localização armazenada localmente.');
    } catch (e) {
      print('Erro ao obter a localização: $e');
    }
  }
}
