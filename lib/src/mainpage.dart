import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'colorscheme.dart';
import 'padding.dart';
import 'buttons.dart';
import 'package:url_launcher/url_launcher.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

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
        child: FlutterMap(
          mapController: MapController(),
          options: MapOptions(
            initialCenter: LatLng(52.819210, 1.368957),
            initialZoom: 13
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.jaddison.middleofnowhere',
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
      ),
    );
  }
}