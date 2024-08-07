import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'colorscheme.dart';

class Map extends StatefulWidget {
  final List<LatLng> points;
  final LatLng startPos;
  const Map({super.key, required this.points, required this.startPos});

  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
  late final MapController mapController;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: widget.startPos,
        initialZoom: 13
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.jaddison.middleofnowhere',
          tileProvider: CancellableNetworkTileProvider(),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: InkWell(
            onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: context.cs.primary,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(8))
              ),
              child: Text('OpenStreetMap', style: TextStyle(
                color: context.cs.onPrimary,
                fontSize: 11
              ))
            ),
          )
        )
      ],
    );
  }
}