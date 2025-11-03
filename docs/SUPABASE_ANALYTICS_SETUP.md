# Supabase Analytics Setup Guide

## Overview
The Bolide app uses **Supabase** (your existing stack) for analytics tracking instead of Firebase. All analytics events are stored directly in your Supabase database.

---

## 📋 Database Setup

### 1. Run the Migration

Apply the analytics tables migration to your Supabase database:

```bash
# Using Supabase CLI
supabase migration up

# Or manually in Supabase Dashboard:
# 1. Go to SQL Editor
# 2. Copy contents of supabase/migrations/create_analytics_tables.sql
# 3. Run the SQL
```

### 2. Tables Created

**`analytics_events`** - Stores all tracked events
- `id` - Unique event identifier
- `event_name` - Event type (e.g., 'product_view', 'add_to_cart')
- `event_params` - JSON parameters for the event
- `user_id` - User who triggered the event (nullable for anonymous)
- `timestamp` - When the event occurred
- `platform` - Platform (android, ios, web, etc.)

**`analytics_user_properties`** - Stores user properties
- `id` - Unique identifier
- `user_id` - User reference
- `property_name` - Property key
- `property_value` - Property value
- `updated_at` - Last updated timestamp

**`analytics_dashboard`** - View for analytics insights
- Pre-aggregated data for dashboard queries
- Event counts, unique users, parameter breakdown

---

## 🚀 Usage

### Tracking Events

The analytics service is already integrated in your app:

```dart
import 'package:bolide/services/analytics_service.dart';

// Track product view
await Analytics.instance.trackProductView(
  product.id,
  product.name,
);

// Track add to cart
await Analytics.instance.trackAddToCart(
  product.id,
  product.name,
  product.price,
  quantity,
);

// Track search
await Analytics.instance.trackSearch(
  searchQuery,
  resultCount,
);

// Track purchase
await Analytics.instance.trackOrderCompleted(
  orderId,
  totalAmount,
  itemCount,
);
```

### Available Events

All events are automatically tracked to your Supabase database:

- `screen_view` - Screen navigation
- `product_view` - Product page visits
- `add_to_cart` - Items added to cart
- `remove_from_cart` - Items removed from cart
- `search` - Search queries
- `category_view` - Category page visits
- `begin_checkout` - Checkout started
- `purchase` - Order completed
- `sign_up` - User registration
- `login` - User login
- `favorite_added` - Item added to favorites
- `favorite_removed` - Item removed from favorites
- `app_error` - Error occurrences

---

## 📊 Viewing Analytics Data

### Using Supabase Dashboard

1. Go to **Table Editor** in Supabase Dashboard
2. Select `analytics_events` table
3. Filter by `event_name`, `user_id`, or date range
4. View event parameters in JSONB format

### Using SQL Queries

```sql
-- Most popular products (last 7 days)
SELECT 
  event_params->>'product_name' as product,
  COUNT(*) as views
FROM analytics_events
WHERE event_name = 'product_view'
  AND timestamp > NOW() - INTERVAL '7 days'
GROUP BY event_params->>'product_name'
ORDER BY views DESC
LIMIT 10;

-- Conversion funnel
SELECT 
  event_name,
  COUNT(*) as count,
  COUNT(DISTINCT user_id) as unique_users
FROM analytics_events
WHERE event_name IN ('product_view', 'add_to_cart', 'begin_checkout', 'purchase')
  AND timestamp > NOW() - INTERVAL '30 days'
GROUP BY event_name
ORDER BY 
  CASE event_name
    WHEN 'product_view' THEN 1
    WHEN 'add_to_cart' THEN 2
    WHEN 'begin_checkout' THEN 3
    WHEN 'purchase' THEN 4
  END;

-- Search analytics
SELECT 
  event_params->>'search_term' as search_term,
  AVG((event_params->>'result_count')::int) as avg_results,
  COUNT(*) as search_count
FROM analytics_events
WHERE event_name = 'search'
  AND timestamp > NOW() - INTERVAL '7 days'
GROUP BY event_params->>'search_term'
ORDER BY search_count DESC
LIMIT 20;

-- Daily active users
SELECT 
  DATE(timestamp) as date,
  COUNT(DISTINCT user_id) as daily_active_users
FROM analytics_events
WHERE timestamp > NOW() - INTERVAL '30 days'
GROUP BY DATE(timestamp)
ORDER BY date DESC;
```

### Using the Analytics Dashboard View

```sql
-- Event summary for last 30 days
SELECT *
FROM analytics_dashboard
WHERE event_date > NOW() - INTERVAL '30 days'
ORDER BY event_date DESC, event_count DESC;
```

---

## 🔐 Security

### Row Level Security (RLS)

RLS policies are automatically created:

- **Users can insert their own events** - Authenticated users can track their own analytics
- **Users can view their own events** - Users can see their own analytics data
- **Admins can view all events** - Admin users can access all analytics (requires `role = 'admin'` in profiles table)

### Anonymous Events

Events from non-authenticated users are stored with `user_id = NULL` and are visible to everyone (for aggregate analytics).

