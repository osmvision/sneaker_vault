import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/ui/crt_effect.dart';
import '../../vault/domain/sneaker_model.dart';

class SneakerDetailScreen extends StatefulWidget {
  final Sneaker sneaker;
  const SneakerDetailScreen({super.key, required this.sneaker});

  @override
  State<SneakerDetailScreen> createState() => _SneakerDetailScreenState();
}

class _SneakerDetailScreenState extends State<SneakerDetailScreen> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  late AudioPlayer _audioPlayer;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    // Animation : Tourne en 4 secondes (33 tours)
    _rotationController = AnimationController(duration: const Duration(seconds: 4), vsync: this);
    
    _audioPlayer = AudioPlayer();
    _initAudio();
  }

  Future<void> _initAudio() async {
    // Ta config audio était parfaite, je la garde !
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

  @override
  void dispose() {
    _rotationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CRTEffect(
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white), 
            onPressed: () => Navigator.pop(context)
          ),
        ),
        body: Column(
          children: [
            const SizedBox(height: 10),
            
            // --- 1. LE VINYLE (On remplace le simple CircleAvatar par ça) ---
            GestureDetector(
              onTap: _togglePlay,
              child: AnimatedBuilder(
                animation: _rotationController,
                builder: (_, child) => Transform.rotate(angle: _rotationController.value * 6.28, child: child),
                child: _buildVinylDisk(), // Appel du widget custom plus bas
              ),
            ),
            
            const SizedBox(height: 30),

            // --- 2. LA FICHE TECHNIQUE (Zone noire en bas) ---
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                  border: Border(top: BorderSide(color: Color(0xFFD000FF), width: 4)), // Bordure Néon Violette
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Marque (Petit texte cyan)
                    Text(
                      widget.sneaker.brand.toUpperCase(),
                      style: GoogleFonts.robotoMono(color: const Color(0xFF00FFE0), fontSize: 16, letterSpacing: 2),
                    ),
                    // Modèle (Gros titre)
                    Text(
                      widget.sneaker.model,
                      style: GoogleFonts.permanentMarker(fontSize: 32, color: Colors.white, height: 1.1),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 20),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 20),

                    // Liste des détails style "Ticket"
                    _buildDetailRow("YEAR", "${widget.sneaker.year}"),
                    _buildDetailRow("COLORWAY", widget.sneaker.colorway),
                    _buildDetailRow("EST. VALUE", "\$${widget.sneaker.price.toInt()}"),
                    
                    const Spacer(),
                    
                    // Indicateur Play/Pause
                    Center(
                      child: Text(
                        isPlaying ? "NOW PLAYING..." : "PAUSED", 
                        style: GoogleFonts.robotoMono(
                          color: isPlaying ? const Color(0xFFD000FF) : Colors.white30, 
                          fontWeight: FontWeight.bold
                        )
                      ),
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

  // --- WIDGETS DE STYLE ---

  // Le Disque Vinyle Réaliste
  Widget _buildVinylDisk() {
    return Container(
      width: 260, height: 260,
      decoration: BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: const Color(0xFFD000FF).withOpacity(0.4), blurRadius: 20, spreadRadius: 2), // Glow Violet
        ],
        border: Border.all(color: Colors.black, width: 8),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Les sillons du vinyle
          Container(
            width: 240, height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white10, width: 2),
              gradient: const RadialGradient(colors: [Colors.black, Color(0xFF222222)]),
            ),
          ),
          // L'image de la sneaker (Macaron central)
          ClipOval(
            child: SizedBox(
              width: 150, height: 150,
              child: Image.file(File(widget.sneaker.imagePath), fit: BoxFit.cover),
            ),
          ),
          // Le trou central blanc
          Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
        ],
      ),
    );
  }

  // La ligne de détail style "Ticket de concert"
  Widget _buildDetailRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05), // Fond très léger
        borderRadius: BorderRadius.circular(8),
        border: const Border(left: BorderSide(color: Color(0xFF00FFE0), width: 3)), // Barre Cyan à gauche
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.robotoMono(color: Colors.white54, fontSize: 12)),
          Text(value.toUpperCase(), style: GoogleFonts.bebasNeue(color: Colors.white, fontSize: 20, letterSpacing: 1)),
        ],
      ),
    );
  }
}