import { createClient } from '@supabase/supabase-js';
import * as fs from 'fs';
import * as path from 'path';

// Initialize Supabase client
const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY!;

const supabase = createClient(supabaseUrl, supabaseServiceKey);

interface ProductImport {
  name: string;
  sku: string;
  price: number;
  category_slug: string;
  brand?: string;
  stock_quantity?: number;
  description?: string;
  compare_at_price?: number;
  is_featured?: boolean;
  tags?: string[];
}

/**
 * Generate a URL-friendly slug from a string
 */
function generateSlug(text: string): string {
  return text
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '') // Remove diacritics
    .replace(/[^a-z0-9]+/g, '-') // Replace non-alphanumeric with hyphens
    .replace(/^-+|-+$/g, ''); // Remove leading/trailing hyphens
}

/**
 * Get or create a category by slug
 */
async function getCategoryId(categorySlug: string): Promise<string | null> {
  const { data, error } = await supabase
    .from('categories')
    .select('id')
    .eq('slug', categorySlug)
    .single();

  if (error) {
    console.error(`Error fetching category ${categorySlug}:`, error.message);
    return null;
  }

  return data?.id || null;
}

/**
 * Import products in bulk
 */
async function importProducts(products: ProductImport[]) {
  console.log(`Starting import of ${products.length} products...`);
  
  let successCount = 0;
  let errorCount = 0;
  const errors: Array<{ product: string; error: string }> = [];

  for (const product of products) {
    try {
      // Get category ID
      const categoryId = await getCategoryId(product.category_slug);
      
      if (!categoryId) {
        throw new Error(`Category not found: ${product.category_slug}`);
      }

      // Generate slug from name + SKU to ensure uniqueness
      const slug = generateSlug(`${product.name}-${product.sku}`);

      // Check if product with this SKU already exists
      const { data: existing } = await supabase
        .from('products')
        .select('id')
        .eq('sku', product.sku)
        .single();

      if (existing) {
        console.log(`⚠️  Product ${product.sku} already exists, skipping...`);
        continue;
      }

      // Insert product
      const { error } = await supabase.from('products').insert({
        name: product.name,
        slug,
        sku: product.sku,
        price: product.price,
        compare_at_price: product.compare_at_price || null,
        category_id: categoryId,
        brand: product.brand || null,
        description: product.description || null,
        stock_quantity: product.stock_quantity || 0,
        in_stock: (product.stock_quantity || 0) > 0,
        is_featured: product.is_featured || false,
        is_active: true,
        tags: product.tags || [],
      });

      if (error) {
        throw error;
      }

      successCount++;
      console.log(`✅ Imported: ${product.name} (${product.sku})`);
    } catch (error: any) {
      errorCount++;
      const errorMsg = error.message || 'Unknown error';
      errors.push({ product: `${product.name} (${product.sku})`, error: errorMsg });
      console.error(`❌ Error importing ${product.name}:`, errorMsg);
    }
  }

  console.log('\n=== Import Summary ===');
  console.log(`✅ Successfully imported: ${successCount}`);
  console.log(`❌ Errors: ${errorCount}`);
  
  if (errors.length > 0) {
    console.log('\n=== Errors Details ===');
    errors.forEach(({ product, error }) => {
      console.log(`- ${product}: ${error}`);
    });
  }
}

/**
 * Create missing categories
 */
async function ensureCategories(categories: Array<{ name: string; slug: string; icon?: string }>) {
  console.log('Ensuring categories exist...');
  
  for (const category of categories) {
    const { data: existing } = await supabase
      .from('categories')
      .select('id')
      .eq('slug', category.slug)
      .single();

    if (!existing) {
      const { error } = await supabase.from('categories').insert({
        name: category.name,
        slug: category.slug,
        icon: category.icon || 'category',
        is_active: true,
      });

      if (error) {
        console.error(`Error creating category ${category.name}:`, error.message);
      } else {
        console.log(`✅ Created category: ${category.name}`);
      }
    } else {
      console.log(`Category ${category.name} already exists`);
    }
  }
}

// Example usage
async function main() {
  // First, ensure all required categories exist
  await ensureCategories([
    { name: 'Freinage', slug: 'freinage', icon: 'speed' },
    { name: 'Suspension', slug: 'suspension', icon: 'settings' },
    { name: 'Filtration', slug: 'filtration', icon: 'filter_list' },
    { name: 'Moteur', slug: 'moteur', icon: 'build' },
    { name: 'Allumage', slug: 'allumage', icon: 'flash_on' },
    { name: 'Refroidissement', slug: 'refroidissement', icon: 'ac_unit' },
    { name: 'Courroie', slug: 'courroie', icon: 'settings' },
  ]);

  // Example products - YOU NEED TO FILL IN THE PRICES
  const products: ProductImport[] = [
    // Land Rover Range Rover Sport 2014 V6 3.0
    {
      name: 'Shock Absorber RH',
      sku: 'LR060154',
      price: 0, // ⚠️ PRICE NEEDED
      category_slug: 'suspension',
      brand: 'Land Rover',
      stock_quantity: 6,
      tags: ['land-rover', 'range-rover-sport', 'suspension'],
    },
    {
      name: 'Shock Absorber LH',
      sku: 'LR060155',
      price: 0, // ⚠️ PRICE NEEDED
      category_slug: 'suspension',
      brand: 'Land Rover',
      stock_quantity: 6,
      tags: ['land-rover', 'range-rover-sport', 'suspension'],
    },
    {
      name: 'Front Brake Disc',
      sku: 'LR016176',
      price: 0, // ⚠️ PRICE NEEDED
      category_slug: 'freinage',
      brand: 'Land Rover',
      stock_quantity: 8,
      tags: ['land-rover', 'range-rover-sport', 'brake'],
    },
    {
      name: 'Front Brake Pads',
      sku: 'LR020362',
      price: 0, // ⚠️ PRICE NEEDED
      category_slug: 'freinage',
      brand: 'Land Rover',
      stock_quantity: 25,
      tags: ['land-rover', 'range-rover-sport', 'brake'],
    },
    // Add more products here...
  ];

  await importProducts(products);
}

// Run the import
main()
  .then(() => {
    console.log('\n✅ Import completed');
    process.exit(0);
  })
  .catch((error) => {
    console.error('\n❌ Import failed:', error);
    process.exit(1);
  });
