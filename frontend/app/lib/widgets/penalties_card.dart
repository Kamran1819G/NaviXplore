import 'package:flutter/material.dart';

class PenaltieCard extends StatelessWidget {
  final String title;
  final String section;
  final String penalty;
  final String? description;

  PenaltieCard({
    super.key,
    required this.title,
    required this.section,
    required this.penalty,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.black, // Border color
          width: 1.0, // Border width
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          Text("Sec. $section"),
          Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  margin: EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text("Penalty", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                ),
                Expanded(child: Text(penalty, maxLines: 10)),
              ],
            ),
          ),
          if(description != null) Text(description!)
        ],
      ),
    );
  }
}
