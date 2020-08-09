import 'package:location/location.dart';

class Permission {
  Location location = new Location();
  PermissionStatus _permissionGranted;

  void checkPermission() async {
    print("checkpermission");
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
    }
  }
}