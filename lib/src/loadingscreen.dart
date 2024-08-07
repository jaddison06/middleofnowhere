import 'package:flutter/material.dart';
import 'colorscheme.dart';

class LoadingScreen extends StatelessWidget {
  final double progress;
  final String message;
  const LoadingScreen({super.key, required this.progress, required this.message});

  @override
  Widget build(BuildContext context) {
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
              Text(message, style: TextStyle(color: context.cs.onSurface))
            ],
          ),
        ),
      )
    );
  }
}