import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class Skeleton extends StatelessWidget {
  Skeleton({super.key, this.width, this.height});

  double? width, height;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      interval: Duration(seconds: 1),
      duration: Duration(seconds: 2),
      child: Container(
        padding: EdgeInsets.all(0.8),
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
