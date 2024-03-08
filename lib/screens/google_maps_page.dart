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
      setState(() {
        _currentLocation = LatLng(13.017844, 80.154037);
      });
      await _getNearbyTherapists();
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
      5000,
      type: "health",
      keyword: "mental health therapist",
    );

    if (response.isOkay) {
      List<Widget> therapistsList = [];

      for (var place in response.results.take(5)) {
        therapistsList.add(
          Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blueGrey),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text("Address: ${place.vicinity ?? 'N/A'}"),
                SizedBox(height: 5),
                Text("Phone: ${_getPhoneNumber(place)}"),
                SizedBox(height: 5),
                Text("Distance: ${_calculateDistance(place)} meters away"),
              ],
            ),
          ),
        );
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Nearby Therapists"),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: therapistsList,
              ),
            ),
          );
        },
      );
    } else {
      print("Error: ${response.errorMessage}");
    }
  }

  String _getPhoneNumber(PlacesSearchResult place) {
    return '9152987821'; //place.formattedPhoneNumber ?? 'N/A';
  }

  String _calculateDistance(PlacesSearchResult place) {
    double distance = place.geometry?.location?.lat ?? 0.0;
    return distance.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Therapist Locator'),
      ),
    );
  }
}