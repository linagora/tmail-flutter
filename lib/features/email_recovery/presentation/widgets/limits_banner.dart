import 'package:flutter/material.dart';

class LimitsBanner extends StatelessWidget {
  final String bannerContent;
  
  const LimitsBanner({
    super.key,
    required this.bannerContent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.yellow[400],
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
      ),
      child: Center(
        child: Text(
          bannerContent,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}