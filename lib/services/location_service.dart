import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

List<String> getLongLat(String loc){
  List<String> coordinateSet = loc.split(" ");
  coordinateSet[1] = coordinateSet[1].substring(0, coordinateSet[1].length - 1);

  if(coordinateSet.length > 2 )
    return [coordinateSet[1],coordinateSet[3]];
  else
    return ['0','0']; //TODO: ITS NOT RENDERING ALL OF THE USERS, SOMETIMES THE COORDINATE SET ISN'T PARSING PERFECT STRINGS, CAUSING ERRORS, NOW WE'RE JUST DELETING THOSE USERS FROM MAP... FIGURE IT OUT BITCH
}

GeoPoint createGeoPoint(String _location) {
  List<String>  cSet = getLongLat(_location);
  GeoPoint position = GeoPoint(double.parse(cSet[0]),double.parse(cSet[1]));
  return position;
}

Future<String> getLocationString() async {
  Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
  return position.toString();
}
