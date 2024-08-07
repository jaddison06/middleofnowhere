import 'overpass.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math';

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
  final void Function(double) onProgressUpdate;
  final void Function(String) onLoadingMessageUpdate;
  MONEngine({required this.onProgressUpdate, required this.onLoadingMessageUpdate});

  final _overpassDownloadBullshitPercentage = 0.2;

  var _areaCovered = 0.0;
  var _userRadius = 5000.0;
  var _nothingRadius = 235.0;

  void _updateProgressByArea(double area) {
    _areaCovered += area;
    onProgressUpdate(
      _overpassDownloadBullshitPercentage + (
        (_areaCovered / pow(_userRadius * 2, 2)) * (1 - _overpassDownloadBullshitPercentage)
      )
    );
  }

  // Find all boxes that contain NO points within nothingRadius of infrastructure
  List<BBox> _getCandidatesInBox({required _BBWithInfra area}) {
    // Check if any infrastructure inside this box or within nothingRadius of edges
    for (var node in area.points) {
      if (node.containedBy(area.box.expandSidesByMetres(_nothingRadius))) {
        if (area.box.hypotenuseMetres <= _nothingRadius) {
          // Max distance across box is smaller than minimum distance from infrastructure therefore no valid points in the box
          // Technically slightly invalid bcos infra within nothingRadius of a corner could be far enough away from opposite
          // corner but that makes the base case really complicated for very little added usefulness
          _updateProgressByArea(area.box.areaMetres);
          return [];
        }

        // Infrastructure in box (or within nothingRadius of corners) but division still useful - recurse!!
        return area.split(divisions: 2, nothingRadius: _nothingRadius)
          .map((area) => _getCandidatesInBox(area: area))
          .reduce((a, b) => a + b);
      }
    }
    // No infrastructure in box or within nothingRadius - we're good here!!
    _updateProgressByArea(area.box.areaMetres);
    return [area.box];
  }

  // For this to work correctly you gotta expand the OG box by nothingRadius and pass in surrounding infrastructure also
  Future<List<BBox>> getCandidateAreas({required List<LatLng> infrastructure, required LatLng startPos}) async
    => _getCandidatesInBox(area: _BBWithInfra(
      box: BBox.fromCenterWithDimensionsMetres(center: startPos, height: _userRadius * 2, width: _userRadius * 2),
      points: infrastructure
    ));
  
  Future<List<LatLng>> _getInfrastructure(LatLng userPos) => Overpass().getAllInfrastructure(
      BBox.fromCenterWithDimensionsMetres(center: userPos, width: _userRadius * 2, height: _userRadius * 2).expandSidesByMetres(_nothingRadius)
    );

  Future<void> _updateLoadingMessage(String msg) {
    onLoadingMessageUpdate(msg);
    return Future.delayed(Duration(milliseconds: 450));
  }
  
  Future<List<LatLng>> getPoints(LatLng userPos) async {
    onProgressUpdate(0);
    await _updateLoadingMessage('Loading map data');

    _areaCovered = 0;
    var infrastructure = await _getInfrastructure(userPos);

    onProgressUpdate(_overpassDownloadBullshitPercentage);
    await _updateLoadingMessage('Finding some spots');

    var candidates = await getCandidateAreas(infrastructure: infrastructure, startPos: userPos);
    while (candidates.length < 5) {
      onProgressUpdate(0);
      await _updateLoadingMessage('Struggling to find somewhere - casting the net wider');

      _areaCovered = 0;
      _userRadius *= 1.5;
      _nothingRadius = max(_nothingRadius - 7, 210);

      infrastructure = await _getInfrastructure(userPos);

      onProgressUpdate(_overpassDownloadBullshitPercentage);
      await _updateLoadingMessage('Looking for some more spots');

      candidates = await getCandidateAreas(infrastructure: infrastructure, startPos: userPos);
    }

    await _updateLoadingMessage('Handpicking the best spots near you');

    candidates.shuffle();
    final points = <LatLng>[];
    for (var i = 0; i < min(10, candidates.length); i++) {
      points.add(candidates[i].randomPoint());
    }

    return points;
  }
}