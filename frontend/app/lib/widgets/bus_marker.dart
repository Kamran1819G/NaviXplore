import 'package:flutter/material.dart';

class BusMarker extends StatelessWidget {
  const BusMarker({super.key, required this.routeNo});
  final String routeNo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.directions_bus,
            color: Colors.white,
            size: 30,
          ),
          const SizedBox(width: 8),
          Text(
            routeNo,
            style: const TextStyle(fontSize: 26, color: Colors.white,fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
