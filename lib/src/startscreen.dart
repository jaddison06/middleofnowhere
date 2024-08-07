import 'package:flutter/material.dart';
import 'buttons.dart';
import 'padding.dart';
import 'colorscheme.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocode/geocode.dart';

class StartScreen extends StatefulWidget {
  final void Function(LatLng) onHaveGotUserLocation;
  const StartScreen({super.key, required this.onHaveGotUserLocation});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  var showStartButton = true;
  var showAddressBox = false;

  late final TextEditingController addressInput;
  late final FocusNode addressFocus;

  @override
  void initState() {
    super.initState();
    addressInput = TextEditingController();
    addressFocus = FocusNode();
  }

  @override
  void dispose() {
    addressInput.dispose();
    addressFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cs.surface,
      body: Center(child: Container(
        width: 160,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              height: showStartButton ? 75 : 0,
              child: PrimaryButton(''
                'start',
                onPressed: () async {
                  setState(() => showStartButton = false);
                  final location = await Location().getLocation();
                  widget.onHaveGotUserLocation(LatLng(location.latitude!, location.longitude!));
                },
              ),
            ),
            VPadding(50),
            SecondaryButton(
              'enter address manually',
              onPressed: () => setState(() {
                showStartButton = false;
                showAddressBox = true;
                addressFocus.requestFocus();
              }),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              height: showAddressBox ? 200 : 0,
              child: Column(
                children: [
                  VPadding(25),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: context.cs.outline,
                        width: 2.5
                      ),
                      borderRadius: BorderRadius.circular(12)
                    ),
                    padding: EdgeInsets.all(5),
                    child: TextField(
                      controller: addressInput,
                      focusNode: addressFocus,
                      onSubmitted: (address) async {
                        final coords = await GeoCode().forwardGeocoding(address: address);
                        widget.onHaveGotUserLocation(LatLng(coords.latitude!, coords.longitude!));
                      }
                    )
                  )
                ],
              ),
            )
          ],
        ),
      )),
    );
  }
}