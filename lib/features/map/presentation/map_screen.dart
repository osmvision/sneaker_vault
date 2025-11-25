import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

// Imports
import '../../../core/theme/app_colors.dart';
import '../../../core/services/shop_service.dart'; // Service
import '../../map/domain/shop_model.dart'; // Modèle

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final ShopService _shopService = ShopService();
  
  LatLng _currentPosition = const LatLng(48.8566, 2.3522); // Paris par défaut
  List<Shop> _shops = [];
  bool _isLoading = true;
  
  // Shop sélectionné pour la popup
  Shop? _selectedShop; 

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition();
    
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      // Une fois la position trouvée, on génère les shops autour
      _shops = _shopService.getShopsAround(_currentPosition);
      _isLoading = false;
    });

    _mapController.move(_currentPosition, 15.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. LA CARTE
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition, 
              initialZoom: 14.0,
              // Ferme la popup si on clique ailleurs sur la carte
              onTap: (_, __) => setState(() => _selectedShop = null), 
            ),
            children: [
              // Fond Dark Matter
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
              ),
              
              // Marqueurs
              MarkerLayer(
                markers: [
                  // MA POSITION (Radar Bleu)
                  if (!_isLoading)
                    Marker(
                      point: _currentPosition,
                      width: 60,
                      height: 60,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const Icon(Icons.my_location, color: Colors.blueAccent, size: 24),
                        ],
                      ),
                    ),
                    
                  // LES SHOPS (Marqueurs Violets)
                  ..._shops.map((shop) => Marker(
                    point: shop.location,
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedShop = shop); // Affiche la popup
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.accent, width: 2)
                        ),
                        child: const Icon(Icons.storefront, color: Colors.white, size: 20),
                      ),
                    ),
                  )),
                ],
              ),
            ],
          ),

          // 2. HEADER FLOTTANT
          Positioned(
            top: 50, left: 20, right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCircleBtn(Icons.arrow_back, () => Navigator.pop(context)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.highlight, width: 1)
                  ),
                  child: Text("STREET MAP", style: GoogleFonts.sedgwickAve(color: AppColors.highlight, fontSize: 20)),
                ),
                _buildCircleBtn(Icons.refresh, _determinePosition),
              ],
            ),
          ),

          // 3. POPUP SHOP (Affichée seulement si un shop est cliqué)
          if (_selectedShop != null)
            Positioned(
              bottom: 40, left: 20, right: 20,
              child: _buildShopCard(_selectedShop!),
            ),
        ],
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildCircleBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black, 
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24)
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildShopCard(Shop shop) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 10))]
      ),
      child: Row(
        children: [
          // Image Shop
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white10)
            ),
            child: const Icon(Icons.shopping_bag, color: Colors.white),
          ),
          const SizedBox(width: 16),
          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(shop.name, style: GoogleFonts.bebasNeue(color: Colors.white, fontSize: 24)),
                Text(shop.type.toUpperCase(), style: GoogleFonts.roboto(color: AppColors.highlight, fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(shop.address, style: GoogleFonts.roboto(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: shop.isOpen ? Colors.green : Colors.red),
                    const SizedBox(width: 4),
                    Text(shop.isOpen ? "OPEN NOW" : "CLOSED", style: const TextStyle(color: Colors.white, fontSize: 10)),
                  ],
                )
              ],
            ),
          ),
          // Bouton Go
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(12)
            ),
            child: const Icon(Icons.directions, color: Colors.white),
          )
        ],
      ),
    );
  }
}