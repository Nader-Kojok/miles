import { createServerSupabaseClient } from '@/lib/supabase/server'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { ArrowUpRight, Clock, ShoppingCart } from 'lucide-react'
import { DashboardHeader } from '@/components/dashboard-header'
import { StatCard } from '@/components/stat-card'
import Link from 'next/link'

async function getDashboardStats() {
  const supabase = await createServerSupabaseClient()

  const [
    { count: productsCount },
    { count: ordersCount },
    { count: usersCount },
    { data: recentOrders },
  ] = await Promise.all([
    supabase.from('products').select('*', { count: 'exact', head: true }),
    supabase.from('orders').select('*', { count: 'exact', head: true }),
    supabase.from('profiles').select('*', { count: 'exact', head: true }),
    supabase
      .from('orders')
      .select('*, profiles(full_name, phone)')
      .order('created_at', { ascending: false })
      .limit(5),
  ])

  // Calculate total revenue
  const { data: orders } = await supabase.from('orders').select('total')
  const totalRevenue = orders?.reduce((sum, order) => sum + (order.total || 0), 0) || 0

  return {
    productsCount: productsCount || 0,
    ordersCount: ordersCount || 0,
    usersCount: usersCount || 0,
    totalRevenue,
    recentOrders: recentOrders || [],
  }
}

export default async function DashboardPage() {
  const stats = await getDashboardStats()

  const getStatusBadge = (status: string) => {
    if (status === 'delivered') return 'bg-green-100 text-green-800'
    if (status === 'cancelled') return 'bg-red-100 text-red-800'
    return 'bg-yellow-100 text-yellow-800'
  }

  const getStatusLabel = (status: string) => {
    const labels: Record<string, string> = {
      pending: 'En attente',
      confirmed: 'Confirmée',
      processing: 'En cours',
      shipped: 'Expédiée',
      delivered: 'Livrée',
      cancelled: 'Annulée'
    }
    return labels[status] || status
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 via-white to-gray-50">
      <DashboardHeader 
        title="Tableau de bord" 
        subtitle="Vue d'ensemble de votre activité"
      />
      
      <div className="p-6 space-y-6">
        {/* Stats Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          <StatCard
            title="Total Produits"
            value={stats.productsCount}
            iconName="package"
            color="blue"
            trend={{ value: 12, isPositive: true }}
            delay={0}
          />
          <StatCard
            title="Commandes"
            value={stats.ordersCount}
            iconName="shopping-cart"
            color="green"
            trend={{ value: 8, isPositive: true }}
            delay={100}
          />
          <StatCard
            title="Utilisateurs"
            value={stats.usersCount}
            iconName="users"
            color="purple"
            trend={{ value: 3, isPositive: true }}
            delay={200}
          />
          <StatCard
            title="Chiffre d'affaires"
            value={`${stats.totalRevenue.toLocaleString('fr-FR')} FCFA`}
            iconName="trending-up"
            color="orange"
            trend={{ value: 15, isPositive: true }}
            delay={300}
          />
        </div>

        {/* Recent Orders Section */}
        <Card className="border-0 shadow-lg animate-fade-in bg-white/80 backdrop-blur-sm">
          <CardHeader className="border-b bg-gradient-to-r from-gray-50 to-white">
            <div className="flex items-center justify-between">
              <div>
                <CardTitle className="text-xl font-bold flex items-center gap-2">
                  <Clock className="h-5 w-5 text-gray-600" />
                  Commandes récentes
                </CardTitle>
                <p className="text-sm text-gray-500 mt-1">
                  Dernières commandes passées
                </p>
              </div>
              <Link
                href="/dashboard/orders"
                className="text-sm font-medium text-blue-600 hover:text-blue-700 flex items-center gap-1 smooth-transition group"
              >
                Voir tout
                <ArrowUpRight className="h-4 w-4 group-hover:translate-x-0.5 group-hover:-translate-y-0.5 transition-transform" />
              </Link>
            </div>
          </CardHeader>
          <CardContent className="p-0">
            {stats.recentOrders.length === 0 ? (
              <div className="text-center py-12">
                <ShoppingCart className="h-12 w-12 text-gray-300 mx-auto mb-3" />
                <p className="text-gray-500 font-medium">Aucune commande pour le moment</p>
                <p className="text-sm text-gray-400 mt-1">Les nouvelles commandes apparaîtront ici</p>
              </div>
            ) : (
              <div className="divide-y">
                {stats.recentOrders.map((order: any, index: number) => (
                  <Link
                    key={order.id}
                    href={`/dashboard/orders`}
                    className="flex items-center justify-between p-6 hover:bg-gray-50 smooth-transition group animate-slide-in-up"
                    style={{ animationDelay: `${(index + 4) * 100}ms` }}
                  >
                    <div className="flex items-center gap-4 flex-1">
                      <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-blue-500 to-blue-600 flex items-center justify-center text-white font-bold shadow-lg">
                        {order.order_number.slice(-3)}
                      </div>
                      <div className="flex-1">
                        <div className="flex items-center gap-2">
                          <p className="font-semibold text-gray-900 group-hover:text-blue-600 transition-colors">
                            {order.order_number}
                          </p>
                          <span
                            className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusBadge(order.status)}`}
                          >
                            {getStatusLabel(order.status)}
                          </span>
                        </div>
                        <p className="text-sm text-gray-500 mt-0.5">
                          {order.profiles?.full_name || 'Client'} • {order.profiles?.phone || 'N/A'}
                        </p>
                      </div>
                    </div>
                    <div className="text-right">
                      <p className="font-bold text-lg text-gray-900">
                        {order.total.toLocaleString('fr-FR')} <span className="text-sm font-normal text-gray-500">FCFA</span>
                      </p>
                      <p className="text-xs text-gray-400 mt-0.5">
                        {new Date(order.created_at).toLocaleDateString('fr-FR', {
                          day: 'numeric',
                          month: 'short',
                          hour: '2-digit',
                          minute: '2-digit'
                        })}
                      </p>
                    </div>
                    <ArrowUpRight className="h-5 w-5 text-gray-400 ml-4 group-hover:text-blue-600 group-hover:translate-x-1 group-hover:-translate-y-1 transition-all" />
                  </Link>
                ))}
              </div>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
