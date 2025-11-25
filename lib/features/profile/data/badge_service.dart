import 'package:flutter/material.dart';
import '../../vault/domain/sneaker_model.dart';

// On utilise "Achievement" pour ne pas confondre avec le widget Badge de Flutter
class Achievement {
  final String name;
  final String description;
  final String lottieAsset;
  final IconData fallbackIcon; // Icône de secours
  final bool isUnlocked;
  final Color color;

  Achievement({
    required this.name,
    required this.description,
    required this.lottieAsset,
    required this.fallbackIcon,
    required this.isUnlocked,
    required this.color,
  });
}

class BadgeService {
  static List<Achievement> calculateBadges(List<Sneaker> sneakers) {
    final int count = sneakers.length;
    
    final int jordanCount = sneakers.where((s) => 
      s.brand.toLowerCase().contains('jordan') || 
      s.model.toLowerCase().contains('jordan')
    ).length;

    final int vintageCount = sneakers.where((s) => s.year < 2000).length;

    return [
      Achievement(
        name: "ROOKIE",
        description: "First pair collected",
        lottieAsset: "assets/animations/sneaker.json",
        fallbackIcon: Icons.star, // Icône si pas de Lottie
        isUnlocked: count >= 1,
        color: const Color(0xFF00FFE0), 
      ),
      Achievement(
        name: "FRESH KID",
        description: "5 pairs in the vault",
        lottieAsset: "assets/animations/boombox.json",
        fallbackIcon: Icons.speaker,
        isUnlocked: count >= 5,
        color: const Color(0xFFD000FF), 
      ),
      Achievement(
        name: "JORDAN ADDICT",
        description: "3 Jordans owned",
        lottieAsset: "assets/animations/fire.json",
        fallbackIcon: Icons.local_fire_department,
        isUnlocked: jordanCount >= 3,
        color: const Color(0xFFFF0000), 
      ),
      Achievement(
        name: "LEGEND",
        description: "Collection Master",
        lottieAsset: "assets/animations/trophy.json",
        fallbackIcon: Icons.emoji_events,
        isUnlocked: count >= 10,
        color: const Color(0xFFFFD700), 
      ),
    ];
  }
}