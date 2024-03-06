import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import "package:flutter_google_maps_webservices/geocoding.dart" as geocoding;

const kGoogleApiKey = "";

class GoogleMapsPage extends StatefulWidget {
  @override
  _GoogleMapsPageState createState() => _GoogleMapsPageState();
}

class _GoogleMapsPageState extends State<GoogleMapsPage> {
  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    try {
      // Replace the dynamic location retrieval with a static location
      // For example, using coordinates for San Francisco, CA
      setState(() {
        _currentLocation = LatLng(37.7749, -122.4194);
      });
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  Future<void> _getNearbyTherapists() async {
    if (_currentLocation == null) {
      print("Location not available");
      return;
    }

    PlacesSearchResponse response = await _places.searchNearbyWithRadius(
      Location(
        lat: _currentLocation!.latitude!,
        lng: _currentLocation!.longitude!,
      ),
      5000, // Radius in meters (adjust as needed)
      type: "health",
      keyword: "mental health therapist",
    );

    if (response.isOkay) {
      // Process the results and display them in a table or any desired format
      List<TableRow> rows = [];

      for (var place in response.results.take(5)) {
        rows.add(
          TableRow(
            children: [
              TableCell(child: Text(place.name)),
              TableCell(child: Text(place.vicinity ?? 'N/A')),
              TableCell(child: Text(place.types.join(", "))),
              // Add more details as needed
            ],
          ),
        );
      }

      // Display the results in a table
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Nearby Therapists"),
            content: Table(
              border: TableBorder.all(),
              children: rows,
            ),
          );
        },
      );
    } else {
      // Handle error
      print("Error: ${response.errorMessage}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Therapist Locator'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _getNearbyTherapists();
          },
          child: Text('Find Nearby Therapists'),
        ),
      ),
    );
  }
}