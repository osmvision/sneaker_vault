import 'package:flutter/material.dart';

class CRTEffect extends StatelessWidget {
  final Widget child;
  const CRTEffect({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        IgnorePointer(
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.1), Colors.transparent],
                stops: const [0.0, 0.5, 1.0],
                tileMode: TileMode.repeated,
              ).createShader(bounds);
            },
            blendMode: BlendMode.darken,
            child: Container(color: Colors.transparent),
          ),
        ),
      ],
    );
  }
}