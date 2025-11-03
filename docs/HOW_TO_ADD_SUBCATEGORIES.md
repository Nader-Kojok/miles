# How to Add Subcategories

## Understanding the Category Structure

Your admin dashboard supports a two-level category hierarchy:
- **Parent Categories** (e.g., "Outillage", "Moteur", "Freinage")
- **Subcategories** (children of parent categories)

## Current Situation

Looking at your screenshot, you have "Outillage" as a parent category, but no subcategories have been created for it yet.

## How to Create Subcategories

### Method 1: Using the Admin Dashboard (Recommended)

1. Go to **Dashboard → Categories**
2. Click **"Nouvelle catégorie"** button
3. Fill in the form:
   - **Nom**: Name of the subcategory (e.g., "Clés à molette")
   - **Slug**: URL-friendly version (e.g., "cles-a-molette")
   - **Icône**: Material icon name (optional)
   - **Catégorie parente**: Select "Outillage" from the dropdown
   - **Ordre d'affichage**: Number for sorting
   - **Statut**: Check "Actif"
4. Click **Save**

### Method 2: Using SQL (For Bulk Creation)

If you want to create multiple subcategories at once, you can run SQL:

```sql
-- Example: Add subcategories for "Outillage"
INSERT INTO public.categories (name, slug, icon, parent_id, display_order, is_active)
SELECT 
  unnest(ARRAY[
    'Clés à molette',
    'Tournevis',
    'Pinces',
    'Marteaux',
    'Crics'
  ]) as name,
  unnest(ARRAY[
    'cles-a-molette',
    'tournevis',
    'pinces',
    'marteaux',
    'crics'
  ]) as slug,
  'build' as icon,
  c.id as parent_id,
  generate_series(1, 5) as display_order,
  true as is_active
FROM categories c
WHERE c.name = 'Outillage' AND c.parent_id IS NULL;
```

## Viewing Subcategories

Once you've created subcategories:

1. Go to **Dashboard → Categories**
2. Find the parent category (e.g., "Outillage")
3. Click the **chevron/arrow icon** next to it to expand
4. You'll see all subcategories listed underneath

## Important Notes

### Products Can Only Be Linked to Parent Categories

As per your request, we've configured the system so that:
- ✅ Products can ONLY be assigned to **parent categories**
- ❌ Products CANNOT be assigned to **subcategories**

This means:
- When creating/editing a product, the category dropdown will only show parent categories
- Subcategories are for organizational purposes in the categories management page
- They help you organize your category structure but don't directly link to products

### Example Structure

```
Outillage (Parent - can be assigned to products)
  ├─ Clés à molette (Subcategory - organizational only)
  ├─ Tournevis (Subcategory - organizational only)
  └─ Pinces (Subcategory - organizational only)

Moteur (Parent - can be assigned to products)
  ├─ Bouchon de vidange (Subcategory - organizational only)
  ├─ Filtre à huile (Subcategory - organizational only)
  └─ Joint de culasse (Subcategory - organizational only)
```

## Pre-populated Subcategories

The file `admin-dashboard/subcategories_migration.sql` contains hundreds of pre-defined subcategories for common auto parts categories like:
- Filtre (10 subcategories)
- Frein (38 subcategories)
- Moteur (77 subcategories)
- Carrosserie (55 subcategories)
- And many more...

To use these, you would need to:
1. Ensure the parent categories exist with the correct slugs
2. Run the migration SQL in your Supabase SQL Editor

However, since you're using "Outillage" which is not in the default set, you'll need to create its subcategories manually using Method 1 or Method 2 above.
