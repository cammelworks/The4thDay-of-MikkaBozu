import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapPanel extends StatelessWidget {
  Position _initialPosition;

  MapPanel(this._initialPosition);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Container(
      height: size.height/3,
      padding: EdgeInsets.fromLTRB(0, 0, 0, size.height / 20),
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: LatLng(_initialPosition.latitude, _initialPosition.longitude),
          zoom: 14.4746,
        ),
      ),
    );
  }
}
