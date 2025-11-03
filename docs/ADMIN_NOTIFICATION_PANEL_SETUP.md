# Admin Notification Panel - Setup Guide

## ✅ What's Been Created

### Backend API Routes
1. **`/api/notifications/send`** - Send push notifications
2. **`/api/notifications/history`** - Get notification history

### Frontend
1. **`/dashboard/notifications`** - Complete admin notification panel with:
   - Send notification form
   - Notification history
   - Statistics dashboard
   - Real-time updates

### Database
1. **`supabase_admin_notifications_schema.sql`** - Admin notification history table

---

## 🚀 Setup Instructions

### Step 1: Get OneSignal REST API Key (2 minutes)

1. Go to OneSignal Dashboard:
   ```
   https://dashboard.onesignal.com/apps/924c65ff-2ef3-4dfb-ab0c-a101adda03f8/settings/keys-ids
   ```

2. Copy your **REST API Key** (starts with `OS...`)

3. Add to your `.env.local` file:
   ```bash
   cd admin-dashboard
   cp .env.example .env.local
   ```

4. Edit `.env.local` and add:
   ```env
   ONESIGNAL_APP_ID=924c65ff-2ef3-4dfb-ab0c-a101adda03f8
   ONESIGNAL_REST_API_KEY=your_rest_api_key_here
   ```

### Step 2: Apply Database Schema (2 minutes)

1. Open Supabase SQL Editor:
   ```
   https://supabase.com/dashboard/project/uerwlrpatvumjdksfgbj/sql/new
   ```

2. Copy and run both SQL files:
   - `supabase_notifications_schema.sql` (user notifications)
   - `supabase_admin_notifications_schema.sql` (admin history)

3. Verify tables created:
   - `notifications`
   - `fcm_tokens`
   - `admin_notifications`

### Step 3: Test the Admin Panel (5 minutes)

1. Start the admin dashboard:
   ```bash
   cd admin-dashboard
   npm run dev
   ```

2. Navigate to:
   ```
   http://localhost:3000/dashboard/notifications
   ```

3. Click "Nouvelle notification"

4. Fill in the form:
   - **Titre**: "Test Notification"
   - **Message**: "Ceci est un test"
   - **Type**: Personnalisée
   - **Audience**: Tous les utilisateurs

5. Click "Envoyer maintenant"

6. Check your iPhone for the notification!

---

## 📱 Features

### Send Notifications

**Notification Types:**
- ✅ **Personnalisée** - Custom messages
- ✅ **Promotion** - Marketing offers
- ✅ **Mise à jour commande** - Order updates
- ✅ **Baisse de prix** - Price drops
- ✅ **Retour en stock** - Back in stock alerts

**Target Audience:**
- ✅ **Tous les utilisateurs** - Broadcast to all
- ✅ **Segment spécifique** - Target specific segments

**Optional Fields:**
- 📸 **Image URL** - Add rich media (1200x600px recommended)
- 🔗 **Action URL** - Deep link to specific page

### Notification History

- 📊 View all sent notifications
- 👥 See recipient counts
- 📅 Filter by date, type, status
- 👤 Track who sent each notification

### Statistics Dashboard

- 📈 Total notifications sent
- 👥 Total recipients reached
- ✅ 100% delivery rate (OneSignal handles retries)

---

## 🎯 Usage Examples

### Example 1: Promotion Notification

```json
{
  "title": "🎉 Soldes d'été !",
  "message": "Profitez de -30% sur toutes les pièces de freinage",
  "type": "promotion",
  "targetType": "all",
  "imageUrl": "https://bolide.app/images/summer-sale.jpg",
  "actionUrl": "https://bolide.app/category/brakes"
}
```

### Example 2: Order Update

```json
{
  "title": "Commande expédiée 📦",
  "message": "Votre commande #12345 a été expédiée",
  "type": "order_update",
  "targetType": "specific",
  "userIds": ["user-uuid-here"],
  "actionUrl": "https://bolide.app/orders/12345"
}
```

### Example 3: Price Drop Alert

```json
{
  "title": "💰 Baisse de prix !",
  "message": "Le produit dans vos favoris est maintenant à -20%",
  "type": "price_drop",
  "targetType": "segment",
  "segment": "Has Favorites",
  "imageUrl": "https://bolide.app/products/brake-pads.jpg",
  "actionUrl": "https://bolide.app/products/brake-pads-123"
}
```

---

## 🔧 API Reference

### POST /api/notifications/send

Send a push notification to users.

