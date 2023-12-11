import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';

// Definindo um TileUpdateTransformer para animação de movimento do mapa.
final _animatedMoveTileUpdateTransformer = TileUpdateTransformer.fromHandlers(
  handleData: (updateEvent, sink) {
    sink.add(updateEvent);
  },
);

class MapView extends StatelessWidget {
  final AnimatedMapController animatedMapController;
  final ValueNotifier<List<AnimatedMarker>> markers;
  final Function(LatLng)
      onUserLocationUpdate; // Função chamada quando a localização do usuário é atualizada.

  // Construtor da classe MapView.
  const MapView({
    Key? key,
    required this.animatedMapController,
    required this.markers,
    required this.onUserLocationUpdate,
  }) : super(key: key);

  // Obtém o TileUpdateTransformer para animação do mapa.
  TileUpdateTransformer? get tileUpdateTransformer =>
      _animatedMoveTileUpdateTransformer;

  @override
  Widget build(BuildContext context) {
    // Widget ValueListenableBuilder usado para reconstruir o FlutterMap sempre que a lista de marcadores (markers) é atualizada.
    return ValueListenableBuilder<List<AnimatedMarker>>(
      valueListenable: markers,
      builder: (context, markers, _) {
        return FlutterMap(
          // Configuração do FlutterMap.
          mapController: animatedMapController.mapController,
          options: MapOptions(
            initialCenter:
                const LatLng(-22.8665, -43.7772), // Centro inicial do mapa.
            // onTap: (_, point) =>
            //  _addMarker(point), // Adiciona um marcador no local do toque.
            maxZoom: 30.0,
          ),
          children: [
            // Camada de azulejos do OpenStreetMap.
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
              tileUpdateTransformer: tileUpdateTransformer,
              tileProvider: CancellableNetworkTileProvider(),
            ),
            // Camada de marcadores animados.
            AnimatedMarkerLayer(markers: markers),
          ],
        );
      },
    );
  }

  // Adiciona um marcador à lista de marcadores.
  void _addMarker(LatLng point) {
    markers.value = List.from(markers.value)
      ..add(
        AnimatedMarker(
          point: point,
          width: 50.0,
          height: 50.0,
          builder: (context, animation) {
            // Constrói um marcador animado.
            final size = 50.0 * animation.value;

            return GestureDetector(
              onTap: () {
                animatedMapController.animateTo(
                    dest: point); // Anima o mapa até o ponto do marcador.
                onUserLocationUpdate(
                    point); // Chama a função de atualização da localização do usuário.
              },
              child: Opacity(
                opacity: animation.value,
                child: Icon(
                  Icons.room, // Ícone do marcador.
                  size: size,
                ),
              ),
            );
          },
        ),
      );
  }
}
