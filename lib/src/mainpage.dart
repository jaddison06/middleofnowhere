import 'package:flutter/material.dart';
import 'startscreen.dart';
import 'loadingscreen.dart';
import 'resultsscreen.dart';
import 'package:latlong2/latlong.dart';
import 'engine.dart';
import 'futurewithdefault.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  LatLng? userPos;
  late final Future<List<LatLng>> points;
  late final MONEngine engine;
  var loadingProgress = 0.0;
  var loadingMessage = '';

  @override
  void initState() {
    super.initState();
    engine = MONEngine(
      onLoadingMessageUpdate: (message) => setState(() => loadingMessage = message),
      onProgressUpdate: (progress) => setState(() => loadingProgress = progress)
    );
  }

  @override
  Widget build(BuildContext context) {
    if (userPos == null) {
      return StartScreen(onHaveGotUserLocation: (pos) => setState(() {
        userPos = pos;
        points = engine.getPoints(pos);
      }));
    }
    return FutureWithDefault(
      builder: () async {
        return ResultsScreen(points: await points, startPos: userPos!);
      },
      show: LoadingScreen(progress: loadingProgress, message: loadingMessage)
    );
  }
}