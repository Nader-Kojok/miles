# Fix: Infinite Recursion in RLS Policies

## Problem
```
infinite recursion detected in policy for relation "profiles"
```

## Root Cause
The admin policies were checking the `profiles` table **while being applied TO the profiles table**, creating infinite recursion:

```sql
-- ❌ BAD: This causes recursion
CREATE POLICY "Admins can view all profiles"
  ON public.profiles FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles  -- ← Checking profiles FROM profiles = recursion!
      WHERE profiles.id = auth.uid()
      AND profiles.is_admin = true
    )
  );
```

## Solution: Use SECURITY DEFINER Function

Instead of inline queries, we use a **helper function** with `SECURITY DEFINER` that bypasses RLS:

```sql
-- ✅ GOOD: Function with SECURITY DEFINER
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid()
    AND is_admin = true
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

Then use the function in policies:
```sql
-- ✅ GOOD: No recursion
CREATE POLICY "Admins can view all profiles"
  ON public.profiles FOR SELECT
  TO authenticated
  USING (public.is_admin());
```

## How to Fix

### Step 1: Use the Fixed SQL File

1. **Ignore** the previous `admin_rls_policies.sql`
2. **Use** `admin_rls_policies_fixed.sql` instead
3. Open **Supabase Dashboard** → **SQL Editor**
4. Copy and paste the **entire** `admin_rls_policies_fixed.sql`
5. Click **Run**

### Step 2: Verify It Works

Run this to test:
```sql
SELECT public.is_admin() AS am_i_admin;
```

Should return `true` if you're an admin, `false` otherwise.

### Step 3: Set Yourself as Admin (if needed)

```sql
UPDATE public.profiles 
SET is_admin = true 
WHERE email = 'your-email@example.com';
```

### Step 4: Test in Dashboard

1. Refresh your admin dashboard
2. Try creating/editing a product
3. Should work now! ✅

## Why This Works

### The Problem with Direct Queries
```
Policy on profiles → Checks profiles table → Triggers policy → Checks profiles table → ∞
```

### The Solution with SECURITY DEFINER
```
Policy → Calls is_admin() function → Function bypasses RLS → Returns true/false → ✅
```

The `SECURITY DEFINER` keyword makes the function run with the **privileges of the function owner** (superuser), bypassing RLS and avoiding recursion.

## What the Fixed Script Does

1. **Drops** any existing admin policies (clean slate)
2. **Creates** the `is_admin()` helper function
3. **Creates** all admin policies using the function
4. **Grants** execute permission to authenticated users
5. **Verifies** everything works

## Security

This is still **secure** because:
- ✅ Function only checks `is_admin` flag (read-only)
- ✅ Can't modify data through the function
- ✅ `is_admin` can only be set via SQL (not through app)
- ✅ Function is deterministic and simple
- ✅ All checks happen server-side

## Troubleshooting

If you still get errors:

1. **Check if function exists:**
   ```sql
   SELECT routine_name 
   FROM information_schema.routines 
   WHERE routine_name = 'is_admin';
   ```

2. **Test the function directly:**
   ```sql
   SELECT public.is_admin();
   ```

3. **Check policies are using the function:**
   ```sql
   SELECT tablename, policyname, qual 
   FROM pg_policies 
   WHERE schemaname = 'public' 
   AND qual LIKE '%is_admin()%';
   ```

4. **If all else fails, disable RLS temporarily (NOT for production):**
   ```sql
   ALTER TABLE public.products DISABLE ROW LEVEL SECURITY;
   ```
   Then re-enable after fixing:
   ```sql
   ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
   ```
