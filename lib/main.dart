import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'src/colorscheme.dart';
import 'src/padding.dart';
import 'src/buttons.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'middle of nowhere',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 42, 25, 1), brightness: Brightness.dark),
        useMaterial3: true
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cs.surface,
      body: Center(child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrimaryButton(
            'start',
            onPressed: (){},
          ),
          VPadding(50),
          SecondaryButton(
            'enter address manually',
            onPressed: (){},
          )
        ],
      )),
    );
  }
}