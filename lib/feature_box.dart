import 'package:flutter/material.dart';

class FeatureBox extends StatelessWidget {
   final String headerText;
   final String descText;
   final Color color;
  const FeatureBox({super.key, required this.color, required this.headerText, required this.descText});


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: color
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(headerText,
          style: const TextStyle(
            fontFamily: 'Cera pro',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          ),
          const SizedBox(height: 3),
          Text(descText,
          style: const TextStyle(
            fontFamily: 'Cera pro',
          ),
          ),
        ],
      ),
    );
  }
}