# 🔐 Admin Access Management

## Overview

The admin dashboard now has proper role-based access control. Only users with `is_admin = true` in their profile can access the dashboard.

## Security Layers

### 1. **Middleware Protection** (`middleware.ts`)
- Checks authentication status
- Verifies admin role before allowing dashboard access
- Redirects non-admin users to `/unauthorized`

### 2. **Server-Side Layout Check** (`app/dashboard/layout.tsx`)
- Additional server-side verification
- Prevents unauthorized access even if middleware is bypassed
- Uses `isAdmin()` utility function

### 3. **Database Column** (`profiles.is_admin`)
- Boolean field in profiles table
- Defaults to `false` for all new users
- Indexed for fast lookups

## Managing Admin Users

### Grant Admin Access

To make a user an admin, run this SQL in Supabase SQL Editor:

```sql
-- Replace with the user's email
UPDATE profiles 
SET is_admin = true 
WHERE email = 'user@example.com';
```

Or by user ID:

```sql
-- Replace with the user's ID
UPDATE profiles 
SET is_admin = true 
WHERE id = 'user-uuid-here';
```

### Revoke Admin Access

```sql
-- Remove admin privileges
UPDATE profiles 
SET is_admin = false 
WHERE email = 'user@example.com';
```

### List All Admins

```sql
SELECT id, email, full_name, created_at 
FROM profiles 
WHERE is_admin = true 
ORDER BY created_at;
```

### List All Non-Admin Users

```sql
SELECT id, email, full_name, created_at 
FROM profiles 
WHERE is_admin = false 
ORDER BY created_at;
```

## Current Admin Users

✅ **naderkojok@gmail.com** (Nader) - Set as admin on initial setup

## How It Works

1. **User registers/logs in** → Supabase Auth creates user
2. **Profile created** → `is_admin` defaults to `false`
3. **User tries to access dashboard** → Middleware checks `is_admin`
4. **If not admin** → Redirected to `/unauthorized` page
5. **If admin** → Full dashboard access granted

## Unauthorized Page

Non-admin users see a friendly error page at `/unauthorized` explaining:
- They don't have admin permissions
- Only administrators can access the dashboard
- How to contact an administrator

## Testing

### Test as Admin
1. Login with an admin account (naderkojok@gmail.com)
2. Should access dashboard normally

### Test as Regular User
1. Create a new user in Supabase Auth
2. Login with that account
3. Should be redirected to `/unauthorized`

## Security Best Practices

✅ **Multi-layer protection**: Middleware + Server-side checks
✅ **Database-driven**: Admin status stored securely in database
✅ **No client-side bypass**: All checks happen server-side
✅ **Indexed queries**: Fast admin lookups with database index
✅ **Clear error messages**: Users know why they can't access

## Troubleshooting

### Issue: Admin user can't access dashboard

**Solution**: Verify admin status in database:
```sql
SELECT email, is_admin FROM profiles WHERE email = 'admin@example.com';
```

If `is_admin` is `false`, update it:
```sql
UPDATE profiles SET is_admin = true WHERE email = 'admin@example.com';
```

### Issue: Regular user sees dashboard briefly before redirect

**Solution**: This is normal - the middleware redirect happens after initial page load. The server-side check in the layout prevents any actual data access.

### Issue: Need to make first user admin

**Solution**: Use Supabase SQL Editor:
```sql
-- Make the first registered user an admin
UPDATE profiles 
SET is_admin = true 
WHERE id = (SELECT id FROM profiles ORDER BY created_at ASC LIMIT 1);
```

## Migration History

- **add_is_admin_to_profiles**: Added `is_admin` column with default `false`
- Created index on `is_admin` for performance
- Set initial admin user (naderkojok@gmail.com)

## API Endpoints

The admin check utilities are available in `lib/supabase/server.ts`:

```typescript
// Check if current user is admin
const userIsAdmin = await isAdmin()

// Get current user's profile (includes is_admin)
const profile = await getUserProfile()
```

## Future Enhancements

Consider adding:
- [ ] Admin user management UI in dashboard
- [ ] Role-based permissions (super admin, editor, viewer)
- [ ] Audit log for admin actions
- [ ] Email notifications when admin status changes
- [ ] Two-factor authentication for admin accounts
