import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../../core/services/vision_service.dart';
import '../../../core/services/search_service.dart';
import '../../../core/services/market_service.dart';
import '../../vault/data/vault_provider.dart'; 
import '../../vault/domain/sneaker_model.dart';
import '../../vault/presentation/sneaker_detail_screen.dart';
import '../../market/presentation/market_screen.dart';
import '../../map/presentation/map_screen.dart';
import '../../news/presentation/news_screen.dart';
import '../../../../features/profile/presentation/profile_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/ui_components.dart'; 

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sneakerListAsync = ref.watch(sneakerListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.8),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.person_outline, color: Colors.white, size: 28),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
        ),
        title: Text("SNEAKER VAULT", style: GoogleFonts.sedgwickAve(color: AppColors.highlight, fontSize: 26)),
        actions: [
          IconButton(
            icon: const Icon(Icons.newspaper, color: Colors.white, size: 28),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewsScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.public, color: Colors.white, size: 28),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MapScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart, color: AppColors.accent, size: 28),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MarketScreen())),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(child: Image.network("https://images.unsplash.com/photo-1550684848-fac1c5b4e853?q=80&w=1000&auto=format&fit=crop", fit: BoxFit.cover)),
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.85))),
          sneakerListAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
            error: (err, stack) => Center(child: Text("Error", style: TextStyle(color: Colors.red))),
            data: (sneakers) => sneakers.isEmpty ? _buildEmptyState() : _buildGrid(sneakers),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: ModernButton(text: "DROP KICK", icon: Icons.camera_alt, onPressed: () => _onAdd(context, ref)),
      ),
    );
  }

  Widget _buildEmptyState() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.album, size: 80, color: Colors.white10), Text("EMPTY", style: GoogleFonts.bebasNeue(fontSize: 30, color: Colors.white30))]));
  
  Widget _buildGrid(List<Sneaker> sneakers) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.65, crossAxisSpacing: 16, mainAxisSpacing: 16),
      itemCount: sneakers.length,
      itemBuilder: (ctx, i) => UrbanCard(
        image: Hero(tag: 's_${sneakers[i].id}', child: Image.file(File(sneakers[i].imagePath), fit: BoxFit.contain)),
        brand: sneakers[i].brand, model: sneakers[i].model, price: "\$${sneakers[i].price.toInt()}",
        onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => SneakerDetailScreen(sneaker: sneakers[i]))),
      ),
    );
  }

  Future<void> _onAdd(BuildContext context, WidgetRef ref) async {
    final photo = await ImagePicker().pickImage(source: ImageSource.camera);
    if (photo == null) return;
    if (context.mounted) showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.accent)));
    final analysis = await VisionService().analyzeImage(File(photo.path));
    if (context.mounted) {
      Navigator.pop(context);
      _showDialog(context, ref, File(photo.path), analysis['brand'], analysis['model']);
    }
  }

  Future<void> _showDialog(BuildContext context, WidgetRef ref, File img, String? brand, String? model) async {
    final bCtrl = TextEditingController(text: brand);
    final mCtrl = TextEditingController(text: model);
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text("CHECK KICKS", style: GoogleFonts.sedgwickAve(color: AppColors.highlight, fontSize: 24)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Image.file(img, height: 100, fit: BoxFit.cover),
          TextField(controller: bCtrl, style: TextStyle(color: Colors.white), decoration: InputDecoration(labelText: "Brand")),
          TextField(controller: mCtrl, style: TextStyle(color: Colors.white), decoration: InputDecoration(labelText: "Model")),
        ]),
        actions: [
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent), onPressed: () async {
            if (bCtrl.text.isEmpty) return;
            Navigator.pop(ctx);
            // Sauvegarde simplifiée (Garde photo caméra si pas de clé Google)
            final dir = await getApplicationDocumentsDirectory();
            final savedImg = await img.copy('${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
            final price = await MarketService().getEstimatedPrice("${bCtrl.text} ${mCtrl.text}");
            ref.read(sneakerListProvider.notifier).addSneaker(Sneaker(brand: bCtrl.text, model: mCtrl.text, colorway: "Unknown", imagePath: savedImg.path, price: price, year: 2024, dateAdded: DateTime.now()));
          }, child: Text("ADD"))
        ],
      ),
    );
  }
}