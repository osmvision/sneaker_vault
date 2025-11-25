import 'dart:math';
import 'package:latlong2/latlong.dart';
import '../../features/map/domain/shop_model.dart';

class ShopService {
  // Génère des shops fictifs autour d'une position donnée
  List<Shop> getShopsAround(LatLng center) {
    final random = Random();
    final List<Shop> shops = [];

    // Liste de noms stylés pour les shops
    final names = [
      "SNEAKER TEMPLE", "KICKS LAB", "OG VAULT", "HYPED STREET", 
      "SOLE KITCHEN", "VINTAGE PLUG", "DROP ZONE", "THE ARCHIVE"
    ];

    final types = ["Resell Store", "Official Retailer", "Vintage Shop", "Consignment"];

    // On crée 8 shops aléatoires
    for (var i = 0; i < 8; i++) {
      // Génération d'un décalage aléatoire (env. 1-2km)
      // 0.01 degré lat/long ~= 1.1km
      double latOffset = (random.nextDouble() - 0.5) * 0.02; 
      double lngOffset = (random.nextDouble() - 0.5) * 0.02;

      shops.add(Shop(
        name: names[i % names.length],
        type: types[random.nextInt(types.length)],
        address: "${random.nextInt(100) + 1} Street Ave, City",
        location: LatLng(center.latitude + latOffset, center.longitude + lngOffset),
        isOpen: random.nextBool(), // Parfois fermé
      ));
    }

    return shops;
  }
}