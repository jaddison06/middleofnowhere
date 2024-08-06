import 'package:http/http.dart';
import 'dart:math';
import 'package:xml/xml.dart';

class LatLon {
  double lat, lon;
  LatLon(this.lat, this.lon);
  @override
  String toString() => '($lat, $lon)';

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  // Adapted from https://github.com/Ujjwalsharma2210/flutter_map_math/blob/d07096bf9e0a153d9c4d4a0e55799bff69f769fb/lib/flutter_geo_math.dart#L29
  double distanceTo(LatLon other) {
    const earthRadius = 6371000; // in metres
    // assuming earth is a perfect sphere (it's not)

    // Convert degrees to radians
    final lat1Rad = _degreesToRadians(lat);
    final lon1Rad = _degreesToRadians(lon);
    final lat2Rad = _degreesToRadians(other.lat);
    final lon2Rad = _degreesToRadians(other.lon);

    final dLat = lat2Rad - lat1Rad;
    final dLon = lon2Rad - lon1Rad;

    // Haversine formula
    final a = pow(sin(dLat / 2), 2) +
        cos(lat1Rad) * cos(lat2Rad) * pow(sin(dLon / 2), 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    final distance = earthRadius * c;

    return distance; // in metres
  }
}

class Overpass {
  Future<XmlDocument> _overpassRequest(String query) async {
    final response = await get(Uri.parse('https://overpass-api.de/api/interpreter?data=$query'));
    if (response.statusCode != 200) throw 'Unexpected Overpass response code ${response.statusCode}\n${response.body}';
    return XmlDocument.parse(response.body);
  }

  List<LatLon> _getNodes(XmlDocument document) {
    final out = <LatLon>[];
    for (var element in document.getElement('osm')!.childElements) {
      if (element.name.local == 'node') {
        out.add(LatLon(
          double.tryParse(element.getAttribute('lat')!)!,
          double.tryParse(element.getAttribute('lon')!)!
        ));
      }
    }
    return out;
  }

  // Overpass takes lowest lat, lowest long, highest lat, highest long
  String _overpassBBox(LatLon start, LatLon end) => '(${min(start.lat, end.lat)},${min(start.lon, end.lon)},${max(start.lat, end.lat)},${max(start.lon, end.lon)})';

  Future<List<LatLon>> getAllBuildings(LatLon start, LatLon end) async {
    final document = await _overpassRequest('way["building"]${_overpassBBox(start, end)};>;out;');
    return _getNodes(document);
  }

  Future<List<LatLon>> getAllRoads(LatLon start, LatLon end) async {
    // Anything we *don't* want to be close to - https://taginfo.openstreetmap.org/keys/highway#values
    final roadTypes = ['road', 'motorway', 'primary', 'secondary', 'tertiary'];
    final document = await _overpassRequest('way["highway"~"${roadTypes.join('|')}"]${_overpassBBox(start, end)};>;out;');
    return _getNodes(document);
  }
}