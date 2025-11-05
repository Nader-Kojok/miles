# Product Import Instructions

## ✅ Setup Complete

All scripts are ready to import **79 products** (44 Land Rover + 35 Toyota) into your database.

### What's Been Done

1. ✅ Created bulk import scripts
2. ✅ Parsed all products from your markdown file
3. ✅ Added dummy prices (8,000 - 450,000 FCFA range)
4. ✅ Set stock quantities (Land Rover has actual quantities, Toyota set to 15 each)
5. ✅ Organized products by vehicle model and category
6. ✅ Added npm script for easy import

### Before Running Import

You need to add your Supabase **Service Role Key** to `.env.local`:

1. Go to your Supabase Dashboard: https://uerwlrpatvumjdksfgbj.supabase.co
2. Navigate to **Settings** → **API**
3. Copy the **service_role** key (NOT the anon key)
4. Add it to `.env.local`:

```env
NEXT_PUBLIC_SUPABASE_URL=https://uerwlrpatvumjdksfgbj.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here
```

⚠️ **IMPORTANT**: The service role key bypasses RLS policies. Keep it secret!

### Run the Import

From the `admin-dashboard` directory:

```bash
npm run import:products
```

### What Will Happen

The script will:
1. ✅ Create missing categories (Freinage, Suspension, Filtration, etc.)
2. ✅ Check for duplicate SKUs (skips if exists)
3. ✅ Import all 79 products with:
   - Product name
   - SKU (OEM part number)
   - Dummy price (UPDATE THESE LATER!)
   - Category
   - Brand (Land Rover or Toyota)
   - Stock quantity
   - Vehicle model in description
   - Tags for filtering

### After Import

1. **Update Prices**: Go to admin dashboard → Products and update the dummy prices
2. **Add Images**: Upload product images
3. **Review Stock**: Verify stock quantities are correct
4. **Test**: Check that products appear correctly in the mobile app

### Products Summary

#### Land Rover Range Rover Sport 2014 V6 3.0 (44 products)
- Suspension: 16 items (shock absorbers, arms, links, bushings)
- Brake System: 10 items (discs, pads, warnings)
- Filtration: 5 items (oil, air, cabin filters)
- Cooling: 7 items (water pumps, cooler, thermostat)
- Ignition: 2 items (spark plugs, coils)
- Steering: 2 items (tie rods, end kits)
- Belts: 1 item (serpentine belt)

#### Toyota Products (35 products)
- **Prado LJ120L (2002-2009)**: 17 items
  - Belts, filters, brake system, ignition, injection pump
- **Prado GDJ150L (2023+)**: 9 items
  - Filters, brake system, ignition coil
- **LC200 (2010-2015)**: 9 items
  - Filters, brake system, glow plugs

### Dummy Price Ranges Applied

- **Filters**: 8,000 - 18,000 FCFA
- **Brakes**: 8,000 - 85,000 FCFA  
- **Suspension**: 15,000 - 150,000 FCFA
- **Cooling**: 22,000 - 180,000 FCFA
- **Ignition**: 6,000 - 35,000 FCFA
- **Belts**: 12,000 - 25,000 FCFA
- **Engine**: 350,000 - 450,000 FCFA

### Troubleshooting

**Error: "Category not found"**
- The script creates categories automatically
- Check that category slugs match

**Error: "duplicate key value"**
- Product with that SKU already exists
- Script will skip it automatically

**Products not showing in app**
- Verify `is_active` is `true`
- Check RLS policies allow reading products
- Ensure products have valid `category_id`

### Files Created

- `scripts/parse-products-data.ts` - Product data parser
- `scripts/import-all-products.ts` - Main import script
- `scripts/bulk-import-products.ts` - Generic import utility
- `scripts/fix-prices.ts` - Price updater (already run)

### Next Steps

1. Add service role key to `.env.local`
2. Run `npm run import:products`
3. Update prices via admin dashboard
4. Add product images
5. Test in mobile app

---

Need help? Check the console output for detailed error messages.
