import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'colorscheme.dart';
import 'package:themed/themed.dart';

class Map extends StatefulWidget {
  final List<LatLng> points;
  final LatLng startPos;
  final int? highlightedPoint;
  final void Function(int) onPointPressed;
  final MapController controller;
  const Map({super.key, required this.points, required this.startPos, this.highlightedPoint, required this.onPointPressed, required this.controller});

  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
  @override
  Widget build(BuildContext context) {
    return ChangeColors(
      brightness: -.15,
      saturation: -.15,
      child: FlutterMap(
        mapController: widget.controller,
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
          MarkerLayer(
            markers: widget.points.map((point) {
              final pointID = widget.points.indexOf(point);
              final selected = widget.highlightedPoint == pointID;
              final size = selected ? 25.0: 20.0;
              return Marker(
                point: point,
                width: size,
                height: size,
                child: GestureDetector(
                  onTap: () => widget.onPointPressed(widget.points.indexOf(point)),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: selected ? context.cs.surfaceBright : Colors.black,
                      borderRadius: BorderRadius.circular(20)
                    ),
                  ),
                )
              );
            }).toList()
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
      ),
    );
  }
}