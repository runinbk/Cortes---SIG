import 'package:flutter/material.dart';

class MapLoading extends StatelessWidget {
  const MapLoading({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
            child: Container(
                width: size.width * 0.6,
                height: size.height * 0.3,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/esperando.gif"),
                        fit: BoxFit.fill)))));
  }
}
