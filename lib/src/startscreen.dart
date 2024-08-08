import 'package:flutter/material.dart';
import 'buttons.dart';
import 'padding.dart';
import 'colorscheme.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';
import 'package:dio/dio.dart';

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

                  // London test location
                  // widget.onHaveGotUserLocation(LatLng(51.52085134900359, -0.25858847091567677));

                  // Norfolk test location
                  // widget.onHaveGotUserLocation(LatLng(52.8191919256764, 1.3689539378712867));
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
                        // https://github.com/imvalient/geocode/blob/b5cf4898df587f135077fbd406bdf33f5b93901e/lib/src/service/geocode_client.dart#L52
                        final uri = Uri.https('geocode.xyz', '/${address.replaceAll(' ', '+')}', {'geoit': 'json'});
                        final res = await Dio().getUri(uri);
                        widget.onHaveGotUserLocation(LatLng(double.parse(res.data['latt']), double.parse(res.data['longt'])));
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