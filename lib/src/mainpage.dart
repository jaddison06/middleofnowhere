import 'package:flutter/material.dart';
import 'colorscheme.dart';
import 'padding.dart';
import 'buttons.dart';
import 'map.dart';
import 'engine.dart';
import 'package:latlong2/latlong.dart';
import 'overpass.dart';
import 'futurewithdefault.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  double nothingRadius = 280;
  double userRadius = 5000;
  // need this for the overpass call frfr
  final maxUserRadius = 15000.0;
  final startPos = LatLng(52.819210, 1.368957);

  late Future<List<LatLng>> infrastructure;
  List<LatLng> points = [];

  void loadInfrastructure() {
    // TODO yeah this is gonna be Engine code
    infrastructure = Overpass().getAllInfrastructure(
      BBox.fromCenterWithDimensionsMetres(center: startPos, width: maxUserRadius * 2, height: maxUserRadius * 2).expandSidesByMetres(nothingRadius)
    );
  }

  @override
  void initState() {
    super.initState();
    loadInfrastructure();
  }

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   backgroundColor: context.cs.surface,
    //   body: Center(child: Column(
    //     mainAxisSize: MainAxisSize.min,
    //     children: [
    //       PrimaryButton(
    //         'start',
    //         onPressed: (){},
    //       ),
    //       VPadding(50),
    //       SecondaryButton(
    //         'enter address manually',
    //         onPressed: (){},
    //       )
    //     ],
    //   )),
    // );
    return Scaffold(
      body: Center(
        child: FutureWithDefault(
          builder: () async {
            points.clear();
            final candidateBoxes = MONEngine(nothingRadius: nothingRadius, userRadius: userRadius).getCandidateAreas(startPos: startPos, infrastructure: await infrastructure);
            for (var box in candidateBoxes) points.addAll([box.minCorner, box.maxCorner]);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 800,
                  child: Map(
                    points: points,
                    startPos: LatLng(52.819210, 1.368957)
                  ),
                ),
                Slider(
                  value: nothingRadius,
                  min: 20,
                  max: 10000,
                  onChanged: (newVal) => setState(() {
                    nothingRadius = newVal;
            
                  }),
                ),
                Slider(
                  value: userRadius,
                  label: '$userRadius',
                  min: 700,
                  max: maxUserRadius,
                  onChanged: (newVal) => setState(() {
                    userRadius = newVal;
                  })
                ),
                Text('nothingRadius @${nothingRadius}m | userRadius @${userRadius}m | center @(${startPos.latitude}, ${startPos.longitude}) | points found: ${points.length}')
              ],
            );
          }
        )
      ),
    );
  }
}