import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'map.dart';
import 'colorscheme.dart';
import 'buttons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'overpass.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';

class ResultsScreen extends StatefulWidget {
  final List<LatLng> points;
  final LatLng startPos;
  ResultsScreen({super.key, required this.points, required this.startPos});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> with TickerProviderStateMixin {
  int? highlightedPoint;
  bool isSmallScreen(BuildContext context) => MediaQuery.of(context).size.width < 450;
  var showMenu = false;

  late final AnimatedMapController mapController;
  late final AnimationController fabController;
  late final Animation<double> fabAnim;

  @override
  void initState() {
    super.initState();
    mapController = AnimatedMapController(
      vsync: this,
    );
    fabController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 450)
    );
    fabAnim = Tween(begin: 1.0, end: 0.0).animate(fabController);
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  void onPointPressed(int pointID) => setState(() {
    if (highlightedPoint == pointID) {
      highlightedPoint = null;
      mapController.animateTo(dest: widget.startPos, zoom: 12);
    }
    else {
      highlightedPoint = pointID;
      mapController.animateTo(dest: widget.points[pointID], zoom: 15);
    }
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: isSmallScreen(context) ? FloatingActionButton(
        onPressed: () {
          setState(() => showMenu = !showMenu);
          fabController.toggle();
        },
        child: AnimatedIcon(
          icon: AnimatedIcons.close_menu,
          progress: fabAnim,
        ),
      ) : null,
      body: Row(
        children: [
          Expanded(
            child: Map(
              controller: mapController.mapController,
              startPos: widget.startPos,
              points: widget.points,
              highlightedPoint: highlightedPoint,
              onPointPressed: onPointPressed
            )
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 450),
            width: isSmallScreen(context)
              ? showMenu
                ? 250
                : 0
              : 250,
            child: ListView(
              children: [...widget.points.map((point) {
                final pointID = widget.points.indexOf(point);
                final selected = highlightedPoint == pointID;
                return Padding(
                  padding: EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () => onPointPressed(pointID),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: selected ? context.cs.primary : context.cs.primaryContainer,
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Text(point.toStringPretty,
                        style: TextStyle(
                          color: selected ? context.cs.onPrimary : context.cs.onPrimaryContainer
                        ),
                      ),
                    ),
                  ),
                );}),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: PrimaryButton(
                    'Open selected in Maps',
                    fontSize: 14,
                    onPressed: () {
                      if (highlightedPoint != null) {
                        launchUrl(Uri.parse('https://www.google.com/maps/search/?api=1&query=${widget.points[highlightedPoint!].toStringPretty.replaceAll(' / ', ' ').replaceAll(' ', '+')}'));
                      }
                    },
                  ),
                ),
                Container(
                  width: 185,
                  child: Text('MON does not guarantee the suitability or safety of any of these locations!', textAlign: TextAlign.center)
                )
              ]
            ),
          ),
        ],
      ),
    );
  }
}