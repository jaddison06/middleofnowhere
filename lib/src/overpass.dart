import 'package:http/http.dart';
import 'dart:math';
import 'package:xml/xml.dart';
import 'package:latlong2/latlong.dart';

extension DistanceTo on LatLng {
  // Adapted from https://github.com/Ujjwalsharma2210/flutter_map_math/blob/d07096bf9e0a153d9c4d4a0e55799bff69f769fb/lib/flutter_geo_math.dart#L29
  double distanceTo(LatLng other) {
    const earthRadius = 6371000; // in metres
    // assuming earth is a perfect sphere (it's not)

    // Convert degrees to radians
    final lat1Rad = latitudeInRad;
    final lon1Rad = longitudeInRad;
    final lat2Rad = other.latitudeInRad;
    final lon2Rad = other.longitudeInRad;

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

  // Overpass takes lowest lat, lowest long, highest lat, highest long
  String _overpassBBox(LatLng start, LatLng end) => '(${min(start.latitude, end.latitude)},${min(start.longitude, end.longitude)},${max(start.latitude, end.latitude)},${max(start.longitude, end.longitude)})';

  Future<List<LatLng>> getAllBuildings(LatLng start, LatLng end) async {
    final document = await _overpassRequest('way["building"]${_overpassBBox(start, end)};>;out;');
    return _getNodes(document);
  }

  Future<List<LatLng>> getAllRoads(LatLng start, LatLng end) async {
    // Anything we *don't* want to be close to - https://taginfo.openstreetmap.org/keys/highway#values
    final roadTypes = ['road', 'motorway', 'primary', 'secondary', 'tertiary'];
    final document = await _overpassRequest('way["highway"~"${roadTypes.join('|')}"]${_overpassBBox(start, end)};>;out;');
    return _getNodes(document);
  }
}