---

## 📈 Building Analytics Dashboards

### Option 1: Supabase Dashboard
Use the built-in Table Editor and SQL Editor for quick insights.

### Option 2: Custom Dashboard
Build a custom analytics dashboard in your admin panel:

```dart
// Fetch analytics data
final response = await Supabase.instance.client
  .from('analytics_events')
  .select()
  .eq('event_name', 'product_view')
  .gte('timestamp', DateTime.now().subtract(Duration(days: 7)).toIso8601String());

// Process and display data
```

### Option 3: External Tools
Export data to tools like:
- Google Data Studio
- Metabase
- Grafana
- Custom BI tools

---

## 🎯 Best Practices

### 1. Event Naming Convention
Use consistent, descriptive names:
- ✅ `product_view`, `add_to_cart`, `purchase`
- ❌ `view`, `click`, `buy`

### 2. Event Parameters
Keep parameters consistent and typed:
```dart
{
  'product_id': 'string',
  'product_name': 'string',
  'price': double,
  'quantity': int,
}
```

### 3. Privacy
- Don't track sensitive data (passwords, credit cards, etc.)
- Follow GDPR/privacy laws
- Allow users to opt-out if required

### 4. Data Retention
Set up automatic cleanup for old data:

```sql
-- Delete events older than 1 year
DELETE FROM analytics_events
WHERE timestamp < NOW() - INTERVAL '1 year';

-- Or create a scheduled job in Supabase
```

---

## 🔧 Configuration

### Enable/Disable Tracking

```dart
// In main.dart
Analytics.initialize(
  enableSupabaseTracking: true, // Set to false to disable
);
```

### Debug Mode
In debug mode, events are only logged to console, not saved to database:
```dart
// Automatically enabled in debug mode
if (kDebugMode) {
  // Only uses LoggerAnalyticsClient
}
```

### Release Mode
In release mode, events are saved to Supabase:
```dart
// Automatically enabled in release mode
if (kReleaseMode) {
  // Uses SupabaseAnalyticsClient
}
```

---

## 🐛 Troubleshooting

### Events not appearing in database

1. **Check RLS policies**:
   ```sql
   SELECT * FROM analytics_events; -- Run as authenticated user
   ```

2. **Check user authentication**:
   ```dart
   final user = Supabase.instance.client.auth.currentUser;
   print('User ID: ${user?.id}'); // Should not be null
   ```

3. **Check error logs**:
   Events that fail to insert will be logged to console.

### Performance issues

1. **Add more indexes** if querying specific parameters frequently:
   ```sql
   CREATE INDEX idx_custom ON analytics_events((event_params->>'product_id'));
   ```

2. **Archive old data** regularly

3. **Use the dashboard view** for pre-aggregated queries

---

## 📊 Example Queries for Admin Dashboard

### Revenue Analytics
```sql
SELECT 
  DATE(timestamp) as date,
  SUM((event_params->>'value')::decimal) as total_revenue,
  COUNT(*) as total_purchases,
  AVG((event_params->>'value')::decimal) as avg_order_value
FROM analytics_events
WHERE event_name = 'purchase'
  AND timestamp > NOW() - INTERVAL '30 days'
GROUP BY DATE(timestamp)
ORDER BY date DESC;
```

### Product Performance
```sql
SELECT 
  event_params->>'product_id' as product_id,
  event_params->>'product_name' as product_name,
  COUNT(*) FILTER (WHERE event_name = 'product_view') as views,
  COUNT(*) FILTER (WHERE event_name = 'add_to_cart') as adds_to_cart,
  ROUND(
    COUNT(*) FILTER (WHERE event_name = 'add_to_cart')::decimal / 
    NULLIF(COUNT(*) FILTER (WHERE event_name = 'product_view'), 0) * 100,
    2
  ) as conversion_rate
FROM analytics_events
WHERE event_name IN ('product_view', 'add_to_cart')
  AND timestamp > NOW() - INTERVAL '7 days'
GROUP BY 
  event_params->>'product_id',
  event_params->>'product_name'
ORDER BY views DESC
LIMIT 20;
```

### User Journey
```sql
SELECT 
  user_id,
  event_name,
  event_params,
  timestamp
FROM analytics_events
WHERE user_id = 'USER_ID_HERE'
ORDER BY timestamp DESC
LIMIT 100;
```

---

## ✅ Advantages Over Firebase Analytics

1. **No Additional Service** - Uses your existing Supabase infrastructure
2. **Full Data Control** - All data stays in your database
3. **Custom Queries** - Write any SQL query you need
4. **No Cost Surprises** - Included in your Supabase plan
5. **Privacy Compliant** - Full control over data storage and retention
6. **Real-time Access** - Query your data immediately
7. **Integration** - Easily join with other app data

---

## 📞 Support

For issues or questions:
1. Check Supabase logs in Dashboard
2. Review the migration SQL file
3. Verify RLS policies
4. Check app logs for errors

---

**Status**: ✅ Ready to use with your existing Supabase stack!
