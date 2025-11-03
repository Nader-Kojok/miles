# 🚗 Bolide - Application de vente de pièces détachées

Application mobile Flutter pour la vente de pièces détachées automobile au Sénégal.

## ✨ Fonctionnalités

### Authentification
- ✅ Connexion par numéro de téléphone (SMS OTP)
- ✅ Connexion avec Google Sign-In
- ✅ Gestion automatique de la session

### Catalogue
- ✅ Navigation par catégories (Moteur, Freinage, Suspension, etc.)
- ✅ Recherche de produits
- ✅ Affichage en grille avec images
- ✅ Détails des produits
- ✅ Statut de disponibilité

### Commandes
- ✅ Historique des commandes
- ✅ Suivi du statut
- ✅ Détails des commandes

### Profil utilisateur
- ✅ Informations personnelles
- ✅ Paramètres de l'application
- ✅ Déconnexion

## 🛠️ Technologies utilisées

- **Frontend**: Flutter 3.9.2+
- **Backend**: Supabase
  - Base de données PostgreSQL
  - Authentication (Phone & Google)
  - Row Level Security
- **State Management**: Provider
- **UI/UX**: Material Design 3

## 📋 Prérequis

- Flutter SDK 3.9.2 ou supérieur
- Compte Supabase (gratuit)
- Compte Google Cloud (pour Google Sign-In)
- Un fournisseur SMS pour l'authentification par téléphone (Twilio, MessageBird, etc.)

## 🚀 Installation

1. **Cloner le projet**
```bash
cd bolide
```

2. **Installer les dépendances**
```bash
flutter pub get
```

3. **Configurer Supabase**
   
   Voir le fichier détaillé: [README_CONFIG.md](README_CONFIG.md)

4. **Lancer l'application**
```bash
flutter run
```

## 📱 Captures d'écran

L'application comprend:
- Page de connexion avec options téléphone et Google
- Vérification OTP par SMS
- Catalogue de produits avec recherche et filtres
- Page détail produit
- Historique des commandes
- Profil utilisateur

## 📂 Structure du projet

```
lib/
├── main.dart                    # Point d'entrée
├── models/
│   └── product.dart            # Modèle de données produit
├── screens/
│   ├── login_screen.dart       # Page de connexion
│   ├── otp_verification_screen.dart  # Vérification OTP
│   ├── home_screen.dart        # Écran principal avec navigation
│   ├── catalog_screen.dart     # Catalogue des produits
│   ├── product_detail_screen.dart  # Détails d'un produit
│   ├── orders_screen.dart      # Historique des commandes
│   └── profile_screen.dart     # Profil utilisateur
└── services/
    └── supabase_service.dart   # Service d'authentification
```

## ⚙️ Configuration

Consultez [README_CONFIG.md](README_CONFIG.md) pour les instructions détaillées de configuration incluant:
- Configuration Supabase
- Configuration Google Sign-In
- Création des tables de base de données
- Politiques de sécurité RLS

## 🌍 Localisation

- Pays: Sénégal (SN)
- Devise: Franc CFA (FCFA)
- Indicatif téléphonique: +221
- Langue: Français

## 📝 TODO

- [ ] Intégrer le panier d'achat
- [ ] Système de paiement mobile (Orange Money, Wave)
- [ ] Notifications push
- [ ] Chat en direct avec le vendeur
- [ ] Système de notation et avis
- [ ] Géolocalisation pour la livraison
- [ ] Mode sombre

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à ouvrir une issue ou soumettre une pull request.

## 📄 Licence

Ce projet est sous licence MIT.
