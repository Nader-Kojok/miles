# Admin Dashboard - Analytics & System Health Guide

## 🎯 New Dashboard Pages

Your Next.js admin dashboard now has **2 new pages** to monitor all the technical improvements:

### 1. 📊 Analytics Dashboard
**URL**: `/dashboard/analytics`

**What it shows**:
- **Total Events** - All tracked events (last 30 days)
- **Active Users** - Daily active users
- **Product Views** - Total product page visits
- **Conversions** - Completed purchases

**Tabs**:
- **Événements** - Summary of all event types with counts
- **Produits** - Top products by views, cart adds, and conversion rate
- **Recherches** - Popular search terms and average results
- **Activité Quotidienne** - Daily breakdown of events and users

**Data Source**: Supabase `analytics_events` table

---

### 2. 🏥 System Health Dashboard
**URL**: `/dashboard/system-health`

**What it shows**:
- **System Status** - Overall health (Healthy/Warning/Critical)
- **Active Users** - Users in last 24h
- **Favorites Count** - Total favorites tracked
- **Vehicles Count** - Total vehicles registered
- **Recent Errors** - Errors caught in last 24h

**Provider Status Monitoring**:
- ✅ **ProfileProvider** - User profiles & addresses management
- ✅ **FavoriteProvider** - Favorites with optimistic updates
- ✅ **VehicleProvider** - Vehicle management
- ✅ **ConnectivityService** - Network monitoring

**Error Tracking**:
- Shows recent errors captured by GlobalErrorHandler
- Error type, message, timestamp, and user ID
- Real-time error monitoring

**Analytics Integration Status**:
- Database tables status
- SupabaseAnalyticsClient status
- Event tracking configuration

---

## 🚀 How to Access

### In the Admin Dashboard:

1. **Login** to admin dashboard
2. **Sidebar Navigation** - New menu items:
   - 📊 **Analytics** - View all analytics data
   - 🏥 **État Système** - Monitor system health

### Direct URLs:
```
https://your-domain.com/dashboard/analytics
https://your-domain.com/dashboard/system-health
```

---

## 📊 Analytics Queries Used

### Event Summary (Last 30 days):
```typescript
const { data } = await supabase
  .from('analytics_events')
  .select('event_name, user_id')
  .gte('timestamp', thirtyDaysAgo);
```

### Top Products (Last 7 days):
```typescript
const { data } = await supabase
  .from('analytics_events')
  .select('event_name, event_params')
  .in('event_name', ['product_view', 'add_to_cart'])
  .gte('timestamp', sevenDaysAgo);
```

### Search Terms:
```typescript
const { data } = await supabase
  .from('analytics_events')
  .select('event_params')
  .eq('event_name', 'search')
  .gte('timestamp', sevenDaysAgo);
```

### Daily Stats:
```typescript
const { data } = await supabase
  .from('analytics_events')
  .select('timestamp, event_name, user_id')
  .gte('timestamp', sevenDaysAgo);
```

---

## 🎨 Dashboard Features

### Real-time Updates:
- System Health refreshes every 30 seconds
- Manual refresh available on all pages

### Visual Indicators:
- ✅ **Green badges** - System healthy
- ⚠️ **Yellow badges** - Warning state
- ❌ **Red badges** - Critical issues

### Event Icons:
- 👁️ Product views
- 🛒 Cart actions
- 🔍 Searches
- ❤️ Favorites
- 📦 Purchases

---

## 📈 Metrics Explained

### Analytics Dashboard:

**Total Événements**: Sum of all tracked events
**Utilisateurs Actifs**: Unique users today
**Vues Produits**: Total product_view events
**Conversions**: Total purchase events

### System Health:

**Utilisateurs Actifs**: Unique users in last 24h
**Favoris Actifs**: Total favorites in database
**Véhicules**: Total vehicles registered
**Erreurs (24h)**: Errors caught by GlobalErrorHandler

---

## 🔧 Customization

### Add Custom Metrics:

Edit `/app/dashboard/analytics/page.tsx`:

```typescript
// Add new metric
const { count: customMetric } = await supabase
  .from('your_table')
  .select('*', { count: 'exact', head: true });

// Display in card
<Card>
  <CardHeader>
    <CardTitle>Custom Metric</CardTitle>
  </CardHeader>
  <CardContent>
    <div className="text-2xl font-bold">{customMetric}</div>
  </CardContent>
</Card>
```

