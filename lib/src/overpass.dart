import 'package:http/http.dart';
import 'dart:math';
import 'package:xml/xml.dart';
import 'package:latlong2/latlong.dart';

class BBox {
  final LatLng start, end;
  BBox(this.start, this.end);

  // this is actually some of the cleanest code i've ever written i love dart yippeeeeeeeee
  BBox.fromStartWithDimensionsMetres({required this.start, required double height, required double width})
     : end = start.offsetBy(height, width);
  BBox.fromStartWithDimensionsDeg({required this.start, required double height, required double width})
     : end = LatLng(start.latitude + height, start.longitude + width);
  factory BBox.fromCenterWithDimensionsMetres({required LatLng center, required double height, required double width})
    => BBox.fromStartWithDimensionsMetres(start: center.offsetBy(height * -0.5, width * -0.5), height: height, width: width);
  factory BBox.fromCenterWithDimensionsDeg({required LatLng center, required double height, required double width}) 
    => BBox.fromStartWithDimensionsDeg(start: LatLng(center.latitude + height * -0.5, center.longitude + width * -0.5), height: height, width: width);
  
  double get minLat => min(start.latitude, end.latitude);
  double get maxLat => max(start.latitude, end.latitude);
  double get minLng => min(start.longitude, end.longitude);
  double get maxLng => max(start.longitude, end.longitude);

  // Overpass takes lowest lat, lowest long, highest lat, highest long
  String toOverpassString() => '($minLat, $minLng, $maxLat, $maxLng)';

  List<BBox> split({required int divisions}) {
    final out = <BBox>[];
    final childHeight = (maxLat - minLat) / divisions;
    final childWidth = (maxLng - minLng) / divisions;
    for (int dLat = 0; dLat < divisions; dLat++) {
      for (int dLng = 0; dLng < divisions; dLng++) {
        out.add(BBox(
          LatLng(
            minLat + childHeight * dLat,
            minLng + childWidth * dLng
          ),
          LatLng(
            minLat + childHeight * (dLat + 1),
            minLng + childWidth * (dLng + 1)
          )
        ));
      }
    }
    return out;
  }
}

extension DistanceCalculations on LatLng {
  static const earthRadius = 6371000; // in metres
  // Adapted from https://github.com/Ujjwalsharma2210/flutter_map_math/blob/d07096bf9e0a153d9c4d4a0e55799bff69f769fb/lib/flutter_geo_math.dart#L29
  double distanceTo(LatLng other) {
    // assuming earth is a perfect sphere (it's not)
    final dLat = other.latitudeInRad - latitudeInRad;
    final dLon = other.longitudeInRad - longitudeInRad;

    // Haversine formula
    final a = pow(sin(dLat / 2), 2) +
        cos(latitudeInRad) * cos(other.latitudeInRad) * pow(sin(dLon / 2), 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    final distance = earthRadius * c;

    return distance; // in metres
  }

  // todo: i have no fucking idea if this works
  // Adapted from https://stackoverflow.com/a/7478827
  LatLng offsetBy(double latMetres, double longMetres) {
    return LatLng(
      latitude + (latMetres / earthRadius) * (180 / pi),
      longitude + (longMetres / earthRadius) * (180 / pi) / cos(latitude * pi/180)
    );
  }

  // todo: IS THIS HOW COORDINATES WORK???????????
  bool containedBy(BBox box) {
    return (
      latitude >= box.minLat &&
      latitude <= box.maxLat &&
      longitude >= box.minLng &&
      longitude <= box.maxLng
    );
  }
}

class Overpass {
  Future<XmlDocument> _overpassRequest(String query) async {
    final response = await get(Uri.parse('https://overpass-api.de/api/interpreter?data=$query'));
    if (response.statusCode != 200) throw 'Unexpected Overpass response code ${response.statusCode}\n${response.body}';
    if (response.headers['content-type'] != 'application/osm3s+xml') throw 'Unexpected Overpass content type ${response.headers['content-type']}\n${response.body}';
    // todo: check doc type
    return XmlDocument.parse(response.body);
  }

  List<LatLng> _getNodes(XmlDocument document) {
    final out = <LatLng>[];
    for (var element in document.getElement('osm')!.childElements) {
      if (element.name.local == 'node') {
        out.add(LatLng(
          double.tryParse(element.getAttribute('lat')!)!,
          double.tryParse(element.getAttribute('lon')!)!
        ));
      }
    }
    return out;
  }

  Future<List<LatLng>> getAllBuildings(BBox box) async {
    final document = await _overpassRequest('way["building"]${box.toOverpassString()};>;out;');
    return _getNodes(document);
  }

  Future<List<LatLng>> getAllRoads(BBox box) async {
    // Anything we *don't* want to be close to - https://taginfo.openstreetmap.org/keys/highway#values
    final roadTypes = ['road', 'motorway', 'primary', 'secondary', 'tertiary'];
    final document = await _overpassRequest('way["highway"~"${roadTypes.join('|')}"]${box.toOverpassString()};>;out;');
    return _getNodes(document);
  }
}