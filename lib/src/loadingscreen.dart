import 'package:flutter/material.dart';
import 'colorscheme.dart';
import 'package:latlong2/latlong.dart';
import 'engine.dart';

class LoadingScreen extends StatefulWidget {
  final LatLng userPos;
  final void Function(List<LatLng>) onHaveGotPoints;
  const LoadingScreen({super.key, required this.userPos, required this.onHaveGotPoints});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  var message = '';
  var progress = 0.0;

  late final MONEngine engine;

  @override
  void initState() {
    super.initState();
    engine = MONEngine(
      // WHYYYYYY THE FUCKKKKK DOES THUS SHITTY CALLBACK ONLY REBUILD THE WIDGET WHEN IT FEELS LIKE IT
      onProgressUpdate: (newProgress) => setState(() => progress = newProgress),
      onLoadingMessageUpdate: (newMessage) => setState(() => message = newMessage)
    );
    engine.getPoints(widget.userPos).then((points) => widget.onHaveGotPoints(points));
  }

  @override
  Widget build(BuildContext context) {
    // print('BUILDING LOADINGSCREEN');
    return Scaffold(
      backgroundColor: context.cs.surface,
      body: Center(
        child: Container(
          width: 265,
          height: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('${(progress * 100).toInt()}%', style: TextStyle(color: context.cs.onSurface)),
              TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 450),
                curve: Curves.easeInOut,
                tween: Tween(
                  begin: 0,
                  end: progress
                ),
                builder: (_, value, __) => LinearProgressIndicator(value: value, color: context.cs.onSurface),
              ),
              Text(message, style: TextStyle(color: context.cs.onSurface), textAlign: TextAlign.center)
            ],
          ),
        ),
      )
    );
  }
}