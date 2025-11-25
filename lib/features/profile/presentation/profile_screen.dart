import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// On garde uniquement les liens vers les données
import '../../vault/data/vault_provider.dart';
import '../../market/data/market_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sneakersAsync = ref.watch(sneakerListProvider);
    final totalValue = ref.watch(totalValueProvider);

    // COULEURS EN DUR (Pour éviter les bugs d'import)
    const bgColor = Color(0xFF050505);
    const cardColor = Color(0xFF1A1A1A);
    const accentColor = Color(0xFFD000FF); // Violet
    const highlightColor = Color(0xFF00FFE0); // Cyan

    return Scaffold(
      backgroundColor: bgColor,
      
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          "MY REP", 
          style: GoogleFonts.sedgwickAve(color: highlightColor, fontSize: 28)
        ),
      ),
      
      body: Stack(
        children: [
          // 1. FOND SIMPLE
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.5),
                  radius: 1.3,
                  colors: [Color(0xFF252525), Colors.black],
                ),
              ),
            ),
          ),

          // 2. CONTENU
          sneakersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: accentColor)),
            
            error: (err, stack) => Center(
              child: Text("Erreur: $err", style: const TextStyle(color: Colors.red))
            ),
            
            data: (sneakers) {
              final count = sneakers.length;
              final rank = _getRank(count);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // --- CARTE PROFIL ---
                    Container(
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white10),
                        boxShadow: [
                          BoxShadow(color: accentColor.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icône Rang
                          Icon(_getRankIcon(count), size: 100, color: _getRankColor(count)),
                          const SizedBox(height: 20),
                          // Texte Rang
                          Text(
                            "MEMBER STATUS",
                            style: GoogleFonts.roboto(color: Colors.grey, letterSpacing: 2, fontSize: 12),
                          ),
                          Text(
                            rank,
                            style: GoogleFonts.bebasNeue(fontSize: 50, color: Colors.white),
                          ),
                          // Niveau
                          Container(
                            // --- C'EST ICI QUE C'ÉTAIT CORRIGÉ ---
                            margin: const EdgeInsets.only(top: 10), 
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: highlightColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "LEVEL $count",
                              style: GoogleFonts.roboto(color: Colors.black, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // --- STATISTIQUES ---
                    Row(
                      children: [
                        Expanded(
                          child: _buildLocalStatBox("PAIRS", "$count", cardColor, accentColor),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildLocalStatBox("VALUE", "\$${totalValue.toInt()}", cardColor, highlightColor),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Widget local
  Widget _buildLocalStatBox(String label, String value, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Text(
            label, 
            style: GoogleFonts.roboto(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: 8),
          Text(
            value, 
            style: GoogleFonts.bebasNeue(color: textColor, fontSize: 32)
          ),
        ],
      ),
    );
  }

  // Logique locale
  String _getRank(int count) {
    if (count == 0) return "NOOB";
    if (count < 3) return "ROOKIE";
    if (count < 10) return "HYPEBEAST";
    return "LEGEND";
  }

  Color _getRankColor(int count) {
    if (count == 0) return Colors.grey;
    if (count < 3) return Colors.white;
    if (count < 10) return const Color(0xFF00FFE0); 
    return const Color(0xFFFFD700); 
  }

  IconData _getRankIcon(int count) {
    if (count == 0) return Icons.person_outline;
    if (count < 3) return Icons.star_border;
    if (count < 10) return Icons.flash_on;
    return Icons.emoji_events;
  }
}