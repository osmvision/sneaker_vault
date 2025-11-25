import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class UrbanCard extends StatelessWidget {
  final Widget image;
  final String brand;
  final String model;
  final String price;
  final VoidCallback? onTap;

  const UrbanCard({super.key, required this.image, required this.brand, required this.model, required this.price, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(color: AppColors.imageBackground, borderRadius: BorderRadius.vertical(top: Radius.circular(11))),
                child: image, 
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(brand.toUpperCase(), style: GoogleFonts.roboto(fontSize: 10, color: AppColors.highlight, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(model.toUpperCase(), maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.bebasNeue(fontSize: 20, color: AppColors.textPrimary, height: 0.9)),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(price, style: GoogleFonts.roboto(fontSize: 14, color: AppColors.accent, fontWeight: FontWeight.w900)),
                        const Icon(Icons.arrow_forward, size: 14, color: Colors.white54),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ModernButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const ModernButton({super.key, required this.text, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60, width: 220,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent, foregroundColor: Colors.white, elevation: 10,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30), side: const BorderSide(color: Colors.white, width: 2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24), const SizedBox(width: 12),
            Text(text.toUpperCase(), style: GoogleFonts.bebasNeue(fontSize: 22, letterSpacing: 1.5)),
          ],
        ),
      ),
    );
  }
}