### Add New Event Types:

Update the `getEventLabel` function:

```typescript
const labels: any = {
  'your_event': 'Your Event Label',
  // ... existing events
};
```

---

## 🐛 Troubleshooting

### No data showing?

1. **Check Supabase migration ran**:
   ```sql
   SELECT * FROM analytics_events LIMIT 1;
   ```

2. **Check RLS policies**:
   - Admin users should have access
   - Verify in Supabase Dashboard > Authentication

3. **Check app is tracking events**:
   ```dart
   Analytics.instance.trackScreenView('TestScreen');
   ```

### Provider status showing inactive?

- Providers show as active when they have recent data
- Add test data to verify:
  ```sql
  -- Check profiles
  SELECT COUNT(*) FROM profiles;
  
  -- Check favorites
  SELECT COUNT(*) FROM favorites;
  
  -- Check vehicles
  SELECT COUNT(*) FROM vehicles;
  ```

---

## 📱 Mobile App Integration

Events are automatically tracked when you use the Analytics service in your Flutter app:

```dart
// In any screen
Analytics.instance.trackScreenView('ProductScreen');
Analytics.instance.trackProductView(product.id, product.name);
Analytics.instance.trackAddToCart(id, name, price, qty);
```

All these events will appear in the Analytics Dashboard!

---

## 🎯 Best Practices

### For Analytics:
1. **Track key user actions** - Focus on conversion funnel
2. **Monitor daily** - Check for unusual patterns
3. **Use filters** - Focus on specific time periods
4. **Export data** - Use SQL queries for detailed analysis

### For System Health:
1. **Check daily** - Monitor error rates
2. **Investigate spikes** - Look into sudden error increases
3. **Monitor providers** - Ensure all are active
4. **Review errors** - Fix recurring issues

---

## 📊 Example Queries for Custom Reports

### Conversion Funnel:
```sql
SELECT 
  event_name,
  COUNT(*) as count,
  COUNT(DISTINCT user_id) as unique_users
FROM analytics_events
WHERE event_name IN ('product_view', 'add_to_cart', 'begin_checkout', 'purchase')
  AND timestamp > NOW() - INTERVAL '7 days'
GROUP BY event_name
ORDER BY 
  CASE event_name
    WHEN 'product_view' THEN 1
    WHEN 'add_to_cart' THEN 2
    WHEN 'begin_checkout' THEN 3
    WHEN 'purchase' THEN 4
  END;
```

### User Retention:
```sql
SELECT 
  DATE(timestamp) as date,
  COUNT(DISTINCT user_id) as daily_users
FROM analytics_events
WHERE timestamp > NOW() - INTERVAL '30 days'
GROUP BY DATE(timestamp)
ORDER BY date DESC;
```

### Product Performance:
```sql
SELECT 
  event_params->>'product_name' as product,
  COUNT(*) FILTER (WHERE event_name = 'product_view') as views,
  COUNT(*) FILTER (WHERE event_name = 'add_to_cart') as cart_adds,
  ROUND(
    COUNT(*) FILTER (WHERE event_name = 'add_to_cart')::decimal / 
    NULLIF(COUNT(*) FILTER (WHERE event_name = 'product_view'), 0) * 100,
    2
  ) as conversion_rate
FROM analytics_events
WHERE event_name IN ('product_view', 'add_to_cart')
  AND timestamp > NOW() - INTERVAL '7 days'
GROUP BY event_params->>'product_name'
ORDER BY views DESC
LIMIT 20;
```

---

## ✅ Summary

You now have **complete visibility** into:
- ✅ User behavior (Analytics Dashboard)
- ✅ System health (System Health Dashboard)
- ✅ Provider status (Real-time monitoring)
- ✅ Error tracking (GlobalErrorHandler integration)
- ✅ Performance metrics (All in Supabase)

**All without Firebase** - using only your existing Supabase stack! 🎉

---

## 📞 Support

For issues or questions:
1. Check Supabase logs
2. Review analytics_events table
3. Verify RLS policies
4. Check app integration

**Status**: ✅ Fully operational with Supabase!
