-- =============================================
-- Admin RLS Policies for Bolide Admin Dashboard (FIXED)
-- Execute this in Supabase SQL Editor
-- =============================================

-- IMPORTANT: First, drop any existing admin policies that might cause recursion
DROP POLICY IF EXISTS "Admins can view all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Admins can view all products" ON public.products;
DROP POLICY IF EXISTS "Admins can insert products" ON public.products;
DROP POLICY IF EXISTS "Admins can update products" ON public.products;
DROP POLICY IF EXISTS "Admins can delete products" ON public.products;
DROP POLICY IF EXISTS "Admins can view all categories" ON public.categories;
DROP POLICY IF EXISTS "Admins can insert categories" ON public.categories;
DROP POLICY IF EXISTS "Admins can update categories" ON public.categories;
DROP POLICY IF EXISTS "Admins can delete categories" ON public.categories;
DROP POLICY IF EXISTS "Admins can view all orders" ON public.orders;
DROP POLICY IF EXISTS "Admins can update orders" ON public.orders;
DROP POLICY IF EXISTS "Admins can view all promo codes" ON public.promo_codes;
DROP POLICY IF EXISTS "Admins can insert promo codes" ON public.promo_codes;
DROP POLICY IF EXISTS "Admins can update promo codes" ON public.promo_codes;
DROP POLICY IF EXISTS "Admins can delete promo codes" ON public.promo_codes;

-- =============================================
-- SOLUTION: Create a helper function to check admin status
-- This avoids recursion by using SECURITY DEFINER
-- =============================================

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

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.is_admin() TO authenticated;

-- =============================================
-- ADMIN POLICIES FOR PRODUCTS
-- =============================================

CREATE POLICY "Admins can view all products"
  ON public.products FOR SELECT
  TO authenticated
  USING (public.is_admin());

CREATE POLICY "Admins can insert products"
  ON public.products FOR INSERT
  TO authenticated
  WITH CHECK (public.is_admin());

CREATE POLICY "Admins can update products"
  ON public.products FOR UPDATE
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

CREATE POLICY "Admins can delete products"
  ON public.products FOR DELETE
  TO authenticated
  USING (public.is_admin());

-- =============================================
-- ADMIN POLICIES FOR CATEGORIES
-- =============================================

CREATE POLICY "Admins can view all categories"
  ON public.categories FOR SELECT
  TO authenticated
  USING (public.is_admin());

CREATE POLICY "Admins can insert categories"
  ON public.categories FOR INSERT
  TO authenticated
  WITH CHECK (public.is_admin());

CREATE POLICY "Admins can update categories"
  ON public.categories FOR UPDATE
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

CREATE POLICY "Admins can delete categories"
  ON public.categories FOR DELETE
  TO authenticated
  USING (public.is_admin());

-- =============================================
-- ADMIN POLICIES FOR ORDERS
-- =============================================

CREATE POLICY "Admins can view all orders"
  ON public.orders FOR SELECT
  TO authenticated
  USING (public.is_admin());

CREATE POLICY "Admins can update orders"
  ON public.orders FOR UPDATE
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- =============================================
-- ADMIN POLICIES FOR PROFILES (NO RECURSION)
-- =============================================

-- Admins can view all profiles
-- Note: This uses the function which has SECURITY DEFINER to avoid recursion
CREATE POLICY "Admins can view all profiles"
  ON public.profiles FOR SELECT
  TO authenticated
  USING (public.is_admin());

-- =============================================
-- ADMIN POLICIES FOR PROMO CODES
-- =============================================

CREATE POLICY "Admins can view all promo codes"
  ON public.promo_codes FOR SELECT
  TO authenticated
  USING (public.is_admin());

CREATE POLICY "Admins can insert promo codes"
  ON public.promo_codes FOR INSERT
  TO authenticated
  WITH CHECK (public.is_admin());

CREATE POLICY "Admins can update promo codes"
  ON public.promo_codes FOR UPDATE
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

CREATE POLICY "Admins can delete promo codes"
  ON public.promo_codes FOR DELETE
  TO authenticated
  USING (public.is_admin());

-- =============================================
-- ADMIN POLICIES FOR ORDER ITEMS (if needed)
-- =============================================

CREATE POLICY "Admins can view all order items"
  ON public.order_items FOR SELECT
  TO authenticated
  USING (public.is_admin());

-- =============================================
-- VERIFICATION
-- =============================================

-- Test the is_admin function
SELECT public.is_admin() AS am_i_admin;

-- Check all admin policies
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd
FROM pg_policies
WHERE schemaname = 'public'
  AND policyname LIKE '%Admin%'
ORDER BY tablename, policyname;

-- Verify your admin status
SELECT id, phone, full_name, is_admin 
FROM public.profiles 
WHERE id = auth.uid();
