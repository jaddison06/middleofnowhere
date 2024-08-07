import 'overpass.dart';
import 'package:latlong2/latlong.dart';

// Bounding box plus list of relevant infrastructure
// Useful for recursion otherwise every box would have to check every point
class _BBWithInfra {
  final BBox box;
  final List<LatLng> points;
  _BBWithInfra({required this.box, required this.points});

  List<_BBWithInfra> split({required int divisions, required double nothingRadius}) {
    // At point of recursion, child box needs a list all infrastructure inside it PLUS everything within nothingRadius of its edges
    final boxes = box.split(divisions: divisions);
    final pointses = List.filled(boxes.length, <LatLng>[]);
    for (var currentPoint in points) {
      for (var i = 0; i < boxes.length; i++) {
        final currentBox = boxes[i];
        // Is the current point in the danger zone?
        if (currentPoint.containedBy(currentBox.expandSidesByMetres(nothingRadius))) {
          pointses[i].add(currentPoint);
        }
      }
    }
    final out = <_BBWithInfra>[];
    for (var i = 0; i < boxes.length; i++) {
      out.add(_BBWithInfra(box: boxes[i], points: pointses[i]));
    }
    return out;
  }
}

class MONEngine {
  final double nothingRadius, userRadius;
  MONEngine({required this.nothingRadius, required this.userRadius});

  // Find all boxes that contain NO points within nothingRadius of infrastructure
  List<BBox> _getCandidatesInBox({required _BBWithInfra area}) {
    // Check if any infrastructure inside this box or within nothingRadius of edges
    for (var node in area.points) {
      if (node.containedBy(area.box.expandSidesByMetres(nothingRadius))) {
        if (area.box.hypotenuseMetres <= nothingRadius) {
          // Max distance across box is smaller than minimum distance from infrastructure therefore no valid points in the box
          // Technically slightly invalid bcos infra within nothingRadius of a corner could be far enough away from opposite
          // corner but that makes the base case really complicated for very little added usefulness
          return [];
        }

        // Infrastructure in box (or within nothingRadius of corners) but division still useful - recurse!!
        return area.split(divisions: 2, nothingRadius: nothingRadius)
          .map((area) => _getCandidatesInBox(area: area))
          .reduce((a, b) => a + b);
      }
    }
    // No infrastructure in box or within nothingRadius - we're good here!!s
    return [area.box];
  }

  // For this to work correctly you gotta expand the OG box by nothingRadius and pass in surrounding infrastructure also
  Future<List<BBox>> getCandidateAreas({required List<LatLng> infrastructure, required LatLng startPos}) async
    => _getCandidatesInBox(area: _BBWithInfra(
      box: BBox.fromCenterWithDimensionsMetres(center: startPos, height: userRadius * 2, width: userRadius * 2),
      points: infrastructure
    ));
}