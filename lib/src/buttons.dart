import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'colorscheme.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final void Function()? onPressed;
  final double vPadding, hPadding, fontSize;
  const PrimaryButton(this.text, {super.key, this.onPressed, this.fontSize = 25, this.vPadding = 15, this.hPadding = 40});

  @override
  Widget build(BuildContext context) {
    return NeumorphicButton(
      padding: EdgeInsets.symmetric(vertical: vPadding, horizontal: hPadding),
      style: NeumorphicStyle(
        color: context.cs.primary,
        shadowLightColor: context.cs.onSurface,
      ),
      child: Center(
        child: Text(text, style: TextStyle(
          color: context.cs.onPrimary,
          fontSize: fontSize
        )),
      ),
      onPressed: onPressed,
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final void Function()? onPressed;
  final double vPadding, hPadding, fontSize;
  const SecondaryButton(this.text, {super.key, this.onPressed, this.fontSize = 12, this.vPadding = 8, this.hPadding = 12});

  @override
  Widget build(BuildContext context) {
    return NeumorphicButton(
      padding: EdgeInsets.symmetric(vertical: vPadding, horizontal: hPadding),
      style: NeumorphicStyle(
        color: context.cs.secondary,
        shadowLightColor: context.cs.onSurface,
      ),
      child: Center(
        child: Text(text, style: TextStyle(
          color: context.cs.onSecondary,
          fontSize: fontSize
        )),
      ),
      onPressed: onPressed,
    );
  }
}