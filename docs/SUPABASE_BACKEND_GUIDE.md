# 🚀 Guide d'implémentation Backend Supabase pour Bolide

## 📋 Table des matières
1. [Prérequis](#prérequis)
2. [Configuration Supabase](#configuration-supabase)
3. [Schéma de base de données](#schéma-de-base-de-données)
4. [Politiques RLS](#politiques-rls)
5. [Intégration Flutter](#intégration-flutter)
6. [Services à implémenter](#services-à-implémenter)

---

## 1. Prérequis

### Informations nécessaires

**Je vais avoir besoin de :**

- [ ] **URL du projet Supabase** (format: `https://xxxxx.supabase.co`)
- [ ] **Clé publique (anon key)** depuis le dashboard Supabase
- [ ] **Clé de service (service_role key)** pour les opérations admin (optionnel)
- [ ] **Configuration Google OAuth** (si connexion Google activée)
  - Client ID Web
  - Client Secret

### Packages déjà installés ✅
```yaml
supabase_flutter: ^2.8.0  # ✅ Déjà dans pubspec.yaml
google_sign_in: ^6.2.2     # ✅ Déjà dans pubspec.yaml
provider: ^6.1.2           # ✅ Pour state management
```

---

## 2. Configuration Supabase

### Étape 1: Créer le projet Supabase
1. Aller sur [database.new](https://database.new)
2. Créer un nouveau projet
3. Choisir la région (recommandé: `eu-west-1` pour l'Europe)
4. Définir un mot de passe sécurisé pour la base de données

### Étape 2: Récupérer les credentials
Dans le dashboard Supabase → Settings → API:
- **Project URL**: `https://xxxxx.supabase.co`
- **anon/public key**: `eyJhbGc...` (clé publique)
- **service_role key**: `eyJhbGc...` (clé privée - à garder secrète)

---

## 3. Schéma de base de données

### Tables à créer

#### 3.1 Table `profiles` (Profils utilisateurs)
```sql
-- Table des profils utilisateurs
create table public.profiles (
  id uuid references auth.users on delete cascade primary key,
  phone varchar(20),
  full_name text,
  avatar_url text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS
alter table public.profiles enable row level security;

-- Trigger pour créer automatiquement un profil lors de l'inscription
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, phone, full_name)
  values (new.id, new.phone, new.raw_user_meta_data->>'full_name');
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
```

#### 3.2 Table `categories` (Catégories de produits)
```sql
create table public.categories (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  slug text unique not null,
  icon text,
  description text,
  image_url text,
  parent_id uuid references public.categories(id),
  display_order int default 0,
  is_active boolean default true,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.categories enable row level security;
```

#### 3.3 Table `products` (Produits)
```sql
create table public.products (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  slug text unique not null,
  description text,
  price decimal(10,2) not null,
  compare_at_price decimal(10,2),
  category_id uuid references public.categories(id),
  image_url text,
  images text[], -- Array d'URLs d'images
  in_stock boolean default true,
  stock_quantity int default 0,
  sku text unique,
  brand text,
  weight decimal(10,2),
  dimensions jsonb, -- {length, width, height}
  tags text[],
  is_featured boolean default false,
  is_active boolean default true,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.products enable row level security;

-- Index pour les recherches
create index products_name_idx on public.products using gin(to_tsvector('french', name));
create index products_category_idx on public.products(category_id);
create index products_is_featured_idx on public.products(is_featured) where is_featured = true;
```

#### 3.4 Table `favorites` (Favoris)
```sql
create table public.favorites (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  product_id uuid references public.products(id) on delete cascade not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique(user_id, product_id)
);

alter table public.favorites enable row level security;

-- Index pour les requêtes
create index favorites_user_id_idx on public.favorites(user_id);
create index favorites_product_id_idx on public.favorites(product_id);
```

#### 3.5 Table `addresses` (Adresses de livraison)
```sql
create table public.addresses (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  label text not null, -- "Maison", "Bureau", etc.
  full_name text not null,
  phone varchar(20) not null,
  address_line1 text not null,
  address_line2 text,
  city text not null,
  postal_code text,
  country text default 'CI' not null,
  is_default boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.addresses enable row level security;

-- Index
create index addresses_user_id_idx on public.addresses(user_id);
```

#### 3.6 Table `orders` (Commandes)
```sql
create type order_status as enum ('pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled');
create type payment_status as enum ('pending', 'paid', 'failed', 'refunded');

create table public.orders (
  id uuid default gen_random_uuid() primary key,
  order_number text unique not null,
  user_id uuid references public.profiles(id) on delete set null,
  
  -- Montants
  subtotal decimal(10,2) not null,
  shipping_cost decimal(10,2) default 0,
  tax decimal(10,2) default 0,
  discount decimal(10,2) default 0,
  total decimal(10,2) not null,
  
  -- Statuts
  status order_status default 'pending' not null,
  payment_status payment_status default 'pending' not null,
  payment_method text,
  
  -- Adresse de livraison
  shipping_address jsonb not null,
  
  -- Notes
  customer_notes text,
  admin_notes text,
  
  -- Dates
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null,
  confirmed_at timestamp with time zone,
  shipped_at timestamp with time zone,
  delivered_at timestamp with time zone
);

alter table public.orders enable row level security;

-- Fonction pour générer un numéro de commande unique
create or replace function generate_order_number()
returns text as $$
declare
  new_number text;
  done bool;
begin
  done := false;
  while not done loop
    new_number := 'XDR' || lpad(floor(random() * 1000000)::text, 6, '0');
    done := not exists(select 1 from orders where order_number = new_number);
  end loop;
  return new_number;
end;
$$ language plpgsql;

-- Index
create index orders_user_id_idx on public.orders(user_id);
create index orders_status_idx on public.orders(status);
create index orders_created_at_idx on public.orders(created_at desc);
```

#### 3.7 Table `order_items` (Articles de commande)
```sql
create table public.order_items (
  id uuid default gen_random_uuid() primary key,
  order_id uuid references public.orders(id) on delete cascade not null,
  product_id uuid references public.products(id) on delete set null,
  
  -- Snapshot du produit au moment de la commande
  product_name text not null,
  product_image text,
  product_sku text,
  
  -- Prix et quantité
  unit_price decimal(10,2) not null,
  quantity int not null check (quantity > 0),
  total_price decimal(10,2) not null,
  
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.order_items enable row level security;

-- Index
create index order_items_order_id_idx on public.order_items(order_id);
```

#### 3.8 Table `promo_codes` (Codes promo)
```sql
create type promo_type as enum ('percentage', 'fixed_amount');

create table public.promo_codes (
  id uuid default gen_random_uuid() primary key,
  code text unique not null,
  description text,
  type promo_type not null,
  value decimal(10,2) not null,
  min_purchase_amount decimal(10,2),
  max_discount_amount decimal(10,2),
  usage_limit int,
  usage_count int default 0,
  is_active boolean default true,
  valid_from timestamp with time zone,
  valid_until timestamp with time zone,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.promo_codes enable row level security;
```

#### 3.9 Table `notifications` (Notifications)
```sql
create type notification_type as enum ('order', 'promo', 'system', 'product');

create table public.notifications (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  type notification_type not null,
  title text not null,
  message text not null,
  data jsonb,
  is_read boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.notifications enable row level security;

-- Index
create index notifications_user_id_idx on public.notifications(user_id);
create index notifications_is_read_idx on public.notifications(is_read) where is_read = false;
```

---

## 4. Politiques RLS (Row Level Security)

### 4.1 Profiles
```sql
-- Les utilisateurs peuvent voir leur propre profil
create policy "Users can view own profile"
  on public.profiles for select
  to authenticated
  using (auth.uid() = id);

-- Les utilisateurs peuvent mettre à jour leur propre profil
create policy "Users can update own profile"
  on public.profiles for update
  to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);
```

### 4.2 Categories (Public read)
```sql
-- Tout le monde peut voir les catégories actives
create policy "Categories are viewable by everyone"
  on public.categories for select
  to anon, authenticated
  using (is_active = true);
```

### 4.3 Products (Public read)
```sql
-- Tout le monde peut voir les produits actifs
create policy "Products are viewable by everyone"
  on public.products for select
  to anon, authenticated
  using (is_active = true);
```

### 4.4 Favorites (User specific)
```sql
-- Les utilisateurs peuvent voir leurs propres favoris
create policy "Users can view own favorites"
  on public.favorites for select
  to authenticated
  using (auth.uid() = user_id);

-- Les utilisateurs peuvent ajouter des favoris
create policy "Users can insert own favorites"
  on public.favorites for insert
  to authenticated
  with check (auth.uid() = user_id);

-- Les utilisateurs peuvent supprimer leurs favoris
create policy "Users can delete own favorites"
  on public.favorites for delete
  to authenticated
  using (auth.uid() = user_id);
```

### 4.5 Addresses (User specific)
```sql
-- Les utilisateurs peuvent voir leurs propres adresses
create policy "Users can view own addresses"
  on public.addresses for select
  to authenticated
  using (auth.uid() = user_id);

-- Les utilisateurs peuvent créer des adresses
create policy "Users can insert own addresses"
  on public.addresses for insert
  to authenticated
  with check (auth.uid() = user_id);

-- Les utilisateurs peuvent mettre à jour leurs adresses
create policy "Users can update own addresses"
  on public.addresses for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Les utilisateurs peuvent supprimer leurs adresses
create policy "Users can delete own addresses"
  on public.addresses for delete
  to authenticated
  using (auth.uid() = user_id);
```

### 4.6 Orders (User specific)
```sql
-- Les utilisateurs peuvent voir leurs propres commandes
create policy "Users can view own orders"
  on public.orders for select
  to authenticated
  using (auth.uid() = user_id);

-- Les utilisateurs peuvent créer des commandes
create policy "Users can insert own orders"
  on public.orders for insert
  to authenticated
  with check (auth.uid() = user_id);
```

### 4.7 Order Items (Via orders)
```sql
-- Les utilisateurs peuvent voir les articles de leurs commandes
create policy "Users can view own order items"
  on public.order_items for select
  to authenticated
  using (
    exists (
      select 1 from public.orders
      where orders.id = order_items.order_id
      and orders.user_id = auth.uid()
    )
  );

-- Les utilisateurs peuvent créer des articles de commande
create policy "Users can insert own order items"
  on public.order_items for insert
  to authenticated
  with check (
    exists (
      select 1 from public.orders
      where orders.id = order_items.order_id
      and orders.user_id = auth.uid()
    )
  );
```

### 4.8 Notifications (User specific)
```sql
-- Les utilisateurs peuvent voir leurs notifications
create policy "Users can view own notifications"
  on public.notifications for select
  to authenticated
  using (auth.uid() = user_id);

-- Les utilisateurs peuvent mettre à jour leurs notifications (marquer comme lu)
create policy "Users can update own notifications"
  on public.notifications for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
```

---

## 5. Intégration Flutter

### 5.1 Configuration dans `main.dart`

**Ce que je vais modifier :**
```dart
await Supabase.initialize(
  url: 'VOTRE_URL_ICI',        // À fournir
  anonKey: 'VOTRE_ANON_KEY',   // À fournir
);
```

### 5.2 Variables d'environnement (Recommandé)

Créer un fichier `.env` (à ajouter dans `.gitignore`):
```env
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGc...
GOOGLE_WEB_CLIENT_ID=xxxxx.apps.googleusercontent.com
```

---

## 6. Services à implémenter

### 6.1 ProductService
```dart
class ProductService {
  // Récupérer tous les produits
  Future<List<Product>> getProducts({String? categoryId})
  
  // Récupérer un produit par ID
  Future<Product> getProductById(String id)
  
  // Rechercher des produits
  Future<List<Product>> searchProducts(String query)
  
  // Récupérer les produits en vedette
  Future<List<Product>> getFeaturedProducts()
}
```

### 6.2 FavoriteService
```dart
class FavoriteService {
  // Récupérer les favoris de l'utilisateur
  Future<List<Product>> getUserFavorites()
  
  // Ajouter aux favoris
  Future<void> addToFavorites(String productId)
  
  // Retirer des favoris
  Future<void> removeFromFavorites(String productId)
  
  // Vérifier si un produit est en favori
  Future<bool> isFavorite(String productId)
}
```

### 6.3 OrderService
```dart
class OrderService {
  // Créer une commande
  Future<Order> createOrder({
    required List<CartItem> items,
    required Address shippingAddress,
    String? promoCode,
  })
  
  // Récupérer les commandes de l'utilisateur
  Future<List<Order>> getUserOrders()
  
  // Récupérer une commande par ID
  Future<Order> getOrderById(String id)
  
  // Annuler une commande
  Future<void> cancelOrder(String orderId)
}
```

### 6.4 ProfileService
```dart
class ProfileService {
  // Récupérer le profil de l'utilisateur
  Future<Profile> getUserProfile()
  
  // Mettre à jour le profil
  Future<void> updateProfile({
    String? fullName,
    String? avatarUrl,
  })
  
  // Gérer les adresses
  Future<List<Address>> getAddresses()
  Future<void> addAddress(Address address)
  Future<void> updateAddress(Address address)
  Future<void> deleteAddress(String addressId)
  Future<void> setDefaultAddress(String addressId)
}
```

### 6.5 NotificationService
```dart
class NotificationService {
  // Récupérer les notifications
  Future<List<Notification>> getNotifications()
  
  // Marquer comme lu
  Future<void> markAsRead(String notificationId)
  
  // Marquer toutes comme lues
  Future<void> markAllAsRead()
  
  // Compter les non lues
  Future<int> getUnreadCount()
}
```

---

## 7. Données de test à insérer

### Catégories
```sql
insert into public.categories (name, slug, icon, description) values
  ('Moteur', 'moteur', 'build', 'Pièces moteur et transmission'),
  ('Freinage', 'freinage', 'speed', 'Système de freinage'),
  ('Suspension', 'suspension', 'settings', 'Amortisseurs et suspension'),
  ('Électrique', 'electrique', 'flash_on', 'Composants électriques'),
  ('Carrosserie', 'carrosserie', 'directions_car', 'Éléments de carrosserie');
```

### Produits (exemples)
```sql
insert into public.products (name, slug, description, price, category_id, image_url, in_stock, stock_quantity, sku, brand) values
  (
    'Plaquettes de frein avant',
    'plaquettes-frein-avant',
    'Plaquettes de frein céramique haute performance',
    25000,
    (select id from categories where slug = 'freinage'),
    'https://example.com/brake-pads.jpg',
    true,
    50,
    'BRK-001',
    'Brembo'
  ),
  (
    'Filtre à huile',
    'filtre-huile',
    'Filtre à huile compatible tous véhicules',
    5000,
    (select id from categories where slug = 'moteur'),
    'https://example.com/oil-filter.jpg',
    true,
    100,
    'OIL-001',
    'Mann Filter'
  );
```

---

## 8. Checklist d'implémentation

### Phase 1: Configuration initiale
- [ ] Créer le projet Supabase
- [ ] Récupérer URL et anon key
- [ ] Configurer l'authentification (Phone + Google)
- [ ] Mettre à jour `main.dart` avec les credentials

### Phase 2: Base de données
- [ ] Créer toutes les tables
- [ ] Configurer les politiques RLS
- [ ] Insérer les données de test
- [ ] Tester les requêtes dans le SQL Editor

### Phase 3: Services Flutter
- [ ] Implémenter ProductService
- [ ] Implémenter FavoriteService
- [ ] Implémenter OrderService
- [ ] Implémenter ProfileService
- [ ] Implémenter NotificationService

### Phase 4: Intégration UI
- [ ] Connecter NewCatalogScreen aux produits réels
- [ ] Connecter FavoritesScreen aux favoris réels
- [ ] Connecter NewOrdersScreen aux commandes réelles
- [ ] Connecter ProfileScreen au profil réel

### Phase 5: Tests
- [ ] Tester l'authentification
- [ ] Tester les opérations CRUD
- [ ] Tester les politiques RLS
- [ ] Tester la synchronisation temps réel

---

## 9. Informations dont j'ai besoin pour commencer

**Merci de me fournir :**

1. ✅ **URL Supabase** : `https://uerwlrpatvumjdksfgbj.supabase.co`
2. ✅ **Anon Key** : `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVlcndscnBhdHZ1bWpka3NmZ2JqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE4MzczNTEsImV4cCI6MjA3NzQxMzM1MX0.Q_TykGHuIEMyhOvf2OfmDh7PQbk54cZehNJKnc4CWYg`
3. ❓ **Voulez-vous que je crée les tables automatiquement ?** (Oui)
4. ❓ **Voulez-vous activer Google Sign-In ?** (Oui)
   - Si oui, fournir le Google Web Client ID (plus tard)
5. ❓ **Région préférée pour le projet** : (eu-west-1)
6. ❓ **Voulez-vous des données de test ?** (Oui)

---

## 10. Prochaines étapes

Une fois les informations fournies, je vais :

1. **Mettre à jour la configuration** dans `main.dart`
2. **Créer tous les services** nécessaires
3. **Générer le script SQL complet** pour créer toutes les tables
4. **Connecter les écrans existants** aux données réelles
5. **Implémenter la synchronisation temps réel**
6. **Ajouter la gestion d'erreurs et le cache**

🎯 **Objectif** : Avoir une application 100% fonctionnelle avec un backend Supabase complet !
