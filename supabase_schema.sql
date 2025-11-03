-- =============================================
-- Script SQL complet pour Bolide - E-commerce
-- À exécuter dans le SQL Editor de Supabase
-- =============================================

-- =============================================
-- 1. CRÉATION DES TYPES ENUM
-- =============================================

create type order_status as enum ('pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled');
create type payment_status as enum ('pending', 'paid', 'failed', 'refunded');
create type promo_type as enum ('percentage', 'fixed_amount');
create type notification_type as enum ('order', 'promo', 'system', 'product');

-- =============================================
-- 2. CRÉATION DES TABLES
-- =============================================

-- ---------------------------------------------
-- 2.1 Table profiles (Profils utilisateurs)
-- ---------------------------------------------
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

-- ---------------------------------------------
-- 2.2 Table categories (Catégories de produits)
-- ---------------------------------------------
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

-- ---------------------------------------------
-- 2.3 Table products (Produits)
-- ---------------------------------------------
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
create index products_is_active_idx on public.products(is_active) where is_active = true;

-- ---------------------------------------------
-- 2.4 Table favorites (Favoris)
-- ---------------------------------------------
create table public.favorites (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  product_id uuid references public.products(id) on delete cascade not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique(user_id, product_id)
);

alter table public.favorites enable row level security;

-- Index
create index favorites_user_id_idx on public.favorites(user_id);
create index favorites_product_id_idx on public.favorites(product_id);

-- ---------------------------------------------
-- 2.5 Table addresses (Adresses de livraison)
-- ---------------------------------------------
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

-- Fonction pour garantir qu'il n'y a qu'une seule adresse par défaut par utilisateur
create or replace function public.ensure_single_default_address()
returns trigger as $$
begin
  if new.is_default = true then
    update public.addresses
    set is_default = false
    where user_id = new.user_id and id != new.id;
  end if;
  return new;
end;
$$ language plpgsql;

create trigger ensure_single_default_address_trigger
  before insert or update on public.addresses
  for each row execute procedure public.ensure_single_default_address();

-- ---------------------------------------------
-- 2.6 Table orders (Commandes)
-- ---------------------------------------------
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
  
  -- Adresse de livraison (snapshot)
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
create index orders_order_number_idx on public.orders(order_number);

-- ---------------------------------------------
-- 2.7 Table order_items (Articles de commande)
-- ---------------------------------------------
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

-- ---------------------------------------------
-- 2.8 Table promo_codes (Codes promo)
-- ---------------------------------------------
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

-- Index
create index promo_codes_code_idx on public.promo_codes(code);
create index promo_codes_is_active_idx on public.promo_codes(is_active) where is_active = true;

-- ---------------------------------------------
-- 2.9 Table notifications (Notifications)
-- ---------------------------------------------
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
create index notifications_created_at_idx on public.notifications(created_at desc);

-- =============================================
-- 3. POLITIQUES RLS (Row Level Security)
-- =============================================

-- ---------------------------------------------
-- 3.1 Profiles
-- ---------------------------------------------
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

-- ---------------------------------------------
-- 3.2 Categories (Public read)
-- ---------------------------------------------
-- Tout le monde peut voir les catégories actives
create policy "Categories are viewable by everyone"
  on public.categories for select
  to anon, authenticated
  using (is_active = true);

-- ---------------------------------------------
-- 3.3 Products (Public read)
-- ---------------------------------------------
-- Tout le monde peut voir les produits actifs
create policy "Products are viewable by everyone"
  on public.products for select
  to anon, authenticated
  using (is_active = true);

-- ---------------------------------------------
-- 3.4 Favorites (User specific)
-- ---------------------------------------------
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

-- ---------------------------------------------
-- 3.5 Addresses (User specific)
-- ---------------------------------------------
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

-- ---------------------------------------------
-- 3.6 Orders (User specific)
-- ---------------------------------------------
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

-- ---------------------------------------------
-- 3.7 Order Items (Via orders)
-- ---------------------------------------------
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

