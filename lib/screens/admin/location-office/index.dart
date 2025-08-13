import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart'; 
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:provider/provider.dart';
import '../../../providers/office_config_provider.dart';

const kGoogleApiKey = "AIzaSyCz2lLwBT3d-8TpoTl8Um32PSZitcoxNhc"; 
final places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

class OfficeConfigScreen extends StatefulWidget {
  const OfficeConfigScreen({super.key});

  @override
  State<OfficeConfigScreen> createState() => _OfficeConfigScreenState();
}

class _OfficeConfigScreenState extends State<OfficeConfigScreen> {
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();
  final _radiusCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final config = Provider.of<OfficeConfigProvider>(context, listen: false);
    _latCtrl.text = config.lat.toString();
    _lngCtrl.text = config.lng.toString();
    _radiusCtrl.text = config.radius.toString();
  }

  @override
  void dispose() {
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _radiusCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = Provider.of<OfficeConfigProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan Lokasi Kantor')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _latCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Latitude'),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _lngCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Longitude'),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _radiusCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Radius (meter)'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                final selected = await Navigator.push<LatLng>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MapPickerScreen(),
                  ),
                );
                if (selected != null) {
                  _latCtrl.text = selected.latitude.toString();
                  _lngCtrl.text = selected.longitude.toString();
                }
              },
              child: const Text('Pilih di Peta'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final lat = double.tryParse(_latCtrl.text) ?? config.lat;
                final lng = double.tryParse(_lngCtrl.text) ?? config.lng;
                final radius = double.tryParse(_radiusCtrl.text) ?? config.radius;
                await config.updateConfig(lat, lng, radius);
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Simpan'),
            )
          ],
        ),
      ),
    );
  }
}


class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  GoogleMapController? _controller;
  LatLng _pickedLocation = const LatLng(-6.200000, 106.816666);
  String _currentAddress = "Mengambil lokasi...";

  Future<void> _goToCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      
      if (!mounted) return;
      setState(() {
        _pickedLocation = LatLng(position.latitude, position.longitude);
      });

      
      _controller?.animateCamera(
        CameraUpdate.newLatLng(_pickedLocation),
      );

      
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;
      setState(() {
        _currentAddress = placemarks.isNotEmpty ? "${placemarks.first.street}, ${placemarks.first.locality}" : "${position.latitude}, ${position.longitude}";
      });
    } catch (e) {
      print("❌ Gagal mengambil lokasi: $e");
    } finally {
      Navigator.pop(context); 
    }
  }

  Future<void> _searchPlace() async {
    Prediction? p = await PlacesAutocomplete.show(
      context: context,
      apiKey: kGoogleApiKey,
      mode: Mode.overlay,
      language: "id",
      components: [
        Component(Component.country, "id")
      ],
    );

    if (p != null) {
      final detail = await places.getDetailsByPlaceId(p.placeId!);
      final lat = detail.result.geometry!.location.lat;
      final lng = detail.result.geometry!.location.lng;

      if (!mounted) return;
      setState(() {
        _pickedLocation = LatLng(lat, lng);
      });

      _controller?.animateCamera(
        CameraUpdate.newLatLng(_pickedLocation),
      );

      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (!mounted) return;
      setState(() {
        _currentAddress = placemarks.isNotEmpty ? "${placemarks.first.street}, ${placemarks.first.locality}" : "$lat, $lng";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Lokasi di Peta'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _searchPlace,
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _pickedLocation,
              zoom: 15,
            ),
            onMapCreated: (controller) => _controller = controller,
            onTap: (latLng) {
              setState(() {
                _pickedLocation = latLng;
              });
            },
            markers: {
              Marker(
                markerId: const MarkerId('picked'),
                position: _pickedLocation,
              ),
            },
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.white.withOpacity(0.9),
              child: Text(
                'Lokasi saat ini: $_currentAddress',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'current_location',
            mini: true,
            child: const Icon(Icons.my_location),
            onPressed: _goToCurrentLocation,
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'confirm',
            child: const Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context, _pickedLocation);
            },
          ),
        ],
      ),
    );
  }
}
