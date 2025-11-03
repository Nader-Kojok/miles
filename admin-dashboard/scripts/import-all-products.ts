import { createClient } from '@supabase/supabase-js';
import { exportToJSON } from './parse-products-data';
import * as dotenv from 'dotenv';
import * as path from 'path';

// Load environment variables from .env.local
dotenv.config({ path: path.join(__dirname, '..', '.env.local'), override: true });

// Initialize Supabase client
const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

console.log('Environment check:');
console.log('- NEXT_PUBLIC_SUPABASE_URL:', supabaseUrl ? '✓ Found' : '✗ Missing');
console.log('- SUPABASE_SERVICE_ROLE_KEY:', supabaseServiceKey ? '✓ Found' : '✗ Missing');

if (!supabaseUrl || !supabaseServiceKey) {
  console.error('\n❌ Missing environment variables!');
  console.error('Please ensure NEXT_PUBLIC_SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are set in .env.local');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseServiceKey);

interface ProductImport {
  name: string;
  sku: string;
  price: number;
  category_slug: string;
  brand: string;
  stock_quantity: number;
  tags: string[];
  vehicle_model?: string;
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
 * Create missing categories
 */
async function ensureCategories(categories: Array<{ name: string; slug: string; icon?: string; description?: string }>) {
  console.log('📁 Ensuring categories exist...\n');
  
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
        description: category.description || null,
        is_active: true,
        display_order: 0,
      });

      if (error) {
        console.error(`❌ Error creating category ${category.name}:`, error.message);
      } else {
        console.log(`✅ Created category: ${category.name}`);
      }
    } else {
      console.log(`✓ Category ${category.name} already exists`);
    }
  }
  console.log('');
}

/**
 * Import products in bulk
 */
async function importProducts(products: ProductImport[]) {
  console.log(`\n🚀 Starting import of ${products.length} products...\n`);
  
  let successCount = 0;
  let errorCount = 0;
  let skippedCount = 0;
  let priceWarningCount = 0;
  const errors: Array<{ product: string; error: string }> = [];

  for (const product of products) {
    try {
      // Check for missing price
      if (product.price === 0) {
        priceWarningCount++;
      }

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
        .select('id, name')
        .eq('sku', product.sku)
        .single();

      if (existing) {
        console.log(`⚠️  Product ${product.sku} (${existing.name}) already exists, skipping...`);
        skippedCount++;
        continue;
      }

      // Prepare description with vehicle model
      const description = product.vehicle_model 
        ? `Compatible with ${product.vehicle_model}. OEM Part Number: ${product.sku}`
        : `OEM Part Number: ${product.sku}`;

      // Insert product
      const { error } = await supabase.from('products').insert({
        name: product.name,
        slug,
        sku: product.sku,
        price: product.price,
        category_id: categoryId,
        brand: product.brand,
        description,
        stock_quantity: product.stock_quantity,
        in_stock: product.stock_quantity > 0,
        is_featured: false,
        is_active: true,
        tags: product.tags,
      });

      if (error) {
        throw error;
      }

      successCount++;
      const priceWarning = product.price === 0 ? ' ⚠️ PRICE=0' : '';
      console.log(`✅ Imported: ${product.name} (${product.sku})${priceWarning}`);
    } catch (error: any) {
      errorCount++;
      const errorMsg = error.message || 'Unknown error';
      errors.push({ product: `${product.name} (${product.sku})`, error: errorMsg });
      console.error(`❌ Error importing ${product.name}:`, errorMsg);
    }
  }

  console.log('\n' + '='.repeat(60));
  console.log('📊 IMPORT SUMMARY');
  console.log('='.repeat(60));
  console.log(`✅ Successfully imported: ${successCount}`);
  console.log(`⏭️  Skipped (already exist): ${skippedCount}`);
  console.log(`❌ Errors: ${errorCount}`);
  if (priceWarningCount > 0) {
    console.log(`⚠️  Products with price = 0: ${priceWarningCount}`);
  }
  console.log('='.repeat(60));
  
  if (errors.length > 0) {
    console.log('\n❌ ERROR DETAILS:');
    errors.forEach(({ product, error }) => {
      console.log(`   - ${product}: ${error}`);
    });
  }

  if (priceWarningCount > 0) {
    console.log('\n⚠️  WARNING: Some products have price = 0');
    console.log('   Please update prices before activating these products!');
  }
}

/**
 * Main import function
 */
async function main() {
  console.log('╔════════════════════════════════════════════════════════╗');
  console.log('║       BOLIDE - BULK PRODUCT IMPORT TOOL               ║');
  console.log('╚════════════════════════════════════════════════════════╝\n');

  // Step 1: Ensure all required categories exist
  await ensureCategories([
    { name: 'Freinage', slug: 'freinage', icon: 'speed', description: 'Système de freinage complet' },
    { name: 'Suspension', slug: 'suspension', icon: 'settings', description: 'Amortisseurs et suspension' },
    { name: 'Filtration', slug: 'filtration', icon: 'filter_list', description: 'Filtres à huile, air et carburant' },
    { name: 'Moteur', slug: 'moteur', icon: 'build', description: 'Pièces moteur et transmission' },
    { name: 'Allumage', slug: 'allumage', icon: 'flash_on', description: 'Système d\'allumage' },
    { name: 'Refroidissement', slug: 'refroidissement', icon: 'ac_unit', description: 'Système de refroidissement' },
    { name: 'Courroie', slug: 'courroie', icon: 'settings', description: 'Courroies et accessoires' },
  ]);

  // Step 2: Load products from parsed data
  console.log('📦 Loading products data...\n');
  const products = exportToJSON();

  // Step 3: Import products
  await importProducts(products);

  console.log('\n✨ Import process completed!\n');
}

// Run the import
main()
  .then(() => {
    process.exit(0);
  })
  .catch((error) => {
    console.error('\n💥 Fatal error:', error);
    process.exit(1);
  });