-- ---------------------------------------------
-- 3.8 Promo Codes (Public read active codes)
-- ---------------------------------------------
-- Tout le monde peut voir les codes promo actifs
create policy "Active promo codes are viewable"
  on public.promo_codes for select
  to anon, authenticated
  using (
    is_active = true
    and (valid_from is null or valid_from <= now())
    and (valid_until is null or valid_until >= now())
  );

-- ---------------------------------------------
-- 3.9 Notifications (User specific)
-- ---------------------------------------------
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

-- =============================================
-- 4. DONNÉES DE TEST
-- =============================================

-- ---------------------------------------------
-- 4.1 Catégories
-- ---------------------------------------------
insert into public.categories (name, slug, icon, description, display_order) values
  ('Moteur', 'moteur', 'build', 'Pièces moteur et transmission', 1),
  ('Freinage', 'freinage', 'speed', 'Système de freinage complet', 2),
  ('Suspension', 'suspension', 'settings', 'Amortisseurs et suspension', 3),
  ('Électrique', 'electrique', 'flash_on', 'Composants électriques et électroniques', 4),
  ('Carrosserie', 'carrosserie', 'directions_car', 'Éléments de carrosserie et accessoires', 5),
  ('Filtration', 'filtration', 'filter_list', 'Filtres à huile, air et carburant', 6),
  ('Éclairage', 'eclairage', 'lightbulb', 'Phares, feux et ampoules', 7),
  ('Climatisation', 'climatisation', 'ac_unit', 'Système de climatisation', 8);

