import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';
import '../../features/news/domain/news_model.dart';

class NewsService {
  static const String _targetUrl = 'https://sneakernews.com/release-dates/';

  Future<List<SneakerDrop>> getUpcomingDrops() async {
    try {
      // 1. LE CAMOUFLAGE (User-Agent)
      // On fait croire qu'on est un navigateur pour ne pas être bloqué (403 Forbidden)
      final response = await http.get(
        Uri.parse(_targetUrl),
        headers: {
          "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36",
          "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        },
      );

      if (response.statusCode == 200) {
        var document = parser.parse(response.body);
        // Sélecteurs CSS mis à jour (parfois ils changent)
        List<Element> cards = document.querySelectorAll('.popular-releases-block .releases-box');

        // Si la liste est vide, on tente un autre sélecteur (parfois la structure change)
        if (cards.isEmpty) {
           cards = document.querySelectorAll('.release-date-shoe-wrapper'); 
        }

        List<SneakerDrop> drops = [];

        for (var card in cards) {
          try {
            // Tentative d'extraction flexible
            var imgElement = card.querySelector('img');
            String image = imgElement?.attributes['src'] ?? "";
            
            // Parfois l'image est dans 'data-src' pour le lazy loading
            if (image.isEmpty) image = imgElement?.attributes['data-src'] ?? "";

            var titleElement = card.querySelector('h2 a') ?? card.querySelector('.release-date-title a');
            String name = titleElement?.text.trim() ?? "";

            var dateElement = card.querySelector('.release-date') ?? card.querySelector('.release-date-date');
            String date = dateElement?.text.trim() ?? "TBA";

            // Si on n'a pas de nom ou d'image, on ignore
            if (name.isNotEmpty && image.isNotEmpty) {
              drops.add(SneakerDrop(
                name: name,
                image: image,
                releaseDate: date,
                price: 0.0, // Prix souvent difficile à scraper, on met 0 ou TBA
                isHype: name.toLowerCase().contains("jordan") || name.toLowerCase().contains("dunk"),
              ));
            }
          } catch (e) {
            // Ignore les erreurs unitaires
          }
        }

        // SI ON A TROUVÉ DES VRAIS DROPS, ON LES RENVOIE
        if (drops.isNotEmpty) return drops;
      }
    } catch (e) {
      print("Erreur Scraping ($e) -> Passage au Plan B");
    }

    // 2. LE PLAN B (Fallback)
    // Si le scraping échoue (pas internet, site bloqué, structure changée),
    // on renvoie les données "Mock" pour que l'utilisateur voit quand même quelque chose.
    return _getMockDrops();
  }

  // Données de secours (Toujours disponibles)
  List<SneakerDrop> _getMockDrops() {
    return [
      SneakerDrop(
        name: "Travis Scott x Jordan 1 Low 'Olive'",
        image: "https://images.stockx.com/images/Air-Jordan-1-Retro-Low-OG-SP-Travis-Scott-Olive-W-Product.jpg?fit=fill&bg=FFFFFF&w=700&h=500&fm=webp&auto=compress&q=90&dpr=2&trim=color&updated_at=1681329530",
        releaseDate: "APR 26",
        price: 150.0,
        isHype: true,
      ),
      SneakerDrop(
        name: "Nike Dunk Low 'Panda'",
        image: "https://images.stockx.com/images/Nike-Dunk-Low-Retro-White-Black-2021-Product.jpg?fit=fill&bg=FFFFFF&w=700&h=500&fm=webp&auto=compress&q=90&dpr=2&trim=color&updated_at=1633027409",
        releaseDate: "RESTOCK",
        price: 110.0,
        isHype: false,
      ),
      SneakerDrop(
        name: "Jordan 4 Retro 'Military Blue'",
        image: "https://images.stockx.com/images/Air-Jordan-4-Retro-Military-Blue-2024-Product.jpg?fit=fill&bg=FFFFFF&w=700&h=500&fm=webp&auto=compress&q=90&dpr=2&trim=color&updated_at=1712152307",
        releaseDate: "MAY 04",
        price: 215.0,
        isHype: true,
      ),
      SneakerDrop(
        name: "Kobe 6 Protro 'Reverse Grinch'",
        image: "https://images.stockx.com/images/Nike-Kobe-6-Protro-Reverse-Grinch-Product.jpg?fit=fill&bg=FFFFFF&w=700&h=500&fm=webp&auto=compress&q=90&dpr=2&trim=color&updated_at=1702483079",
        releaseDate: "DEC 15",
        price: 190.0,
        isHype: true,
      ),
    ];
  }
}