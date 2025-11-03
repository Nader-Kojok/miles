/**
 * Parser for the products data from add_products.md
 * This script will help you prepare the data for import
 */

interface ParsedProduct {
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
 * Parse Land Rover products
 * Note: Using dummy prices (50000-200000 FCFA range) - UPDATE THESE LATER
 */
function parseLandRoverProducts(): ParsedProduct[] {
  const products: ParsedProduct[] = [
    // Shock Absorbers
    { name: 'Shock Absorber RH', sku: 'LR060154', price: 150000, category_slug: 'suspension', brand: 'Land Rover', stock_quantity: 6, tags: ['land-rover', 'range-rover-sport-2014', 'suspension'], vehicle_model: 'Range Rover Sport 2014 V6 3.0' },
    { name: 'Shock Absorber LH', sku: 'LR060155', price: 150000, category_slug: 'suspension', brand: 'Land Rover', stock_quantity: 6, tags: ['land-rover', 'range-rover-sport-2014', 'suspension'], vehicle_model: 'Range Rover Sport 2014 V6 3.0' },
    { name: 'Rear Shock Absorber', sku: 'LR047322', price: 150000, category_slug: 'suspension', brand: 'Land Rover', stock_quantity: 12, tags: ['land-rover', 'range-rover-sport-2014', 'suspension'], vehicle_model: 'Range Rover Sport 2014 V6 3.0' },
    
    // Brake System
    { name: 'Front Brake Disc', sku: 'LR016176', price: 85000, category_slug: 'freinage', brand: 'Land Rover', stock_quantity: 8, tags: ['land-rover', 'range-rover-sport-2014', 'brake'], vehicle_model: 'Range Rover Sport 2014 V6 3.0' },
    { name: 'Front Brake Pads', sku: 'LR020362', price: 45000, category_slug: 'freinage', brand: 'Land Rover', stock_quantity: 25, tags: ['land-rover', 'range-rover-sport-2014', 'brake'], vehicle_model: 'Range Rover Sport 2014 V6 3.0' },
    { name: 'Brake Pads Wear Warning', sku: 'LR033275', price: 8000, category_slug: 'freinage', brand: 'Land Rover', stock_quantity: 12, tags: ['land-rover', 'range-rover-sport-2014', 'brake'], vehicle_model: 'Range Rover Sport 2014 V6 3.0' },
    { name: 'Rear Brake Pads', sku: 'LR065492', price: 45000, category_slug: 'freinage', brand: 'Land Rover', stock_quantity: 15, tags: ['land-rover', 'range-rover-sport-2014', 'brake'], vehicle_model: 'Range Rover Sport 2014 V6 3.0' },
    { name: 'Rear Brake Disc', sku: 'LR033303', price: 85000, category_slug: 'freinage', brand: 'Land Rover', stock_quantity: 8, tags: ['land-rover', 'range-rover-sport-2014', 'brake'], vehicle_model: 'Range Rover Sport 2014 V6 3.0' },
    { name: 'Rear Brake Wear Warning', sku: 'LR033295', price: 8000, category_slug: 'freinage', brand: 'Land Rover', stock_quantity: 12, tags: ['land-rover', 'range-rover-sport-2014', 'brake'], vehicle_model: 'Range Rover Sport 2014 V6 3.0' },
    { name: 'Brake Pads, Rear', sku: 'LR036574', price: 45000, category_slug: 'freinage', brand: 'Land Rover', stock_quantity: 15, tags: ['land-rover', 'range-rover-sport-2014', 'brake'], vehicle_model: 'Range Rover Sport 2014 V6 3.0' },
    { name: 'Brake Disc, Rear', sku: 'LR033302', price: 85000, category_slug: 'freinage', brand: 'Land Rover', stock_quantity: 8, tags: ['land-rover', 'range-rover-sport-2014', 'brake'], vehicle_model: 'Range Rover Sport 2014 V6 3.0' },
    
    // Suspension Links & Arms
    { name: 'Suspension Link, Front', sku: 'LR035489', price: 35000, category_slug: 'suspension', brand: 'Land Rover', stock_quantity: 20, tags: ['land-rover', 'range-rover-sport-2014', 'suspension'], vehicle_model: 'Range Rover Sport 2014 V6 3.0' },
    { name: 'Stabilizer Bar Bush', sku: 'LR043584', price: 15000, category_slug: 'suspension', brand: 'Land Rover', stock_quantity: 20, tags: ['land-rover', 'range-rover-sport-2014', 'suspension'], vehicle_model: 'Range Rover Sport 2014 V6 3.0' },
    { name: 'Rear Suspension Link', sku: 'LR042975', price: 35000, category_slug: 'suspension', brand: 'Land Rover', stock_quantity: 12, tags: ['land-rover', 'range-rover-sport-2014', 'suspension'], vehicle_model: 'Range Rover Sport 2014 V6 3.0' },
    { name: 'Rear Suspension Link', sku: 'LR042976', price: 35000, category_slug: 'suspension', brand: 'Land Rover', stock_quantity: 12, tags: ['land-rover', 'range-rover-sport-2014', 'suspension'], vehicle_model: 'Range Rover Sport 2014 V6 3.0' },
    { name: 'Front Suspension Arm', sku: 'LR044841', price: 65000, category_slug: 'suspension', brand: 'Land Rover', stock_quantity: 4, tags: ['land-rover', 'range-rover-sport-2014', 'suspension'], vehicle_model: 'Range Rover Sport 2014 V6 3.0' },
    { name: 'Front Suspension Arm', sku: 'LR044844', price: 65000, category_slug: 'suspension', brand: 'Land Rover', stock_quantity: 4, tags: ['land-rover', 'range-rover-sport-2014', 'suspension'], vehicle_model: 'Range Rover Sport 2014 V6 3.0' },
    { name: 'Front Suspension Arm', sku: 'LR045243', price: 65000, category_slug: 'suspension', brand: 'Land Rover', stock_quantity: 4, tags: ['land-rover', 'range-rover-sport-2014', 'suspension'], vehicle_model: 'Range Rover Sport 2014 V6 3.0' },
    { name: 'Front Suspension Arm', sku: 'LR045242', price: 65000, category_slug: 'suspension', brand: 'Land Rover', stock_quantity: 4, tags: ['land-rover', 'range-rover-sport-2014', 'suspension'], vehicle_model: 'Range Rover Sport 2014 V6 3.0' },
    { name: 'Front Suspension Arm', sku: 'LR034219', price: 65000, category_slug: 'suspension', brand: 'Land Rover', stock_quantity: 4, tags: ['land-rover', 'range-rover-sport-2014', 'suspension'], vehicle_model: 'Range Rover Sport 2014 V6 3.0' },
    { name: 'Front Suspension Arm', sku: 'LR034220', price: 65000, category_slug: 'suspension', brand: 'Land Rover', stock_quantity: 4, tags: ['land-rover', 'range-rover-sport-2014', 'suspension'], vehicle_model: 'Range Rover Sport 2014 V6 3.0' },
    { name: 'Front Wheel Bearing', sku: 'LR024267', price: 45000, category_slug: 'suspension', brand: 'Land Rover', stock_quantity: 8, tags: ['land-rover', 'range-rover-sport-2014', 'suspension'], vehicle_model: 'Range Rover Sport 2014 V6 3.0' },
    { name: 'Rear Stabilizer Bar Bushing', sku: 'LR048462', price: 15000, category_slug: 'suspension', brand: 'Land Rover', stock_quantity: 20, tags: ['land-rover', 'range-rover-sport-2014', 'suspension'], vehicle_model: 'Range Rover Sport 2014 V6 3.0' },
    { name: 'Rear Suspension', sku: 'LR037690', price: 120000, category_slug: 'suspension', brand: 'Land Rover', stock_quantity: 8, tags: ['land-rover', 'range-rover-sport-2014', 'suspension'], vehicle_model: 'Range Rover Sport 2014 V6 3.0' },
    
    // Steering
    { name: 'End Kit', sku: 'LR033534', price: 25000, category_slug: 'suspension', brand: 'Land Rover', stock_quantity: 8, tags: ['land-rover', 'range-rover-sport-2014', 'steering'], vehicle_model: 'Range Rover Sport 2014 V6 3.0' },
    { name: 'Tie Rod', sku: 'LR033529', price: 30000, category_slug: 'suspension', brand: 'Land Rover', stock_quantity: 8, tags: ['land-rover', 'range-rover-sport-2014', 'steering'], vehicle_model: 'Range Rover Sport 2014 V6 3.0' },
    
    // Filtration
    { name: 'Oil Filter', sku: 'LR013148', price: 12000, category_slug: 'filtration', brand: 'Land Rover', stock_quantity: 40, tags: ['land-rover', 'range-rover-sport-2014', 'filter'], vehicle_model: 'Range Rover Sport 2014 V6 3.0' },
    { name: 'Oil Filter & Cooler', sku: 'LR022895', price: 95000, category_slug: 'filtration', brand: 'Land Rover', stock_quantity: 20, tags: ['land-rover', 'range-rover-sport-2014', 'filter'], vehicle_model: 'Range Rover Sport 2014 V6 3.0' },
    { name: 'Oil Filter', sku: 'LR011279', price: 12000, category_slug: 'filtration', brand: 'Land Rover', stock_quantity: 40, tags: ['land-rover', 'range-rover-sport-2014', 'filter'], vehicle_model: 'Range Rover Sport 2014 V6 3.0' },
    { name: 'Oil Filter', sku: 'LR025306', price: 12000, category_slug: 'filtration', brand: 'Land Rover', stock_quantity: 40, tags: ['land-rover', 'range-rover-sport-2014', 'filter'], vehicle_model: 'Range Rover Sport 2014 V6 3.0' },
    { name: 'Oil Cooler', sku: 'LR025515', price: 180000, category_slug: 'refroidissement', brand: 'Land Rover', stock_quantity: 3, tags: ['land-rover', 'range-rover-sport-2014', 'cooling'], vehicle_model: 'Range Rover Sport 2014 V6 3.0' },
    { name: 'Air Filter Element', sku: 'LR011593', price: 18000, category_slug: 'filtration', brand: 'Land Rover', stock_quantity: 25, tags: ['land-rover', 'range-rover-sport-2014', 'filter'], vehicle_model: 'Range Rover Sport 2014 V6 3.0' },
    { name: 'Cabin Air Filter', sku: 'LR161566', price: 15000, category_slug: 'filtration', brand: 'Land Rover', stock_quantity: 24, tags: ['land-rover', 'range-rover-sport-2014', 'filter'], vehicle_model: 'Range Rover Sport 2014 V6 3.0' },
    
    // Engine & Cooling
    { name: 'Water Pump', sku: 'LR013164', price: 120000, category_slug: 'refroidissement', brand: 'Land Rover', stock_quantity: 4, tags: ['land-rover', 'range-rover-sport-2014', 'cooling'], vehicle_model: 'Range Rover Sport 2014 V6 3.0' },
    { name: 'Water Pump', sku: 'LR033993', price: 120000, category_slug: 'refroidissement', brand: 'Land Rover', stock_quantity: 4, tags: ['land-rover', 'range-rover-sport-2014', 'cooling'], vehicle_model: 'Range Rover Sport 2014 V6 3.0' },
    { name: 'Water Pump Secondary', sku: 'LR048856', price: 85000, category_slug: 'refroidissement', brand: 'Land Rover', stock_quantity: 4, tags: ['land-rover', 'range-rover-sport-2014', 'cooling'], vehicle_model: 'Range Rover Sport 2014 V6 3.0' },
    { name: 'Water Pump Secondary', sku: 'LR067228', price: 85000, category_slug: 'refroidissement', brand: 'Land Rover', stock_quantity: 4, tags: ['land-rover', 'range-rover-sport-2014', 'cooling'], vehicle_model: 'Range Rover Sport 2014 V6 3.0' },
    { name: 'Serpentine Belt', sku: 'LR035543', price: 25000, category_slug: 'courroie', brand: 'Land Rover', stock_quantity: 20, tags: ['land-rover', 'range-rover-sport-2014', 'belt'], vehicle_model: 'Range Rover Sport 2014 V6 3.0' },
    { name: 'Thermostat', sku: 'LR032124', price: 22000, category_slug: 'refroidissement', brand: 'Land Rover', stock_quantity: 3, tags: ['land-rover', 'range-rover-sport-2014', 'cooling'], vehicle_model: 'Range Rover Sport 2014 V6 3.0' },
    
    // Ignition
    { name: 'Spark Plug', sku: 'LR050998', price: 6000, category_slug: 'allumage', brand: 'Land Rover', stock_quantity: 60, tags: ['land-rover', 'range-rover-sport-2014', 'ignition'], vehicle_model: 'Range Rover Sport 2014 V6 3.0' },
    { name: 'Ignition Coil', sku: 'LR035548', price: 35000, category_slug: 'allumage', brand: 'Land Rover', stock_quantity: 12, tags: ['land-rover', 'range-rover-sport-2014', 'ignition'], vehicle_model: 'Range Rover Sport 2014 V6 3.0' },
  ];

  return products;
}

/**
 * Parse Toyota products
 * Note: Toyota products have multiple OEM numbers - using the first one as SKU
 * Using dummy prices (8000-50000 FCFA) and stock quantities (10-25) - UPDATE LATER
 */
function parseToyotaProducts(): ParsedProduct[] {
  const products: ParsedProduct[] = [
    // Toyota Prado LJ120L (2002-2009)
    // Belts
    { name: 'V-Belt (Cooler Compressor to Crankshaft Pulley) No.1', sku: '9933211210', price: 15000, category_slug: 'courroie', brand: 'Toyota', stock_quantity: 15, tags: ['toyota', 'prado-lj120l', 'belt'], vehicle_model: 'Toyota Prado LJ120L (2002-2009)' },
    { name: 'V-Belt (For Fan & Alternator)', sku: '9008092016', price: 15000, category_slug: 'courroie', brand: 'Toyota', stock_quantity: 15, tags: ['toyota', 'prado-lj120l', 'belt'], vehicle_model: 'Toyota Prado LJ120L (2002-2009)' },
    { name: 'V-Belt (For Fan & Alternator)', sku: '9008092017', price: 15000, category_slug: 'courroie', brand: 'Toyota', stock_quantity: 15, tags: ['toyota', 'prado-lj120l', 'belt'], vehicle_model: 'Toyota Prado LJ120L (2002-2009)' },
    { name: 'V-Belt', sku: '9091602211', price: 15000, category_slug: 'courroie', brand: 'Toyota', stock_quantity: 15, tags: ['toyota', 'prado-lj120l', 'belt'], vehicle_model: 'Toyota Prado LJ120L (2002-2009)' },
    
    // Filtration - Prado LJ120L
    { name: 'Oil Filter', sku: '1560041010', price: 10000, category_slug: 'filtration', brand: 'Toyota', stock_quantity: 15, tags: ['toyota', 'prado-lj120l', 'filter'], vehicle_model: 'Toyota Prado LJ120L (2002-2009)' },
    { name: 'Air Filter', sku: '1780130040', price: 10000, category_slug: 'filtration', brand: 'Toyota', stock_quantity: 15, tags: ['toyota', 'prado-lj120l', 'filter'], vehicle_model: 'Toyota Prado LJ120L (2002-2009)' },
    { name: 'Fuel Filter', sku: '2339030180', price: 10000, category_slug: 'filtration', brand: 'Toyota', stock_quantity: 15, tags: ['toyota', 'prado-lj120l', 'filter'], vehicle_model: 'Toyota Prado LJ120L (2002-2009)' },
    { name: 'Cabin Filter', sku: '8713932010', price: 10000, category_slug: 'filtration', brand: 'Toyota', stock_quantity: 15, tags: ['toyota', 'prado-lj120l', 'filter'], vehicle_model: 'Toyota Prado LJ120L (2002-2009)' },
    
    // Brake System - Prado LJ120L
    { name: 'Brake Pad Front', sku: '446535290', price: 40000, category_slug: 'freinage', brand: 'Toyota', stock_quantity: 15, tags: ['toyota', 'prado-lj120l', 'brake'], vehicle_model: 'Toyota Prado LJ120L (2002-2009)' },
    { name: 'Brake Pad Rear', sku: '446660090', price: 40000, category_slug: 'freinage', brand: 'Toyota', stock_quantity: 15, tags: ['toyota', 'prado-lj120l', 'brake'], vehicle_model: 'Toyota Prado LJ120L (2002-2009)' },
    { name: 'Brake Disc Rear', sku: '4243160201', price: 40000, category_slug: 'freinage', brand: 'Toyota', stock_quantity: 15, tags: ['toyota', 'prado-lj120l', 'brake'], vehicle_model: 'Toyota Prado LJ120L (2002-2009)' },
    { name: 'Brake Disc Front', sku: '4351260151', price: 40000, category_slug: 'freinage', brand: 'Toyota', stock_quantity: 15, tags: ['toyota', 'prado-lj120l', 'brake'], vehicle_model: 'Toyota Prado LJ120L (2002-2009)' },
    { name: 'Switch Assy, Parking Brake', sku: '8455016060', price: 40000, category_slug: 'freinage', brand: 'Toyota', stock_quantity: 15, tags: ['toyota', 'prado-lj120l', 'brake'], vehicle_model: 'Toyota Prado LJ120L (2002-2009)' },
    { name: 'Pump Assy, Vacuum', sku: '2930054150', price: 40000, category_slug: 'freinage', brand: 'Toyota', stock_quantity: 15, tags: ['toyota', 'prado-lj120l', 'brake'], vehicle_model: 'Toyota Prado LJ120L (2002-2009)' },
    { name: 'Cylinder Sub-Assy, Brake Master w/Plate', sku: '4702860020', price: 40000, category_slug: 'freinage', brand: 'Toyota', stock_quantity: 15, tags: ['toyota', 'prado-lj120l', 'brake'], vehicle_model: 'Toyota Prado LJ120L (2002-2009)' },
    
    // Ignition - Prado LJ120L
    { name: 'Plug Assy, Glow', sku: '1985054140', price: 25000, category_slug: 'allumage', brand: 'Toyota', stock_quantity: 15, tags: ['toyota', 'prado-lj120l', 'ignition'], vehicle_model: 'Toyota Prado LJ120L (2002-2009)' },
    { name: 'Pump Assy, Injection or Supply', sku: '221005D180', price: 350000, category_slug: 'moteur', brand: 'Toyota', stock_quantity: 15, tags: ['toyota', 'prado-lj120l', 'engine'], vehicle_model: 'Toyota Prado LJ120L (2002-2009)' },
    
    // Toyota Prado GDJ150L (2023+)
    // Filtration
    { name: 'Oil Filter', sku: '9091520005', price: 10000, category_slug: 'filtration', brand: 'Toyota', stock_quantity: 15, tags: ['toyota', 'prado-gdj150l', 'filter'], vehicle_model: 'Toyota Prado GDJ150L (2023+)' },
    { name: 'Air Filter', sku: '1780111130', price: 10000, category_slug: 'filtration', brand: 'Toyota', stock_quantity: 15, tags: ['toyota', 'prado-gdj150l', 'filter'], vehicle_model: 'Toyota Prado GDJ150L (2023+)' },
    { name: 'Fuel Filter', sku: '2339036760', price: 10000, category_slug: 'filtration', brand: 'Toyota', stock_quantity: 15, tags: ['toyota', 'prado-gdj150l', 'filter'], vehicle_model: 'Toyota Prado GDJ150L (2023+)' },
    { name: 'Cabin Filter', sku: '8713950100', price: 10000, category_slug: 'filtration', brand: 'Toyota', stock_quantity: 15, tags: ['toyota', 'prado-gdj150l', 'filter'], vehicle_model: 'Toyota Prado GDJ150L (2023+)' },
    
    // Brake System - Prado GDJ150L
    { name: 'Brake Pad Front', sku: '0446560320', price: 40000, category_slug: 'freinage', brand: 'Toyota', stock_quantity: 15, tags: ['toyota', 'prado-gdj150l', 'brake'], vehicle_model: 'Toyota Prado GDJ150L (2023+)' },
    { name: 'Brake Pad Rear', sku: '0446660140', price: 40000, category_slug: 'freinage', brand: 'Toyota', stock_quantity: 15, tags: ['toyota', 'prado-gdj150l', 'brake'], vehicle_model: 'Toyota Prado GDJ150L (2023+)' },
    { name: 'Brake Disc Rear', sku: '4243160311', price: 40000, category_slug: 'freinage', brand: 'Toyota', stock_quantity: 15, tags: ['toyota', 'prado-gdj150l', 'brake'], vehicle_model: 'Toyota Prado GDJ150L (2023+)' },
    { name: 'Brake Disc Front', sku: '4351260191', price: 40000, category_slug: 'freinage', brand: 'Toyota', stock_quantity: 15, tags: ['toyota', 'prado-gdj150l', 'brake'], vehicle_model: 'Toyota Prado GDJ150L (2023+)' },
    
    // Toyota LC200 (2010-2015)
    // Filtration
    { name: 'Oil Filter', sku: '415238020', price: 10000, category_slug: 'filtration', brand: 'Toyota', stock_quantity: 15, tags: ['toyota', 'lc200', 'filter'], vehicle_model: 'Toyota LC200 (2010-2015)' },
    { name: 'Air Filter', sku: '1780151020', price: 10000, category_slug: 'filtration', brand: 'Toyota', stock_quantity: 15, tags: ['toyota', 'lc200', 'filter'], vehicle_model: 'Toyota LC200 (2010-2015)' },
    { name: 'Fuel Filter', sku: '2339051020', price: 10000, category_slug: 'filtration', brand: 'Toyota', stock_quantity: 15, tags: ['toyota', 'lc200', 'filter'], vehicle_model: 'Toyota LC200 (2010-2015)' },
    { name: 'Cabin Filter', sku: '8713930040', price: 10000, category_slug: 'filtration', brand: 'Toyota', stock_quantity: 15, tags: ['toyota', 'lc200', 'filter'], vehicle_model: 'Toyota LC200 (2010-2015)' },
    
    // Brake System - LC200
    { name: 'Brake Pad Front', sku: '0446560280', price: 40000, category_slug: 'freinage', brand: 'Toyota', stock_quantity: 15, tags: ['toyota', 'lc200', 'brake'], vehicle_model: 'Toyota LC200 (2010-2015)' },
    { name: 'Brake Pad Rear', sku: '0446660120', price: 40000, category_slug: 'freinage', brand: 'Toyota', stock_quantity: 15, tags: ['toyota', 'lc200', 'brake'], vehicle_model: 'Toyota LC200 (2010-2015)' },
    { name: 'Brake Disc Rear', sku: '4243160290', price: 40000, category_slug: 'freinage', brand: 'Toyota', stock_quantity: 15, tags: ['toyota', 'lc200', 'brake'], vehicle_model: 'Toyota LC200 (2010-2015)' },
    { name: 'Brake Disc Front', sku: '4351260180', price: 40000, category_slug: 'freinage', brand: 'Toyota', stock_quantity: 15, tags: ['toyota', 'lc200', 'brake'], vehicle_model: 'Toyota LC200 (2010-2015)' },
    { name: 'Ignition Coil', sku: '1985011040', price: 25000, category_slug: 'allumage', brand: 'Toyota', stock_quantity: 15, tags: ['toyota', 'prado-gdj150l', 'ignition'], vehicle_model: 'Toyota Prado GDJ150L (2023+)' },
    { name: 'Plug Assy, Glow', sku: '1985026010', price: 25000, category_slug: 'allumage', brand: 'Toyota', stock_quantity: 15, tags: ['toyota', 'lc200', 'ignition'], vehicle_model: 'Toyota LC200 (2010-2015)' },
  ];

  return products;
}

/**
 * Export all products to JSON
 */
function exportToJSON() {
  const landRoverProducts = parseLandRoverProducts();
  const toyotaProducts = parseToyotaProducts();
  
  const allProducts = [...landRoverProducts, ...toyotaProducts];
  
  console.log('=== Products Summary ===');
  console.log(`Total products: ${allProducts.length}`);
  console.log(`Land Rover products: ${landRoverProducts.length}`);
  console.log(`Toyota products: ${toyotaProducts.length}`);
  console.log('\n⚠️  WARNING: All prices are set to 0 - YOU MUST UPDATE THEM!');
  console.log('⚠️  WARNING: Toyota products have stock_quantity = 0 - UPDATE IF NEEDED!');
  
  return allProducts;
}

// Export for use in bulk import
export { exportToJSON, parseLandRoverProducts, parseToyotaProducts };

// If run directly
if (require.main === module) {
  const products = exportToJSON();
  console.log('\n=== Sample Products ===');
  console.log(JSON.stringify(products.slice(0, 3), null, 2));
}
