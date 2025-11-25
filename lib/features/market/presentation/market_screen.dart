import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../data/market_provider.dart';

class MarketScreen extends ConsumerWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brandStats = ref.watch(marketStatsProvider);
    final totalValue = ref.watch(totalValueProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "MARKET STATS", 
          style: GoogleFonts.bebasNeue(color: AppColors.highlight, fontSize: 28, letterSpacing: 2)
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. CARTE VALEUR TOTALE (Style Digital) ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.accent.withOpacity(0.5), width: 2), // Bordure Violette
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "TOTAL STASH VALUE", 
                    style: GoogleFonts.roboto(color: Colors.grey, letterSpacing: 1.5, fontSize: 12, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 10),
                  // Effet de texte "Glow"
                  Text(
                    "\$${totalValue.toStringAsFixed(0)}", 
                    style: GoogleFonts.bebasNeue(
                      fontSize: 64, 
                      color: Colors.white,
                      shadows: [
                        Shadow(color: AppColors.accent, blurRadius: 15),
                      ]
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
            
            Text(
              "BRAND DOMINANCE", 
              style: GoogleFonts.sedgwickAve(color: Colors.white, fontSize: 20),
            ),
            
            const SizedBox(height: 20),

            // --- 2. GRAPHIQUE EQUALIZER ---
            Expanded(
              child: brandStats.isEmpty 
                ? Center(
                    child: Text(
                      "NO DATA YET", 
                      style: GoogleFonts.bebasNeue(color: Colors.grey[700], fontSize: 30)
                    )
                  )
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: (brandStats.values.fold(0, (p, c) => p > c ? p : c) + 2).toDouble(),
                      
                      // Fond de la grille
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 1,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.white.withOpacity(0.05),
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      
                      // Titres des axes
                      titlesData: FlTitlesData(
                        show: true,
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              if (value.toInt() >= brandStats.keys.length) return const SizedBox();
                              final label = brandStats.keys.elementAt(value.toInt());
                              return Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Text(
                                  label.length > 3 ? label.substring(0, 3) : label,
                                  style: GoogleFonts.bebasNeue(color: AppColors.highlight, fontSize: 14),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      
                      // Barres Néons
                      barGroups: brandStats.entries.toList().asMap().entries.map((entry) {
                        final index = entry.key;
                        final count = entry.value.value;
                        
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: count.toDouble(),
                              // Dégradé Violet -> Cyan
                              gradient: const LinearGradient(
                                colors: [AppColors.accent, AppColors.highlight],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                              width: 24,
                              borderRadius: BorderRadius.circular(4),
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: (brandStats.values.fold(0, (p, c) => p > c ? p : c) + 2).toDouble(),
                                color: Colors.white.withOpacity(0.05), // Fond de la barre
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}