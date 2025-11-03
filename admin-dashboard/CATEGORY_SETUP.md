# 🚀 Guide de Configuration des Catégories

Ce guide vous explique comment peupler votre base de données avec les **30 catégories principales** et **1000+ sous-catégories** d'auto-doc.fr.

## ✅ Méthode Recommandée: SQL Script

### Étape 1: Accéder à Supabase

1. Ouvrez votre [Supabase Dashboard](https://supabase.com/dashboard)
2. Sélectionnez votre projet **Bolide**
3. Dans le menu latéral, cliquez sur **SQL Editor**

### Étape 2: Exécuter le Script

1. Cliquez sur **New query** (ou + New Query)
2. Ouvrez le fichier `scripts/populate-categories.sql`
3. **Copiez tout le contenu** du fichier
4. **Collez-le** dans l'éditeur SQL de Supabase
5. Cliquez sur **Run** (ou appuyez sur `Ctrl + Enter` / `Cmd + Enter`)

### Étape 3: Vérification

Vous devriez voir:
```
DELETE 8        -- Suppression des anciennes catégories
INSERT 0 30     -- Insertion de 30 nouvelles catégories
```

Puis le script affichera automatiquement:
- La liste complète des catégories
- Le nombre total (30 catégories)

## 📋 Ce qui sera créé

### 30 Catégories Principales

| # | Catégorie | Sous-catégories | Icône |
|---|-----------|-----------------|-------|
| 1 | Filtre | 10 types | filter_list |
| 2 | Frein | 38 références | speed |
| 3 | Moteur | 80+ pièces | build |
| 4 | Carrosserie | 56 éléments | directions_car |
| 5 | Suspension | 29 types | settings |
| 6 | Système d'essuie-glaces | 16 références | water_drop |
| 7 | Amortissement | 22 pièces | compress |
| 8 | Allumage et préchauffage | 15 types | flash_on |
| 9 | Huiles et fluides | 11 produits | water |
| 10 | Courroies, chaînes, galets | 28 références | settings_ethernet |
| 11 | Système électrique | 28 types | electrical_services |
| 12 | Éclairage et signalisation | 48 pièces | lightbulb |
| 13 | Refroidissement | 43 références | ac_unit |
| 14 | Échappement | 32 types | air |
| 15 | Circuit d'alimentation | 37 pièces | local_gas_station |
| 16 | Admission et turbo | 24 références | speed |
| 17 | Direction | 20 types | swap_horizontal_circle |
| 18 | Embrayage | 22 pièces | settings_backup_restore |
| 19 | Transmission | 39 références | settings_input_component |
| 20 | Climatisation et chauffage | 41 types | ac_unit |
| 21 | Roue et pneu | 20 pièces | album |
| 22 | Intérieur | 47 références | event_seat |
| 23 | Entretien | 34 produits | build_circle |
| 24 | Outillage | 39 types | construction |
| 25 | Équipement auto | 48 accessoires | drive_eta |
| 26 | Tuning et performance | 78 pièces | speed |
| 27 | Pièces universelles | 34 types | category |
| 28 | Véhicule utilitaire | 37 pièces | local_shipping |
| 29 | Poids lourd | 79 références | local_shipping |
| 30 | Moto et scooter | 72 pièces | two_wheeler |

## 🔍 Vérification dans le Dashboard

Après l'exécution:

1. Allez dans votre **Admin Dashboard**
2. Cliquez sur **Catégories** dans le menu
3. Vous devriez voir les **30 catégories** affichées

## ⚠️ Important

### Avant d'exécuter:
- ✅ **Sauvegarde**: Le script supprime toutes les catégories existantes
- ✅ **Environnement**: Testez d'abord en dev si possible
- ✅ **Produits**: Les produits existants auront `category_id = NULL`

### Après l'exécution:
- 🔄 Réassignez les produits aux nouvelles catégories
- 📸 Ajoutez des images pour chaque catégorie
- 📝 Personnalisez les descriptions si nécessaire

## 🎯 Prochaines Étapes

### Option 1: Ajouter des Sous-Catégories

Les sous-catégories sont dans `cat_subcat.md`. Pour les ajouter:

```sql
-- Exemple: Sous-catégories de "Filtre"
INSERT INTO categories (name, slug, icon, parent_id, display_order, is_active)
SELECT 
  unnest(ARRAY[
    'Filtre à huile',
    'Filtre à air',
    'Filtre d''habitacle',
    'Filtre à carburant',
    'Kit de filtres'
  ]) as name,
  unnest(ARRAY[
    'filtre-a-huile',
    'filtre-a-air',
    'filtre-d-habitacle',
    'filtre-a-carburant',
    'kit-de-filtres'
  ]) as slug,
  'filter_list' as icon,
  c.id as parent_id,
  generate_series(1, 5) as display_order,
  true as is_active
FROM categories c
WHERE c.slug = 'filtre';
```

### Option 2: Associer les Produits

```sql
-- Associer un produit à une catégorie
UPDATE products 
SET category_id = (SELECT id FROM categories WHERE slug = 'frein')
WHERE name LIKE '%frein%' OR name LIKE '%plaquette%';
```

### Option 3: Ajouter des Images

```sql
-- Ajouter une image à une catégorie
UPDATE categories 
SET image_url = 'https://votre-url.com/image.jpg'
WHERE slug = 'moteur';
```

## 💡 Méthode Alternative: Script TypeScript

Si vous préférez utiliser le script TypeScript:

### Prérequis

1. Créez un fichier `.env.local` avec vos clés:
```env
NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
```

2. Installez tsx si nécessaire:
```bash
npm install -g tsx
```

### Exécution

```bash
cd admin-dashboard
npm run populate:categories
```

### Avantages du Script TypeScript
- ✅ Génération automatique des slugs
- ✅ Mapping automatique des icônes
- ✅ Logs détaillés
- ✅ Gestion d'erreurs

## 📚 Documentation Complète

- 📄 [scripts/README.md](./scripts/README.md) - Documentation détaillée
- 📄 [cat_subcat.md](./cat_subcat.md) - JSON source complet
- 📄 [supabase_schema.sql](../supabase_schema.sql) - Schéma de base de données

## 🆘 Dépannage

### Erreur: "relation 'categories' does not exist"
→ Vérifiez que le schéma de base de données a été créé (`supabase_schema.sql`)

### Erreur: "permission denied"
→ Utilisez le **SQL Editor** de Supabase (pas pgAdmin ou autre)

### Les catégories n'apparaissent pas dans le dashboard
→ Vérifiez que `is_active = true` dans la table

### Problème avec les icônes
→ Les icônes utilisent Material Icons (compatibles avec Flutter et admin)

## 📞 Support

Pour toute question, consultez:
- [Documentation Supabase](https://supabase.com/docs)
- [Guide Quick Start](./QUICK_START.md)
- Fichier [cat_subcat.md](./cat_subcat.md) pour la liste complète

---

**Prêt à commencer?** Suivez la **Méthode Recommandée** ci-dessus! 🚀