-- ---------------------------------------------
-- 4.2 Produits
-- ---------------------------------------------
insert into public.products (name, slug, description, price, compare_at_price, category_id, image_url, in_stock, stock_quantity, sku, brand, is_featured, tags) values
  -- Freinage
  (
    'Plaquettes de frein avant céramique',
    'plaquettes-frein-avant-ceramique',
    'Plaquettes de frein céramique haute performance. Excellente résistance à la chaleur et durabilité accrue. Compatible avec la plupart des véhicules.',
    25000,
    32000,
    (select id from categories where slug = 'freinage'),
    'https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?w=500',
    true,
    50,
    'BRK-001',
    'Brembo',
    true,
    array['freinage', 'ceramique', 'performance']
  ),
  (
    'Disques de frein ventilés',
    'disques-frein-ventiles',
    'Disques de frein ventilés pour un meilleur refroidissement. Diamètre 280mm. Qualité OEM.',
    45000,
    null,
    (select id from categories where slug = 'freinage'),
    'https://images.unsplash.com/photo-1625047509168-a7026f36de04?w=500',
    true,
    30,
    'BRK-002',
    'Bosch',
    false,
    array['freinage', 'disque', 'ventile']
  ),
  
  -- Moteur
  (
    'Filtre à huile haute qualité',
    'filtre-huile-haute-qualite',
    'Filtre à huile compatible avec la plupart des moteurs essence et diesel. Filtration optimale des impuretés.',
    5000,
    7500,
    (select id from categories where slug = 'filtration'),
    'https://images.unsplash.com/photo-1625895197185-efcec01cffe0?w=500',
    true,
    100,
    'OIL-001',
    'Mann Filter',
    true,
    array['moteur', 'filtre', 'huile']
  ),
  (
    'Bougie d''allumage performance',
    'bougie-allumage-performance',
    'Bougies d''allumage longue durée avec électrodes en iridium. Améliore les performances et réduit la consommation.',
    8000,
    null,
    (select id from categories where slug = 'electrique'),
    'https://images.unsplash.com/photo-1625047509841-bbe1c5b6dce5?w=500',
    true,
    80,
    'ELC-001',
    'NGK',
    false,
    array['moteur', 'allumage', 'performance']
  ),
  
  -- Suspension
  (
    'Amortisseur avant gauche',
    'amortisseur-avant-gauche',
    'Amortisseur à gaz haute pression. Améliore le confort et la tenue de route. Installation facile.',
    35000,
    42000,
    (select id from categories where slug = 'suspension'),
    'https://images.unsplash.com/photo-1619642751034-765dfdf7c58e?w=500',
    true,
    25,
    'SUS-001',
    'Monroe',
    true,
    array['suspension', 'amortisseur', 'confort']
  ),
  (
    'Kit de silent-blocs',
    'kit-silent-blocs',
    'Kit complet de silent-blocs pour train avant. Réduit les vibrations et améliore la direction.',
    18000,
    null,
    (select id from categories where slug = 'suspension'),
    'https://images.unsplash.com/photo-1625895197185-efcec01cffe0?w=500',
    true,
    40,
    'SUS-002',
    'Lemförder',
    false,
    array['suspension', 'silent-bloc', 'train-avant']
  ),
  
  -- Carrosserie
  (
    'Rétroviseur droit électrique',
    'retroviseur-droit-electrique',
    'Rétroviseur extérieur droit avec réglage électrique. Chauffant et rabattable. Finition noire brillante.',
    28000,
    35000,
    (select id from categories where slug = 'carrosserie'),
    'https://images.unsplash.com/photo-1449426468159-d96dbf08f19f?w=500',
    true,
    15,
    'CAR-001',
    'Magneti Marelli',
    false,
    array['carrosserie', 'retroviseur', 'electrique']
  ),
  
  -- Éclairage
  (
    'Ampoule LED H7 blanc pur',
    'ampoule-led-h7-blanc-pur',
    'Ampoule LED H7 6000K pour phares. Lumière blanche pure, consommation réduite, longue durée de vie.',
    12000,
    null,
    (select id from categories where slug = 'eclairage'),
    'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=500',
    true,
    60,
    'ECL-001',
    'Philips',
    true,
    array['eclairage', 'led', 'phare']
  ),
  
  -- Climatisation
  (
    'Filtre d''habitacle anti-pollen',
    'filtre-habitacle-anti-pollen',
    'Filtre d''habitacle avec charbon actif. Bloque 99% du pollen et des particules fines. Air pur garanti.',
    8500,
    null,
    (select id from categories where slug = 'climatisation'),
    'https://images.unsplash.com/photo-1625047509841-bbe1c5b6dce5?w=500',
    true,
    70,
    'CLI-001',
    'Bosch',
    false,
    array['climatisation', 'filtre', 'habitacle']
  ),
  
  -- Plus de produits pour remplir le catalogue
  (
    'Kit embrayage complet',
    'kit-embrayage-complet',
    'Kit embrayage 3 pièces : disque, mécanisme et butée. Compatible véhicules essence et diesel.',
    85000,
    105000,
    (select id from categories where slug = 'moteur'),
    'https://images.unsplash.com/photo-1625047509168-a7026f36de04?w=500',
    true,
    12,
    'MOT-001',
    'Valeo',
    true,
    array['moteur', 'embrayage', 'kit']
  );

-- ---------------------------------------------
-- 4.3 Codes promo
-- ---------------------------------------------
insert into public.promo_codes (code, description, type, value, min_purchase_amount, is_active, valid_from, valid_until) values
  ('BIENVENUE10', 'Réduction de 10% pour les nouveaux clients', 'percentage', 10, 20000, true, now(), now() + interval '30 days'),
  ('FREINS5000', 'Réduction de 5000 FCFA sur les produits de freinage', 'fixed_amount', 5000, 30000, true, now(), now() + interval '15 days'),
  ('HIVER2025', 'Promotion d''hiver - 15% de réduction', 'percentage', 15, 50000, true, now(), now() + interval '60 days');

-- =============================================
-- FIN DU SCRIPT
-- =============================================

-- Vérification des tables créées
select 
  schemaname,
  tablename 
from pg_tables 
where schemaname = 'public' 
order by tablename;

-- Vérification des politiques RLS
select 
  tablename,
  policyname,
  permissive,
  roles,
  cmd
from pg_policies
where schemaname = 'public'
order by tablename, policyname;
