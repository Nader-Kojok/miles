/**
 * Quick script to add dummy prices to all products with price: 0
 * Run this before importing
 */

import * as fs from 'fs';
import * as path from 'path';

const filePath = path.join(__dirname, 'parse-products-data.ts');
let content = fs.readFileSync(filePath, 'utf-8');

// Replace all remaining price: 0 with reasonable dummy prices based on product type
const replacements = [
  // Belts
  { pattern: /price: 0,.*'courroie'/g, replacement: "price: 15000, category_slug: 'courroie'" },
  // Filters
  { pattern: /price: 0,.*'filtration'/g, replacement: "price: 10000, category_slug: 'filtration'" },
  // Brakes
  { pattern: /price: 0,.*'freinage'/g, replacement: "price: 40000, category_slug: 'freinage'" },
  // Ignition
  { pattern: /price: 0,.*'allumage'/g, replacement: "price: 25000, category_slug: 'allumage'" },
  // Engine
  { pattern: /price: 0,.*'moteur'/g, replacement: "price: 350000, category_slug: 'moteur'" },
];

for (const { pattern, replacement } of replacements) {
  content = content.replace(pattern, replacement);
}

// Catch any remaining price: 0
content = content.replace(/price: 0,/g, 'price: 25000,');

fs.writeFileSync(filePath, content, 'utf-8');

console.log('✅ All prices updated with dummy values!');
console.log('⚠️  Remember to update these prices via the admin dashboard later.');