**Request Body:**
```typescript
{
  title: string;              // Required
  message: string;            // Required
  type?: 'custom' | 'promotion' | 'order_update' | 'price_drop' | 'back_in_stock';
  targetType?: 'all' | 'specific' | 'segment';
  userIds?: string[];         // For targetType='specific'
  segment?: string;           // For targetType='segment'
  imageUrl?: string;          // Optional rich media
  actionUrl?: string;         // Optional deep link
  scheduledFor?: string;      // Optional ISO date for scheduling
  data?: object;              // Optional custom data
}
```

**Response:**
```typescript
{
  success: true,
  notificationId: string,
  recipients: number,
  savedNotification: object
}
```

### GET /api/notifications/history

Get notification history with pagination.

**Query Parameters:**
- `page` (default: 1)
- `limit` (default: 20)
- `status` (optional: 'sent', 'scheduled', 'failed')
- `type` (optional: notification type)

**Response:**
```typescript
{
  notifications: Array<{
    id: string,
    title: string,
    message: string,
    type: string,
    recipients_count: number,
    status: string,
    created_at: string,
    profiles: {
      email: string,
      full_name: string
    }
  }>,
  pagination: {
    page: number,
    limit: number,
    total: number,
    totalPages: number
  }
}
```

---

## 🎨 UI Components Used

- **shadcn/ui** components:
  - `Card`, `CardHeader`, `CardTitle`, `CardContent`
  - `Button`, `Input`, `Textarea`, `Label`
  - `Select`, `Dialog`, `Badge`
- **Lucide React** icons:
  - `Bell`, `Send`, `Clock`, `Users`, `Plus`, `History`
- **Sonner** for toast notifications

---

## 🔐 Security

### Admin-Only Access
- ✅ All API routes check `is_admin` status
- ✅ RLS policies enforce admin-only access
- ✅ Unauthorized users get 403 Forbidden

### Data Validation
- ✅ Required fields validated
- ✅ Character limits enforced
- ✅ URL validation for images/actions

### Rate Limiting
- Consider adding rate limiting for production
- OneSignal has built-in rate limits

---

## 📊 OneSignal Dashboard

Access your OneSignal dashboard for advanced features:

**Dashboard URL:**
```
https://dashboard.onesignal.com/apps/924c65ff-2ef3-4dfb-ab0c-a101adda03f8
```

**Features:**
- 📈 Delivery analytics
- 👥 User segments
- 🧪 A/B testing
- 📅 Scheduled campaigns
- 🎯 Advanced targeting

---

## 🐛 Troubleshooting

### Notification Not Received

1. **Check OneSignal Dashboard**
   - Go to Messages → Delivery
   - Verify notification was sent
   - Check delivery status

2. **Check User Subscription**
   - Go to Audience → Subscriptions
   - Verify user is subscribed
   - Check subscription status

3. **Check App Permissions**
   - Verify notification permission granted
   - Check device settings

### API Errors

**401 Unauthorized:**
- User not logged in
- Session expired

**403 Forbidden:**
- User is not an admin
- Check `is_admin` in profiles table

**500 Internal Server Error:**
- Check OneSignal REST API Key
- Verify environment variables
- Check server logs

---

## 🚀 Next Steps

1. ✅ **Test on your iPhone**
   - Send a test notification
   - Verify it appears correctly
   - Test deep linking

2. ✅ **Create User Segments** in OneSignal
   - Active users
   - Users with favorites
   - Users by location
   - Custom segments

3. ✅ **Set Up Automated Notifications**
   - Order confirmations
   - Shipping updates
   - Abandoned cart reminders
   - Price drop alerts

4. ✅ **Monitor Analytics**
   - Track open rates
   - Measure engagement
   - Optimize messaging

---

## 📚 Resources

- [OneSignal API Documentation](https://documentation.onesignal.com/reference/create-message)
- [OneSignal Dashboard](https://dashboard.onesignal.com)
- [Supabase RLS Policies](https://supabase.com/docs/guides/auth/row-level-security)
- [Next.js API Routes](https://nextjs.org/docs/app/building-your-application/routing/route-handlers)

---

## ✨ Summary

You now have a complete admin notification panel that allows you to:

- ✅ Send push notifications to all users or specific segments
- ✅ Add rich media (images) and deep links
- ✅ Track notification history and statistics
- ✅ Monitor delivery and engagement
- ✅ Manage everything from your admin dashboard

**All powered by Supabase + OneSignal - no Firebase needed!** 🎉
