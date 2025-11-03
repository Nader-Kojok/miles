# 🚀 Quick Start Guide - Bolide Admin Dashboard

## ✅ Fixed Issues

### Image Configuration Error ✅
**Fixed**: Configured Next.js to allow external images from:
- `images.unsplash.com` (for demo product images)
- `*.supabase.co` (for future Supabase Storage uploads)

The error is now resolved in `next.config.ts`.

### Admin Access Control ✅
**Fixed**: Only authorized admin users can now access the dashboard. Regular users are redirected to an unauthorized page.

## 🎯 Getting Started (5 minutes)

### Step 1: Create Admin User

1. Go to [Supabase Dashboard](https://supabase.com/dashboard/project/uerwlrpatvumjdksfgbj)
2. Click **Authentication** → **Users**
3. Click **Add user** → **Create new user**
4. Enter:
   - **Email**: `admin@bolide.sn` (or your email)
   - **Password**: Create a strong password
5. Click **Create user**
6. **IMPORTANT**: Grant admin access by running this SQL in Supabase SQL Editor:
   ```sql
   UPDATE profiles 
   SET is_admin = true 
   WHERE email = 'admin@bolide.sn';
   ```
   
   > **Note**: `naderkojok@gmail.com` is already set as admin.

### Step 2: Start the Dashboard

The dev server should already be running at:
```
http://localhost:3000
```

If not, run:
```bash
cd admin-dashboard
npm run dev
```

### Step 3: Login

1. Open http://localhost:3000
2. You'll be redirected to `/login`
3. Enter your admin credentials
4. You're in! 🎉

## 📦 What You Can Do Now

### 1. **Products Management**
Navigate to **Products** in the sidebar:
- ✅ View all existing products from your database
- ✅ Click **Nouveau produit** to add new products
- ✅ Edit products by clicking the pencil icon
- ✅ Delete products (with confirmation)
- ✅ Toggle product status (active/inactive)
- ✅ Manage stock, prices, categories

### 2. **Orders Management**
Navigate to **Commandes**:
- ✅ View all customer orders
- ✅ Update order status via dropdown
- ✅ Track payment status
- ✅ See customer details

### 3. **Users Management**
Navigate to **Utilisateurs**:
- ✅ View all registered users
- ✅ See registration dates
- ✅ View user contact info

### 4. **Promo Codes**
Navigate to **Codes promo**:
- ✅ Create discount codes
- ✅ Set percentage or fixed amount discounts
- ✅ Add conditions (min purchase, usage limits)
- ✅ Set validity periods
- ✅ Copy codes to clipboard
- ✅ Toggle active/inactive

### 5. **Categories**
Navigate to **Catégories**:
- ✅ View all product categories
- ✅ Manage display order
- ✅ Delete categories

## 🔑 Key Features Available

| Feature | Status | Location |
|---------|--------|----------|
| Dashboard Analytics | ✅ Ready | `/dashboard` |
| Product CRUD | ✅ Ready | `/dashboard/products` |
| Order Management | ✅ Ready | `/dashboard/orders` |
| User Management | ✅ Ready | `/dashboard/users` |
| Category Management | ✅ Ready | `/dashboard/categories` |
| Promo Codes | ✅ Ready | `/dashboard/promo-codes` |
| Notifications | ✅ Ready | `/dashboard/notifications` |
| Settings | ✅ Ready | `/dashboard/settings` |

## 📱 Test on Mobile

The dashboard is fully responsive. Try it on your phone:
1. Find your computer's local IP (shown when you run `npm run dev`)
2. Open `http://YOUR_IP:3000` on your phone
3. Login and test!

## 🔄 Sync with Mobile App

Everything you do here syncs with your Flutter mobile app:

**When you add a product:**
1. Add it in the dashboard
2. Click "Créer le produit"
3. It immediately appears in your mobile app!

**When a user places an order:**
1. They order from the mobile app
2. The order shows up in your dashboard instantly
3. You can update the status from here

## 🎨 Customization

### Change Colors
Edit `app/globals.css`:
```css
:root {
  --primary: 222.2 47.4% 11.2%; /* Change this */
}
```

### Add New Pages
1. Create file: `app/dashboard/my-page/page.tsx`
2. Add route to `components/sidebar.tsx`
3. Done!

## 🚀 Deploy to Production

### Option 1: Vercel (Recommended)
```bash
# Push to GitHub first
git add .
git commit -m "Add admin dashboard"
git push

# Then on Vercel:
# 1. Import your repository
# 2. Set root directory to "admin-dashboard"
# 3. Add environment variables
# 4. Deploy!
```

### Option 2: Netlify
```bash
cd admin-dashboard
npm run build
# Upload .next folder to Netlify
```

## 📊 Performance Tips

1. **Images**: Always use the Next.js `<Image>` component
2. **Data**: Large lists are automatically optimized
3. **Caching**: Server components cache automatically
4. **Loading**: Add loading states for better UX

## 🆘 Troubleshooting

### Issue: "Cannot find module" errors in IDE
**Solution**: These are TypeScript cache issues. The code works fine. Restart your IDE or run:
```bash
npm run dev
```

### Issue: Images not showing
**Solution**: Check that the image URL is from an allowed domain in `next.config.ts`

### Issue: Can't login
**Solution**: 
1. Verify your Supabase credentials in `.env.local`
2. Make sure you created a user in Supabase Auth
3. Check browser console for errors

### Issue: Changes not reflecting
**Solution**: 
1. Save all files
2. Wait for Next.js to rebuild (watch terminal)
3. Hard refresh browser (Cmd+Shift+R / Ctrl+Shift+F5)

## 📚 Next Steps

1. ✅ **Add real products** with actual data
2. ✅ **Test order flow** from mobile to dashboard
3. ✅ **Create promo codes** for your first customers
4. ✅ **Customize branding** (colors, logo)
5. ✅ **Deploy to production**
6. ⏭️ **Add image upload** (Supabase Storage)
7. ⏭️ **Add analytics charts** (Recharts)
8. ⏭️ **Export reports** (CSV/Excel)

## 💡 Pro Tips

1. **Keyboard Shortcuts**: Most forms support Enter to submit
2. **Bulk Operations**: Select multiple items to delete (coming soon)
3. **Search**: Use browser's Cmd+F to search tables
4. **Mobile**: Dashboard works great on tablets for on-the-go management
5. **Backup**: Export your data regularly

## 📞 Support

For issues:
1. Check the browser console (F12)
2. Check the terminal where `npm run dev` is running
3. Review `FEATURES.md` for complete feature list
4. Check `README.md` for detailed documentation

---

**You're all set!** 🎉

Start managing your Bolide e-commerce store now at http://localhost:3000
