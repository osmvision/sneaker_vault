import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/news_service.dart';
import '../../news/domain/news_model.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final NewsService _newsService = NewsService();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "REALTIME DROPS", // Titre mis à jour
          style: GoogleFonts.sedgwickAve(color: AppColors.highlight, fontSize: 28)
        ),
      ),
      body: FutureBuilder<List<SneakerDrop>>(
        future: _newsService.getUpcomingDrops(),
        builder: (context, snapshot) {
          // 1. CHARGEMENT
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppColors.accent),
                  const SizedBox(height: 20),
                  Text("FETCHING LIVE DATA...", style: GoogleFonts.bebasNeue(color: Colors.white, fontSize: 20)),
                ],
              ),
            );
          }
          
          // 2. ERREUR OU VIDE
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, size: 60, color: Colors.grey),
                  const SizedBox(height: 10),
                  const Text("Impossible de charger les drops.", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => setState(() {}), // Bouton Réessayer
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                    child: const Text("RÉESSAYER"),
                  )
                ],
              ),
            );
          }

          final drops = snapshot.data!;

          // 3. LISTE DES VRAIS DROPS
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: drops.length,
            itemBuilder: (context, index) {
              return _buildDropCard(drops[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildDropCard(SneakerDrop drop) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: 140,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
        ]
      ),
      child: Row(
        children: [
          // IMAGE (Vraie photo web)
          Container(
            width: 130,
            decoration: const BoxDecoration(
              color: Colors.white, 
              borderRadius: BorderRadius.horizontal(left: Radius.circular(15)),
            ),
            padding: const EdgeInsets.all(10),
            child: Image.network(
              drop.image, 
              fit: BoxFit.contain,
              // Gestion d'erreur d'image
              errorBuilder: (c, o, s) => const Icon(Icons.image_not_supported, color: Colors.grey),
            ),
          ),

          // INFOS
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Date
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.accent),
                    ),
                    child: Text(
                      drop.releaseDate.toUpperCase(),
                      style: GoogleFonts.roboto(color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Nom du modèle
                  Text(
                    drop.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.bebasNeue(color: Colors.white, fontSize: 20, height: 1),
                  ),
                  
                  const Spacer(),
                  
                  // Prix
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        drop.price > 0 ? "\$${drop.price.toInt()}" : "TBA", // TBA si prix inconnu
                        style: GoogleFonts.roboto(color: Colors.grey, fontWeight: FontWeight.bold)
                      ),
                      if (drop.isHype) 
                        const Icon(Icons.local_fire_department, color: Colors.orange, size: 20)
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}