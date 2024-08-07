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
  double nothingRadius = 200;
  double userRadius = 5000;
  final startPos = LatLng(52.819210, 1.368957);

  late Future<List<LatLng>> infrastructure;

  void loadInfrastructure() {
    // TODO yeah this is gonna be Engine code
    infrastructure = Overpass().getAllInfrastructure(
      BBox.fromCenterWithDimensionsMetres(center: startPos, width: userRadius * 2, height: userRadius * 2).expandSidesByMetres(nothingRadius)
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
            return Column(
              children: [
                Map(
                  points: MONEngine(nothingRadius: nothingRadius, userRadius: userRadius).getCandidateAreas(startPos: startPos, infrastructure: await infrastructure)
                    .map((e) => e.minCorner).toList(),
                  startPos: LatLng(52.819210, 1.368957)
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
                  min: 700,
                  max: 20000,
                  onChanged: (newVal) => setState(() {
                    userRadius = newVal;
                  })
                )
              ],
            );
          }
        )
      ),
    );
  }
}