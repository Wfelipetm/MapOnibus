import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

import 'LocationTracker.dart';
import 'map_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Mapa com Marcadores Animados'),
        ),
        body: MyAppBody(),
      ),
    );
  }
}

class MyAppBody extends StatefulWidget {
  @override
  _MyAppBodyState createState() => _MyAppBodyState();
}

class _MyAppBodyState extends State<MyAppBody> with TickerProviderStateMixin {
  final ValueNotifier<List<AnimatedMarker>> markers = ValueNotifier([]);
  late AnimatedMapController animatedMapController;
  late Timer _timer;
  bool _trackingStarted = false;

  @override
  void initState() {
    super.initState();
    animatedMapController = AnimatedMapController(vsync: this);
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      _updateUserLocation();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: MapView(
            animatedMapController: animatedMapController,
            markers: markers,
            onUserLocationUpdate: (LatLng userLocation) {
              _updateMapMarker(userLocation);
            },
          ),
        ),
        LocationTracker(
          onLocationUpdate: (LatLng userLocation) {
            _updateMapMarker(userLocation);
          },
        ),
        FloatingActionButton(
          onPressed: () {
            if (!_trackingStarted) {
              _startTracking();
            }
          },
          child: Icon(Icons.play_arrow),
        ),
      ],
    );
  }

  void _startTracking() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      _getCurrentLocation();
      setState(() {
        _trackingStarted = true;
      });
    } else {
      print('Permissão de localização negada');
    }
  }

  void _updateMapMarker(LatLng userLocation) {
    animatedMapController.animateTo(dest: userLocation);
    markers.value = [
      AnimatedMarker(
        point: userLocation,
        width: 50.0,
        height: 50.0,
        builder: (context, animation) {
          final size = 50.0 * animation.value;
          return Opacity(
            opacity: animation.value,
            child: Icon(
              Icons.directions_bus,
              size: size,
            ),
          );
        },
      ),
    ];
  }

  void _updateUserLocation() async {
    if (_trackingStarted) {
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final LatLng userLocation = LatLng(position.latitude, position.longitude);
      _updateMapMarker(userLocation);
    }
  }

  void _getCurrentLocation() async {
    try {
      print('Obtendo localização atual...');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print('Localização obtida: $position');

      final LatLng userLocation = LatLng(position.latitude, position.longitude);
      _updateMapMarker(userLocation);

      print('Localização armazenada localmente.');
    } catch (e) {
      print('Erro ao obter a localização: $e');
    }
  }
}
