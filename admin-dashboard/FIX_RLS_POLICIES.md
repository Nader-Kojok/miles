# Fix RLS Policies for Admin Dashboard

## Problem
You're getting this error when trying to create/edit products:
```
new row violates row-level security policy for table "products"
```

## Root Cause
The database has RLS (Row-Level Security) enabled, but there are **no policies allowing admins to insert/update/delete** products, categories, or other resources. The existing policies only allow:
- Public users to **view** active products/categories
- Users to manage their own orders/favorites/addresses

## Solution

### Step 1: Execute the Admin RLS Policies

1. Open your **Supabase Dashboard**
2. Go to **SQL Editor**
3. Open the file `admin_rls_policies.sql` (in this directory)
4. Copy and paste the entire SQL script
5. Click **Run** to execute

This will create policies that allow users with `is_admin = true` to:
- ✅ View all products (including inactive ones)
- ✅ Insert new products
- ✅ Update existing products
- ✅ Delete products
- ✅ Same permissions for categories, orders, promo codes, etc.

### Step 2: Verify Your Admin Status

After running the script, verify you're an admin by running this query:

```sql
SELECT id, phone, full_name, is_admin 
FROM public.profiles 
WHERE email = 'your-email@example.com';
```

If `is_admin` is `false` or `NULL`, set it to `true`:

```sql
UPDATE public.profiles 
SET is_admin = true 
WHERE email = 'your-email@example.com';
```

### Step 3: Test

1. Refresh your admin dashboard
2. Try creating a new product
3. Try editing an existing product
4. Should work now! ✅

## What the Policies Do

The policies use this pattern:
```sql
EXISTS (
  SELECT 1 FROM public.profiles
  WHERE profiles.id = auth.uid()
  AND profiles.is_admin = true
)
```

This checks if the currently authenticated user has `is_admin = true` in their profile. If yes, they get full CRUD access.

## Security Note

These policies are **secure** because:
1. They only apply to authenticated users
2. They check the `is_admin` flag in the database (not client-side)
3. The `is_admin` column can only be set via SQL (not through the app)
4. Regular users still have restricted access

## Troubleshooting

If it still doesn't work:

1. **Check if policies were created:**
   ```sql
   SELECT tablename, policyname 
   FROM pg_policies 
   WHERE schemaname = 'public' 
   AND policyname LIKE '%Admin%';
   ```

2. **Check your admin status:**
   ```sql
   SELECT is_admin FROM public.profiles WHERE id = auth.uid();
   ```

3. **Check RLS is enabled:**
   ```sql
   SELECT tablename, rowsecurity 
   FROM pg_tables 
   WHERE schemaname = 'public';
   ```

All tables should have `rowsecurity = true`.
