# 👟 SNEAKER VAULT

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0-0175C2?style=for-the-badge&logo=dart)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android-lightgrey?style=for-the-badge)

**The ultimate digital collection manager for Sneakerheads.**

Sneaker Vault est une application mobile Flutter haut de gamme conçue pour les collectionneurs de sneakers. Elle combine une gestion d'inventaire locale, des estimations de marché en temps réel, une gamification engageante et des outils de découverte urbaine, le tout enveloppé dans une interface "Streetwear/Dark Mode" soignée.

---

## ✨ Fonctionnalités

### 📸 **Smart Capture & Vault**
* **Ajout Intelligent :** Prenez une photo, l'application recherche automatiquement l'image officielle du modèle (Google Search) et estime son prix marché.
* **Mode Secours :** Si aucune connexion n'est disponible, la photo caméra est conservée.
* **Stockage Local :** Toutes les données sont sauvegardées en local via **SQLite** (100% privé et hors-ligne).

### 📈 **Market Dashboard**
* **Analyses en temps réel :** Visualisez la valeur totale de votre collection.
* **Equalizer Chart :** Un graphique interactif style "Table de mixage" montrant la dominance des marques dans votre collection.

### 🎧 **Listening Room (Détails)**
* **Expérience Immersive :** Chaque sneaker s'affiche sur un vinyle tournant animé.
* **Vibe Audio :** Lecture d'un beat Hip-Hop local en boucle lors de la consultation des détails.

### 🌍 **Street Map**
* **Localisation :** Carte sombre (Dark Matter style) via **OpenStreetMap**.
* **Shops Finder :** Génération de spots sneakers (Boutiques, Resell, Outlets) autour de votre position GPS réelle.

### 📰 **Fresh Drops News**
* **Scraping en direct :** Récupération des dernières sorties via scraping web (SneakerNews).
* **Mode Hybride :** Bascule automatiquement sur des données simulées si le réseau est indisponible.

### 👑 **My Rep (Gamification)**
* **Système de Rangs :** Évoluez de *Noob* à *Legend* en agrandissant votre collection.
* **Badges :** Débloquez des succès visuels.

---

## 📱 Aperçu de l'interface

| Home Screen | Market Stats | Street Map |
|:-----------:|:------------:|:----------:|
| <img src="assets/screenshots/home.png" width="200" alt="Home"> | <img src="assets/screenshots/stats.png" width="200" alt="Stats"> | <img src="assets/screenshots/map.png" width="200" alt="Map"> |

*(Note : Ajoutez vos captures d'écran dans un dossier `assets/screenshots` pour remplacer ces placeholders)*

---

## 🛠️ Stack Technique

* **Framework :** Flutter & Dart
* **State Management :** [Riverpod](https://riverpod.dev/) (Architecture propre et réactive)
* **Base de données :** [Sqflite](https://pub.dev/packages/sqflite) (Stockage persistant)
* **Réseau :** [Dio](https://pub.dev/packages/dio) & [Http](https://pub.dev/packages/http)
* **Scraping :** [Html](https://pub.dev/packages/html) (Parsing DOM)
* **Cartographie :** [Flutter Map](https://pub.dev/packages/flutter_map) + [Latlong2](https://pub.dev/packages/latlong2)
* **Graphiques :** [Fl_Chart](https://pub.dev/packages/fl_chart)
* **Design :** [Google Fonts](https://pub.dev/packages/google_fonts) (Bebas Neue, Sedgwick Ave)

---

## 🚀 Installation

1.  **Cloner le projet**
    ```bash
    git clone [https://github.com/VOTRE_USERNAME/sneaker_vault.git](https://github.com/VOTRE_USERNAME/sneaker_vault.git)
    cd sneaker_vault
    ```

2.  **Installer les dépendances**
    ```bash
    flutter pub get
    ```

3.  **Configurer les Assets**
    Assurez-vous que le fichier `beat.mp3` est présent dans `assets/sounds/`.

4.  **Lancer l'application**
    ```bash
    flutter run
    ```

---

## 🔑 Configuration API (Optionnel)

L'application fonctionne en mode **"Démo/Fallback"** par défaut (sans clés API). Pour activer les fonctionnalités réelles de recherche d'images :

1.  Allez dans `lib/core/services/search_service.dart`.
2.  Ajoutez votre clé **Google Custom Search API** :
    ```dart
    static const String _apiKey = 'VOTRE_CLE_GOOGLE';
    static const String _cx = 'VOTRE_CX_ID';
    ```

---

## 📂 Architecture du projet

Le projet suit une architecture **Feature-First** pour une meilleure maintenabilité :

```text
lib/
├── core/                # Composants partagés (UI, Services, Thèmes)
│   ├── services/        # Logique métier (API, DB, GPS)
│   ├── theme/           # Couleurs et styles
│   └── ui/              # Widgets réutilisables (UrbanCard, Buttons)
├── features/
│   ├── home/            # Écran d'accueil
│   ├── market/          # Statistiques & Graphiques
│   ├── vault/           # Gestion de la collection (CRUD)
│   ├── map/             # Carte & GPS
│   ├── news/            # Actualités & Scraping
│   └── profile/         # Gamification & Utilisateur
└── main.dart            # Point d'entrée