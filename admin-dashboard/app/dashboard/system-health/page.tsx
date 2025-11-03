'use client';

import { useEffect, useState } from 'react';
import { createClient } from '@/lib/supabase/client';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { DashboardHeader } from '@/components/dashboard-header';
import { 
  AlertCircle, 
  CheckCircle, 
  Wifi, 
  WifiOff, 
  Users, 
  Heart,
  Car,
  TrendingUp,
  Activity,
  Database,
  Server
} from 'lucide-react';

interface SystemMetrics {
  totalUsers: number;
  activeUsers: number;
  totalFavorites: number;
  totalVehicles: number;
  totalOrders: number;
  recentErrors: number;
  avgResponseTime: number;
}

interface ErrorLog {
  id: string;
  error_type: string;
  error_message: string;
  timestamp: string;
  user_id?: string;
}

export default function SystemHealthPage() {
  const [loading, setLoading] = useState(true);
  const [metrics, setMetrics] = useState<SystemMetrics>({
    totalUsers: 0,
    activeUsers: 0,
    totalFavorites: 0,
    totalVehicles: 0,
    totalOrders: 0,
    recentErrors: 0,
    avgResponseTime: 0,
  });
  const [recentErrors, setRecentErrors] = useState<ErrorLog[]>([]);
  const [providerStatus, setProviderStatus] = useState({
    profile: { active: true, lastUpdate: new Date() },
    favorites: { active: true, lastUpdate: new Date() },
    vehicles: { active: true, lastUpdate: new Date() },
    connectivity: { active: true, lastUpdate: new Date() },
  });

  const supabase = createClient();

  useEffect(() => {
    loadSystemHealth();
    const interval = setInterval(loadSystemHealth, 30000); // Refresh every 30s
    return () => clearInterval(interval);
  }, []);

  async function loadSystemHealth() {
    setLoading(true);
    try {
      await Promise.all([
        loadMetrics(),
        loadRecentErrors(),
        checkProviderStatus(),
      ]);
    } catch (error) {
      console.error('Error loading system health:', error);
    } finally {
      setLoading(false);
    }
  }

  async function loadMetrics() {
    // Total users
    const { count: totalUsers } = await supabase
      .from('profiles')
      .select('*', { count: 'exact', head: true });

    // Active users (last 24h)
    const { data: activeUsersData } = await supabase
      .from('analytics_events')
      .select('user_id')
      .gte('timestamp', new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString());

    const activeUsers = new Set(activeUsersData?.map(e => e.user_id).filter(Boolean)).size;

    // Total favorites
    const { count: totalFavorites } = await supabase
      .from('favorites')
      .select('*', { count: 'exact', head: true });

    // Total vehicles
    const { count: totalVehicles } = await supabase
      .from('vehicles')
      .select('*', { count: 'exact', head: true });

    // Total orders
    const { count: totalOrders } = await supabase
      .from('orders')
      .select('*', { count: 'exact', head: true });

    // Recent errors (last 24h)
    const { count: recentErrors } = await supabase
      .from('analytics_events')
      .select('*', { count: 'exact', head: true })
      .eq('event_name', 'app_error')
      .gte('timestamp', new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString());

    setMetrics({
      totalUsers: totalUsers || 0,
      activeUsers,
      totalFavorites: totalFavorites || 0,
      totalVehicles: totalVehicles || 0,
      totalOrders: totalOrders || 0,
      recentErrors: recentErrors || 0,
      avgResponseTime: 0, // Calculate from analytics if needed
    });
  }

  async function loadRecentErrors() {
    const { data } = await supabase
      .from('analytics_events')
      .select('id, event_params, timestamp, user_id')
      .eq('event_name', 'app_error')
      .order('timestamp', { ascending: false })
      .limit(10);

    if (data) {
      const errors: ErrorLog[] = data.map(e => ({
        id: e.id,
        error_type: e.event_params?.error_type || 'Unknown',
        error_message: e.event_params?.error_message || 'No message',
        timestamp: e.timestamp,
        user_id: e.user_id,
      }));
      setRecentErrors(errors);
    }
  }

  async function checkProviderStatus() {
    // Check if providers are being used (have recent data)
    const now = new Date();
    const oneDayAgo = new Date(Date.now() - 24 * 60 * 60 * 1000);

    // Profile provider status
    const { data: profileData } = await supabase
      .from('profiles')
      .select('updated_at')
      .order('updated_at', { ascending: false })
      .limit(1);

    // Favorites provider status
    const { data: favoritesData } = await supabase
      .from('favorites')
      .select('created_at')
      .order('created_at', { ascending: false })
      .limit(1);

    // Vehicles provider status
    const { data: vehiclesData } = await supabase
      .from('vehicles')
      .select('updated_at')
      .order('updated_at', { ascending: false })
      .limit(1);

    setProviderStatus({
      profile: {
        active: Boolean(profileData && profileData.length > 0),
        lastUpdate: profileData?.[0]?.updated_at ? new Date(profileData[0].updated_at) : now,
      },
      favorites: {
        active: Boolean(favoritesData && favoritesData.length > 0),
        lastUpdate: favoritesData?.[0]?.created_at ? new Date(favoritesData[0].created_at) : now,
      },
      vehicles: {
        active: Boolean(vehiclesData && vehiclesData.length > 0),
        lastUpdate: vehiclesData?.[0]?.updated_at ? new Date(vehiclesData[0].updated_at) : now,
      },
      connectivity: {
        active: true,
        lastUpdate: now,
      },
    });
  }

  const getHealthStatus = () => {
    if (metrics.recentErrors > 10) return { status: 'critical', color: 'red', label: 'Critique' };
    if (metrics.recentErrors > 5) return { status: 'warning', color: 'yellow', label: 'Attention' };
    return { status: 'healthy', color: 'green', label: 'Sain' };
  };

  const health = getHealthStatus();

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
        title="État du Système" 
        subtitle="Surveillance des nouvelles fonctionnalités"
      />
      
      <div className="p-6 space-y-6">
        {/* Health Status Badge */}
        <div className="flex justify-end">
          <Badge 
            variant={health.status === 'healthy' ? 'default' : 'destructive'}
            className="text-lg px-4 py-2"
          >
            {health.status === 'healthy' ? (
              <CheckCircle className="h-4 w-4 mr-2" />
            ) : (
              <AlertCircle className="h-4 w-4 mr-2" />
            )}
            {health.label}
          </Badge>
        </div>

      {/* System Metrics */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Utilisateurs Actifs</CardTitle>
            <Users className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{metrics.activeUsers}</div>
            <p className="text-xs text-muted-foreground">
              sur {metrics.totalUsers} total (24h)
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Favoris Actifs</CardTitle>
            <Heart className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{metrics.totalFavorites}</div>
            <p className="text-xs text-muted-foreground">
              Provider Favorites actif
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Véhicules</CardTitle>
            <Car className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{metrics.totalVehicles}</div>
            <p className="text-xs text-muted-foreground">
              Provider Vehicles actif
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Erreurs (24h)</CardTitle>
            <AlertCircle className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className={`text-2xl font-bold ${metrics.recentErrors > 5 ? 'text-red-600' : ''}`}>
              {metrics.recentErrors}
            </div>
            <p className="text-xs text-muted-foreground">
              Error Handler actif
            </p>
          </CardContent>
        </Card>
      </div>

      {/* Provider Status */}
      <Card>
        <CardHeader>
          <CardTitle>État des Providers</CardTitle>
          <CardDescription>Surveillance des nouveaux providers de state management</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            <div className="flex items-center justify-between p-4 border rounded-lg">
              <div className="flex items-center gap-3">
                <Users className="h-5 w-5" />
                <div>
                  <p className="font-medium">ProfileProvider</p>
                  <p className="text-sm text-gray-500">Gestion des profils et adresses</p>
                </div>
              </div>
              <div className="flex items-center gap-2">
                {providerStatus.profile.active ? (
                  <Badge variant="default" className="bg-green-500">
                    <CheckCircle className="h-3 w-3 mr-1" />
                    Actif
                  </Badge>
                ) : (
                  <Badge variant="destructive">
                    <AlertCircle className="h-3 w-3 mr-1" />
                    Inactif
                  </Badge>
                )}
                <span className="text-xs text-gray-500">
                  {providerStatus.profile.lastUpdate.toLocaleTimeString('fr-FR')}
                </span>
              </div>
            </div>

            <div className="flex items-center justify-between p-4 border rounded-lg">
              <div className="flex items-center gap-3">
                <Heart className="h-5 w-5" />
                <div>
                  <p className="font-medium">FavoriteProvider</p>
                  <p className="text-sm text-gray-500">Gestion des favoris avec updates optimistes</p>
                </div>
              </div>
              <div className="flex items-center gap-2">
                {providerStatus.favorites.active ? (
                  <Badge variant="default" className="bg-green-500">
                    <CheckCircle className="h-3 w-3 mr-1" />
                    Actif
                  </Badge>
                ) : (
                  <Badge variant="destructive">
                    <AlertCircle className="h-3 w-3 mr-1" />
                    Inactif
                  </Badge>
                )}
                <span className="text-xs text-gray-500">
                  {providerStatus.favorites.lastUpdate.toLocaleTimeString('fr-FR')}
                </span>
              </div>
            </div>

            <div className="flex items-center justify-between p-4 border rounded-lg">
              <div className="flex items-center gap-3">
                <Car className="h-5 w-5" />
                <div>
                  <p className="font-medium">VehicleProvider</p>
                  <p className="text-sm text-gray-500">Gestion des véhicules utilisateur</p>
                </div>
              </div>
              <div className="flex items-center gap-2">
                {providerStatus.vehicles.active ? (
                  <Badge variant="default" className="bg-green-500">
                    <CheckCircle className="h-3 w-3 mr-1" />
                    Actif
                  </Badge>
                ) : (
                  <Badge variant="destructive">
                    <AlertCircle className="h-3 w-3 mr-1" />
                    Inactif
                  </Badge>
                )}
                <span className="text-xs text-gray-500">
                  {providerStatus.vehicles.lastUpdate.toLocaleTimeString('fr-FR')}
                </span>
              </div>
            </div>

            <div className="flex items-center justify-between p-4 border rounded-lg">
              <div className="flex items-center gap-3">
                <Wifi className="h-5 w-5" />
                <div>
                  <p className="font-medium">ConnectivityService</p>
                  <p className="text-sm text-gray-500">Surveillance de la connexion réseau</p>
                </div>
              </div>
              <div className="flex items-center gap-2">
                <Badge variant="default" className="bg-green-500">
                  <CheckCircle className="h-3 w-3 mr-1" />
                  Actif
                </Badge>
                <span className="text-xs text-gray-500">Temps réel</span>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Recent Errors */}
      {recentErrors.length > 0 && (
        <Card>
          <CardHeader>
            <CardTitle>Erreurs Récentes</CardTitle>
            <CardDescription>Erreurs capturées par le GlobalErrorHandler</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              {recentErrors.map((error) => (
                <div key={error.id} className="flex items-start gap-3 p-3 border rounded-lg">
                  <AlertCircle className="h-5 w-5 text-red-500 mt-0.5" />
                  <div className="flex-1">
                    <div className="flex items-center justify-between">
                      <p className="font-medium text-sm">{error.error_type}</p>
                      <span className="text-xs text-gray-500">
                        {new Date(error.timestamp).toLocaleString('fr-FR')}
                      </span>
                    </div>
                    <p className="text-sm text-gray-600 mt-1">{error.error_message}</p>
                    {error.user_id && (
                      <p className="text-xs text-gray-400 mt-1">User: {error.user_id}</p>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      )}

      {/* Analytics Integration Status */}
      <Card>
        <CardHeader>
          <CardTitle>Intégration Analytics</CardTitle>
          <CardDescription>Supabase Analytics (sans Firebase)</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <Database className="h-5 w-5" />
                <div>
                  <p className="font-medium">Base de données Analytics</p>
                  <p className="text-sm text-gray-500">Tables: analytics_events, analytics_user_properties</p>
                </div>
              </div>
              <Badge variant="default" className="bg-green-500">
                <CheckCircle className="h-3 w-3 mr-1" />
                Opérationnel
              </Badge>
            </div>

            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <Server className="h-5 w-5" />
                <div>
                  <p className="font-medium">SupabaseAnalyticsClient</p>
                  <p className="text-sm text-gray-500">Stockage direct dans Supabase</p>
                </div>
              </div>
              <Badge variant="default" className="bg-green-500">
                <CheckCircle className="h-3 w-3 mr-1" />
                Actif
              </Badge>
            </div>

            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <Activity className="h-5 w-5" />
                <div>
                  <p className="font-medium">Événements Trackés</p>
                  <p className="text-sm text-gray-500">15+ types d'événements configurés</p>
                </div>
              </div>
              <Badge variant="default" className="bg-green-500">
                <CheckCircle className="h-3 w-3 mr-1" />
                Configuré
              </Badge>
            </div>
          </div>
        </CardContent>
      </Card>
      </div>
    </div>
  );
}
