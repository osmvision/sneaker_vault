import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Nécessaire pour la suppression
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../vault/domain/sneaker_model.dart';
import '../../vault/data/vault_provider.dart'; // Import du provider

// On passe en ConsumerStatefulWidget pour accéder à "ref"
class SneakerDetailScreen extends ConsumerStatefulWidget {
  final Sneaker sneaker;
  const SneakerDetailScreen({super.key, required this.sneaker});

  @override
  ConsumerState<SneakerDetailScreen> createState() => _SneakerDetailScreenState();
}

class _SneakerDetailScreenState extends ConsumerState<SneakerDetailScreen> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  late AudioPlayer _audioPlayer;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(duration: const Duration(seconds: 4), vsync: this);
    _audioPlayer = AudioPlayer();
    _initAudio();
  }

  Future<void> _initAudio() async {
    await _audioPlayer.setAudioContext(const AudioContext(
      android: AudioContextAndroid(isSpeakerphoneOn: true, stayAwake: true, audioFocus: AndroidAudioFocus.gain),
      iOS: AudioContextIOS(category: AVAudioSessionCategory.playback),
    ));
    await _audioPlayer.setVolume(0.5);
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    
    try {
      await _audioPlayer.play(AssetSource('sounds/beat.mp3'));
      setState(() { isPlaying = true; _rotationController.repeat(); });
    } catch (e) { print("Error audio: $e"); }
  }

  void _togglePlay() async {
    if (isPlaying) { await _audioPlayer.pause(); _rotationController.stop(); }
    else { await _audioPlayer.resume(); _rotationController.repeat(); }
    setState(() => isPlaying = !isPlaying);
  }

  // --- NOUVELLE FONCTION : SUPPRIMER ---
  void _deleteSneaker() async {
    // 1. Arrêter la musique
    await _audioPlayer.stop();
    
    // 2. Appeler le provider pour supprimer (si l'ID existe)
    if (widget.sneaker.id != null) {
      await ref.read(sneakerListProvider.notifier).removeSneaker(widget.sneaker.id!);
    }

    // 3. Revenir à l'accueil
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("KICKS REMOVED FROM VAULT 🗑️"),
          backgroundColor: Colors.red,
        )
      );
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white), 
          onPressed: () => Navigator.pop(context)
        ),
        // --- BOUTON SUPPRIMER ---
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.vinylRed, size: 28),
            onPressed: () {
              // Petite confirmation avant de supprimer
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.surface,
                  title: Text("DELETE?", style: GoogleFonts.bebasNeue(color: Colors.white, fontSize: 24)),
                  content: const Text("Are you sure you want to trash these kicks?", style: TextStyle(color: Colors.grey)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("NO", style: TextStyle(color: Colors.white))),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx); // Ferme le dialogue
                        _deleteSneaker();   // Supprime vraiment
                      }, 
                      child: const Text("YES, TRASH IT", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _togglePlay,
            child: AnimatedBuilder(
              animation: _rotationController,
              builder: (_, child) => Transform.rotate(angle: _rotationController.value * 6.28, child: child),
              child: CircleAvatar(radius: 140, backgroundImage: FileImage(File(widget.sneaker.imagePath))),
            ),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                border: Border(top: BorderSide(color: AppColors.accent, width: 3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.sneaker.brand.toUpperCase(), style: GoogleFonts.robotoMono(color: AppColors.highlight, fontSize: 16)),
                  Text(widget.sneaker.model, style: GoogleFonts.bebasNeue(fontSize: 40, color: Colors.white)),
                  const Divider(color: Colors.white24, height: 40),
                  _row("YEAR", "${widget.sneaker.year}"),
                  _row("PRICE", "\$${widget.sneaker.price.toInt()}"),
                  const Spacer(),
                  Center(child: Text(isPlaying ? "SPINNING..." : "PAUSED", style: GoogleFonts.robotoMono(color: isPlaying ? AppColors.accent : Colors.grey))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String k, String v) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(k, style: const TextStyle(color: Colors.grey)), Text(v, style: GoogleFonts.bebasNeue(color: Colors.white, fontSize: 24))]));
}