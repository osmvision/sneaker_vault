import 'package:latlong2/latlong.dart';

class Shop {
  final String name;
  final String type; // "Resell", "Retail", "Vintage"
  final String address;
  final LatLng location;
  final bool isOpen;

  Shop({
    required this.name,
    required this.type,
    required this.address,
    required this.location,
    this.isOpen = true,
  });
}