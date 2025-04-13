import 'package:flutter/material.dart';

class BusMarker extends StatelessWidget {
  const BusMarker({Key? key, required this.routeNo}) : super(key: key);

  final String routeNo;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child:  Row(
        mainAxisSize: MainAxisSize.min, // Ensure row only takes necessary space
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_bus,
            color: Colors.white,
            size: 15,
          ),
          SizedBox(width: 4),
          Text(
            routeNo,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}