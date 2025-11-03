# Bolide - Application de vente de pièces détachées au Sénégal

## 🚀 Configuration

### 1. Créer un projet Supabase

1. Allez sur [supabase.com](https://supabase.com)
2. Créez un nouveau projet
3. Notez votre **URL du projet** et votre **clé anon (publique)**

### 2. Configurer l'authentification Supabase

#### Activer l'authentification par téléphone

1. Dans votre dashboard Supabase, allez dans **Authentication > Providers**
2. Activez **Phone**
3. Configurez un fournisseur SMS (Twilio, MessageBird, etc.)

#### Configurer Google Sign-In

1. Créez un projet sur [Google Cloud Console](https://console.cloud.google.com)
2. Activez l'API Google+ 
3. Créez des identifiants OAuth 2.0:
   - **Client ID Web** (pour Supabase)
   - **Client ID Android** (si vous déployez sur Android)
   - **Client ID iOS** (si vous déployez sur iOS)

4. Dans Supabase Dashboard:
   - Allez dans **Authentication > Providers**
   - Activez **Google**
   - Ajoutez votre **Web Client ID** dans "Authorized Client IDs"
   - Activez **Skip nonce checks** (pour iOS)

### 3. Configuration de l'application Flutter

#### Mettre à jour les credentials Supabase

Dans `lib/main.dart`, remplacez:
```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',        // Remplacez par votre URL
  anonKey: 'YOUR_SUPABASE_ANON_KEY', // Remplacez par votre clé anon
);
```

#### Configurer Google Sign-In

Dans `lib/services/supabase_service.dart`, remplacez:
```dart
final GoogleSignIn googleSignIn = GoogleSignIn(
  serverClientId: 'YOUR_WEB_CLIENT_ID', // Remplacez par votre Web Client ID
);
```

#### Configuration iOS (si nécessaire)

Dans `ios/Runner/Info.plist`, ajoutez:
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <!-- Remplacez par votre Reversed Client ID iOS -->
      <string>com.googleusercontent.apps.VOTRE-IOS-CLIENT-ID</string>
    </array>
  </dict>
</array>
```

### 4. Installer les dépendances

```bash
flutter pub get
```

### 5. Créer les tables Supabase

Exécutez ce SQL dans votre éditeur SQL Supabase:

```sql
-- Table des produits
CREATE TABLE products (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  price DECIMAL(10, 2) NOT NULL,
  category TEXT NOT NULL,
  image_url TEXT,
  in_stock BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des commandes
CREATE TABLE orders (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  total DECIMAL(10, 2) NOT NULL,
  status TEXT DEFAULT 'En cours',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des items de commande
CREATE TABLE order_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id),
  quantity INTEGER NOT NULL,
  price DECIMAL(10, 2) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Activer Row Level Security
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

-- Politiques RLS pour les produits (lecture publique)
CREATE POLICY "Les produits sont visibles par tous"
  ON products FOR SELECT
  USING (true);

-- Politiques RLS pour les commandes (utilisateur peut voir ses propres commandes)
CREATE POLICY "Les utilisateurs peuvent voir leurs commandes"
  ON orders FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Les utilisateurs peuvent créer leurs commandes"
  ON orders FOR INSERT
  WITH CHECK (auth.uid() = user_id);
```

## 📱 Structure de l'application

### Pages principales

- **LoginScreen** (`lib/screens/login_screen.dart`)
  - Connexion par numéro de téléphone (SMS OTP)
  - Connexion avec Google

- **OTPVerificationScreen** (`lib/screens/otp_verification_screen.dart`)
  - Vérification du code SMS à 6 chiffres

- **HomeScreen** (`lib/screens/home_screen.dart`)
  - Navigation par onglets (Catalogue, Commandes, Profil)

- **CatalogScreen** (`lib/screens/catalog_screen.dart`)
  - Liste des produits avec recherche et filtres par catégorie
  - Grille de produits avec images et prix

- **ProductDetailScreen** (`lib/screens/product_detail_screen.dart`)
  - Détails d'un produit
  - Ajout au panier

- **OrdersScreen** (`lib/screens/orders_screen.dart`)
  - Historique des commandes

- **ProfileScreen** (`lib/screens/profile_screen.dart`)
  - Informations utilisateur
  - Paramètres
  - Déconnexion

### Services

- **SupabaseService** (`lib/services/supabase_service.dart`)
  - Authentification par téléphone
  - Authentification Google
  - Gestion de session

## 🏃‍♂️ Lancer l'application

```bash
# Sur Android
flutter run

# Sur iOS
flutter run

# Sur Web
flutter run -d chrome
```

## 📝 Notes importantes

1. **Authentification par téléphone**: Nécessite un fournisseur SMS configuré dans Supabase (coûts associés)

2. **Google Sign-In sur iOS**: Nécessite la configuration du `CFBundleURLSchemes` dans Info.plist

3. **Images des produits**: Pour l'instant, l'app utilise des images placeholder. Pour utiliser de vraies images:
   - Configurez Supabase Storage
   - Uploadez vos images
   - Mettez à jour les URLs dans la base de données

4. **Données d'exemple**: Les produits et commandes affichés sont actuellement des données en dur. Connectez-les à Supabase pour des données réelles.

## 🔒 Sécurité

- Les clés API doivent être gardées confidentielles
- Ne commitez jamais les credentials dans le contrôle de version
- Utilisez des variables d'environnement pour les valeurs sensibles en production
- Les politiques RLS de Supabase protègent vos données

## 🌍 Internationalisation

L'application est configurée pour le Sénégal:
- Devise: FCFA
- Code pays par défaut: SN (+221)
- Format de date: fr_FR

## 📞 Support

Pour toute question concernant:
- **Supabase**: [Documentation Supabase](https://supabase.com/docs)
- **Flutter**: [Documentation Flutter](https://docs.flutter.dev)
- **Google Sign-In**: [Documentation Google](https://developers.google.com/identity)
