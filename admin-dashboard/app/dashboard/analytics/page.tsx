'use client';

import { useEffect, useState } from 'react';
import { createClient } from '@/lib/supabase/client';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { DashboardHeader } from '@/components/dashboard-header';
import { BarChart, TrendingUp, Users, ShoppingCart, Search, Eye, Heart, Package } from 'lucide-react';

interface AnalyticsEvent {
  event_name: string;
  event_count: number;
  unique_users: number;
  event_date: string;
}

interface EventSummary {
  event_name: string;
  total_count: number;
  unique_users: number;
}

interface ProductAnalytics {
  product_name: string;
  views: number;
  adds_to_cart: number;
  conversion_rate: number;
}

export default function AnalyticsPage() {
  const [loading, setLoading] = useState(true);
  const [eventSummary, setEventSummary] = useState<EventSummary[]>([]);
  const [recentEvents, setRecentEvents] = useState<AnalyticsEvent[]>([]);
  const [topProducts, setTopProducts] = useState<ProductAnalytics[]>([]);
  const [dailyStats, setDailyStats] = useState<any[]>([]);
  const [searchTerms, setSearchTerms] = useState<any[]>([]);

  const supabase = createClient();

  useEffect(() => {
    loadAnalytics();
  }, []);

  async function loadAnalytics() {
    setLoading(true);
    try {
      await Promise.all([
        loadEventSummary(),
        loadRecentEvents(),
        loadTopProducts(),
        loadDailyStats(),
        loadSearchTerms(),
      ]);
    } catch (error) {
      console.error('Error loading analytics:', error);
    } finally {
      setLoading(false);
    }
  }

  async function loadEventSummary() {
    const { data, error } = await supabase.rpc('get_event_summary', {
      days: 30
    });

    if (!error && data) {
      setEventSummary(data);
    } else {
      // Fallback query
      const { data: fallbackData } = await supabase
        .from('analytics_events')
        .select('event_name')
        .gte('timestamp', new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString());

      if (fallbackData) {
        const summary = fallbackData.reduce((acc: any, event: any) => {
          const existing = acc.find((e: any) => e.event_name === event.event_name);
          if (existing) {
            existing.total_count++;
          } else {
            acc.push({ event_name: event.event_name, total_count: 1, unique_users: 0 });
          }
          return acc;
        }, []);
        setEventSummary(summary);
      }
    }
  }

  async function loadRecentEvents() {
    const { data } = await supabase
      .from('analytics_dashboard')
      .select('*')
      .order('event_date', { ascending: false })
      .limit(50);

    if (data) setRecentEvents(data);
  }

  async function loadTopProducts() {
    const { data } = await supabase
      .from('analytics_events')
      .select('event_name, event_params')
      .in('event_name', ['product_view', 'add_to_cart'])
      .gte('timestamp', new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString());

    if (data) {
      const productStats: any = {};
      
      data.forEach((event: any) => {
        const productName = event.event_params?.product_name;
        if (!productName) return;

        if (!productStats[productName]) {
          productStats[productName] = { product_name: productName, views: 0, adds_to_cart: 0 };
        }

        if (event.event_name === 'product_view') {
          productStats[productName].views++;
        } else if (event.event_name === 'add_to_cart') {
          productStats[productName].adds_to_cart++;
        }
      });

      const products = Object.values(productStats).map((p: any) => ({
        ...p,
        conversion_rate: p.views > 0 ? ((p.adds_to_cart / p.views) * 100).toFixed(2) : 0,
      }));

      setTopProducts(products.sort((a: any, b: any) => b.views - a.views).slice(0, 10));
    }
  }

  async function loadDailyStats() {
    const { data } = await supabase
      .from('analytics_events')
      .select('timestamp, event_name, user_id')
      .gte('timestamp', new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString());

    if (data) {
      const dailyData: any = {};
      
      data.forEach((event: any) => {
        const date = new Date(event.timestamp).toISOString().split('T')[0];
        if (!dailyData[date]) {
          dailyData[date] = { date, events: 0, users: new Set() };
        }
        dailyData[date].events++;
        if (event.user_id) dailyData[date].users.add(event.user_id);
      });

      const stats = Object.values(dailyData).map((d: any) => ({
        date: d.date,
        events: d.events,
        users: d.users.size,
      }));

      setDailyStats(stats.sort((a: any, b: any) => b.date.localeCompare(a.date)));
    }
  }

  async function loadSearchTerms() {
    const { data } = await supabase
      .from('analytics_events')
      .select('event_params')
      .eq('event_name', 'search')
      .gte('timestamp', new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString());

    if (data) {
      const searches: any = {};
      
      data.forEach((event: any) => {
        const term = event.event_params?.search_term;
        if (!term) return;
        
        if (!searches[term]) {
          searches[term] = { term, count: 0, avg_results: 0, total_results: 0 };
        }
        searches[term].count++;
        searches[term].total_results += event.event_params?.result_count || 0;
      });

      const terms = Object.values(searches).map((s: any) => ({
        term: s.term,
        count: s.count,
        avg_results: (s.total_results / s.count).toFixed(1),
      }));

      setSearchTerms(terms.sort((a: any, b: any) => b.count - a.count).slice(0, 10));
    }
  }

  const getEventIcon = (eventName: string) => {
    switch (eventName) {
      case 'product_view': return <Eye className="h-4 w-4" />;
      case 'add_to_cart': return <ShoppingCart className="h-4 w-4" />;
      case 'search': return <Search className="h-4 w-4" />;
      case 'favorite_added': return <Heart className="h-4 w-4" />;
      case 'purchase': return <Package className="h-4 w-4" />;
      default: return <BarChart className="h-4 w-4" />;
    }
  };

  const getEventLabel = (eventName: string) => {
    const labels: any = {
      'product_view': 'Vues produits',
      'add_to_cart': 'Ajouts au panier',
      'remove_from_cart': 'Retraits du panier',
      'search': 'Recherches',
      'category_view': 'Vues catégories',
      'begin_checkout': 'Débuts de commande',
      'purchase': 'Achats',
      'sign_up': 'Inscriptions',
      'login': 'Connexions',
      'favorite_added': 'Favoris ajoutés',
      'favorite_removed': 'Favoris retirés',
      'screen_view': 'Vues d\'écran',
    };
    return labels[eventName] || eventName;
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-96">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-gray-900"></div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 via-white to-gray-50">
      <DashboardHeader 
        title="Analytics Dashboard" 
        subtitle="Suivi des événements et comportement utilisateur"
      />
      
      <div className="p-6 space-y-6">

      {/* Summary Cards */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Événements</CardTitle>
            <BarChart className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">
              {eventSummary.reduce((sum, e) => sum + e.total_count, 0).toLocaleString()}
            </div>
            <p className="text-xs text-muted-foreground">Derniers 30 jours</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Utilisateurs Actifs</CardTitle>
            <Users className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">
              {dailyStats.length > 0 ? dailyStats[0].users : 0}
            </div>
            <p className="text-xs text-muted-foreground">Aujourd'hui</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Vues Produits</CardTitle>
            <Eye className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">
              {eventSummary.find(e => e.event_name === 'product_view')?.total_count || 0}
            </div>
            <p className="text-xs text-muted-foreground">Derniers 30 jours</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Conversions</CardTitle>
            <TrendingUp className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">
              {eventSummary.find(e => e.event_name === 'purchase')?.total_count || 0}
            </div>
            <p className="text-xs text-muted-foreground">Achats complétés</p>
          </CardContent>
        </Card>
      </div>

      {/* Tabs */}
      <Tabs defaultValue="events" className="space-y-4">
        <TabsList>
          <TabsTrigger value="events">Événements</TabsTrigger>
          <TabsTrigger value="products">Produits</TabsTrigger>
          <TabsTrigger value="searches">Recherches</TabsTrigger>
          <TabsTrigger value="daily">Activité Quotidienne</TabsTrigger>
        </TabsList>

        {/* Events Tab */}
        <TabsContent value="events" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle>Résumé des Événements</CardTitle>
              <CardDescription>Derniers 30 jours</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {eventSummary.map((event) => (
                  <div key={event.event_name} className="flex items-center justify-between">
                    <div className="flex items-center gap-3">
                      {getEventIcon(event.event_name)}
                      <div>
                        <p className="font-medium">{getEventLabel(event.event_name)}</p>
                        <p className="text-sm text-gray-500">{event.unique_users} utilisateurs uniques</p>
                      </div>
                    </div>
                    <div className="text-right">
                      <p className="text-2xl font-bold">{event.total_count.toLocaleString()}</p>
                    </div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        {/* Products Tab */}
        <TabsContent value="products" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle>Top Produits</CardTitle>
              <CardDescription>Derniers 7 jours - Performance des produits</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {topProducts.map((product, index) => (
                  <div key={index} className="flex items-center justify-between border-b pb-3">
                    <div className="flex-1">
                      <p className="font-medium">{product.product_name}</p>
                      <div className="flex gap-4 text-sm text-gray-500 mt-1">
                        <span>{product.views} vues</span>
                        <span>{product.adds_to_cart} ajouts panier</span>
                        <span className="text-green-600 font-medium">
                          {product.conversion_rate}% conversion
                        </span>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        {/* Searches Tab */}
        <TabsContent value="searches" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle>Termes de Recherche Populaires</CardTitle>
              <CardDescription>Derniers 7 jours</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-3">
                {searchTerms.map((search, index) => (
                  <div key={index} className="flex items-center justify-between">
                    <div className="flex items-center gap-3">
                      <Search className="h-4 w-4 text-gray-400" />
                      <span className="font-medium">{search.term}</span>
                    </div>
                    <div className="flex gap-4 text-sm text-gray-500">
                      <span>{search.count} recherches</span>
                      <span>{search.avg_results} résultats moy.</span>
                    </div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        {/* Daily Activity Tab */}
        <TabsContent value="daily" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle>Activité Quotidienne</CardTitle>
              <CardDescription>Derniers 7 jours</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-3">
                {dailyStats.map((day, index) => (
                  <div key={index} className="flex items-center justify-between border-b pb-3">
                    <div>
                      <p className="font-medium">
                        {new Date(day.date).toLocaleDateString('fr-FR', {
                          weekday: 'long',
                          day: 'numeric',
                          month: 'long',
                        })}
                      </p>
                    </div>
                    <div className="flex gap-6 text-sm">
                      <div className="text-right">
                        <p className="text-gray-500">Événements</p>
                        <p className="font-bold">{day.events}</p>
                      </div>
                      <div className="text-right">
                        <p className="text-gray-500">Utilisateurs</p>
                        <p className="font-bold">{day.users}</p>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
      </div>
    </div>
  );
}
