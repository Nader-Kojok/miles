import { createServerSupabaseClient } from '@/lib/supabase/server'
import { OrdersTable } from './orders-table'

async function getOrders() {
  const supabase = await createServerSupabaseClient()
  
  const { data: orders, error } = await supabase
    .from('orders')
    .select('*, profiles(full_name, phone)')
    .order('created_at', { ascending: false })

  if (error) {
    console.error('Error fetching orders:', error)
    return []
  }

  return orders || []
}

export default async function OrdersPage() {
  const orders = await getOrders()

  return (
    <div className="p-8">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-slate-900">Commandes</h1>
        <p className="text-slate-600 mt-1">
          Gérez les commandes de vos clients
        </p>
      </div>

      <OrdersTable orders={orders} />
    </div>
  )
}
