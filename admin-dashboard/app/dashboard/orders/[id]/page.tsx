import { createServerSupabaseClient } from '@/lib/supabase/server'
import { notFound } from 'next/navigation'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { ArrowLeft, User, Phone, MapPin, CreditCard, Package } from 'lucide-react'
import Link from 'next/link'
import { format } from 'date-fns'
import { fr } from 'date-fns/locale'

const statusLabels: Record<string, string> = {
  pending: 'En attente',
  confirmed: 'Confirmée',
  processing: 'En traitement',
  shipped: 'Expédiée',
  delivered: 'Livrée',
  cancelled: 'Annulée',
}

const statusColors: Record<string, string> = {
  pending: 'bg-yellow-100 text-yellow-800',
  confirmed: 'bg-blue-100 text-blue-800',
  processing: 'bg-purple-100 text-purple-800',
  shipped: 'bg-indigo-100 text-indigo-800',
  delivered: 'bg-green-100 text-green-800',
  cancelled: 'bg-red-100 text-red-800',
}

async function getOrder(id: string) {
  const supabase = await createServerSupabaseClient()
  
  const { data: order, error } = await supabase
    .from('orders')
    .select(`
      *,
      profiles(full_name, phone, avatar_url),
      order_items(
        id,
        quantity,
        price,
        products(name, image_url)
      )
    `)
    .eq('id', id)
    .single()

  if (error) {
    console.error('Error fetching order:', error)
    return null
  }

  return order
}

export default async function OrderDetailPage({ params }: { params: { id: string } }) {
  const order = await getOrder(params.id)

  if (!order) {
    notFound()
  }

  return (
    <div className="p-8">
      <div className="flex items-center gap-4 mb-8">
        <Link href="/dashboard/orders">
          <Button variant="ghost" size="sm">
            <ArrowLeft className="h-4 w-4 mr-2" />
            Retour
          </Button>
        </Link>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Main Content */}
        <div className="lg:col-span-2 space-y-6">
          {/* Order Info */}
          <Card>
            <CardHeader>
              <div className="flex items-center justify-between">
                <CardTitle>Commande #{order.order_number}</CardTitle>
                <Badge className={statusColors[order.status]}>
                  {statusLabels[order.status]}
                </Badge>
              </div>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-2 gap-4 text-sm">
                <div>
                  <p className="text-slate-600">Date de commande</p>
                  <p className="font-medium">
                    {format(new Date(order.created_at), 'dd MMMM yyyy à HH:mm', { locale: fr })}
                  </p>
                </div>
                {order.confirmed_at && (
                  <div>
                    <p className="text-slate-600">Date de confirmation</p>
                    <p className="font-medium">
                      {format(new Date(order.confirmed_at), 'dd MMMM yyyy à HH:mm', { locale: fr })}
                    </p>
                  </div>
                )}
                {order.shipped_at && (
                  <div>
                    <p className="text-slate-600">Date d'expédition</p>
                    <p className="font-medium">
                      {format(new Date(order.shipped_at), 'dd MMMM yyyy à HH:mm', { locale: fr })}
                    </p>
                  </div>
                )}
                {order.delivered_at && (
                  <div>
                    <p className="text-slate-600">Date de livraison</p>
                    <p className="font-medium">
                      {format(new Date(order.delivered_at), 'dd MMMM yyyy à HH:mm', { locale: fr })}
                    </p>
                  </div>
                )}
              </div>
            </CardContent>
          </Card>

          {/* Order Items */}
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Package className="h-5 w-5" />
                Articles commandés
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {order.order_items?.map((item: any) => (
                  <div key={item.id} className="flex items-center gap-4 pb-4 border-b last:border-0">
                    <div className="w-16 h-16 bg-slate-100 rounded-lg overflow-hidden flex-shrink-0">
                      {item.products?.image_url ? (
                        <img 
                          src={item.products.image_url} 
                          alt={item.products.name}
                          className="w-full h-full object-cover"
                        />
                      ) : (
                        <div className="w-full h-full flex items-center justify-center text-slate-400">
                          📦
                        </div>
                      )}
                    </div>
                    <div className="flex-1">
                      <p className="font-medium">{item.products?.name || 'Produit inconnu'}</p>
                      <p className="text-sm text-slate-600">Quantité: {item.quantity}</p>
                    </div>
                    <div className="text-right">
                      <p className="font-semibold">{(item.price * item.quantity).toLocaleString('fr-FR')} FCFA</p>
                      <p className="text-sm text-slate-600">{item.price.toLocaleString('fr-FR')} FCFA / unité</p>
                    </div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Sidebar */}
        <div className="space-y-6">
          {/* Customer Info */}
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <User className="h-5 w-5" />
                Client
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div>
                <p className="text-sm text-slate-600 mb-1">Nom</p>
                <p className="font-medium">{order.profiles?.full_name || 'Client'}</p>
              </div>
              {order.profiles?.phone && (
                <div>
                  <p className="text-sm text-slate-600 mb-1 flex items-center gap-1">
                    <Phone className="h-4 w-4" />
                    Téléphone
                  </p>
                  <p className="font-medium">{order.profiles.phone}</p>
                </div>
              )}
            </CardContent>
          </Card>

          {/* Shipping Address */}
          {order.shipping_address && (
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <MapPin className="h-5 w-5" />
                  Adresse de livraison
                </CardTitle>
              </CardHeader>
              <CardContent>
                <p className="text-sm whitespace-pre-line">{order.shipping_address}</p>
              </CardContent>
            </Card>
          )}

          {/* Payment Info */}
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <CreditCard className="h-5 w-5" />
                Paiement
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-3">
              <div className="flex justify-between">
                <span className="text-slate-600">Sous-total</span>
                <span className="font-medium">{order.subtotal?.toLocaleString('fr-FR') || '0'} FCFA</span>
              </div>
              {order.shipping_fee > 0 && (
                <div className="flex justify-between">
                  <span className="text-slate-600">Frais de livraison</span>
                  <span className="font-medium">{order.shipping_fee.toLocaleString('fr-FR')} FCFA</span>
                </div>
              )}
              {order.discount > 0 && (
                <div className="flex justify-between text-green-600">
                  <span>Réduction</span>
                  <span className="font-medium">-{order.discount.toLocaleString('fr-FR')} FCFA</span>
                </div>
              )}
              <div className="flex justify-between pt-3 border-t text-lg">
                <span className="font-semibold">Total</span>
                <span className="font-bold">{order.total.toLocaleString('fr-FR')} FCFA</span>
              </div>
              <div className="pt-2">
                <Badge variant={order.payment_status === 'paid' ? 'default' : 'secondary'}>
                  {order.payment_status === 'paid' ? 'Payé' : 'En attente'}
                </Badge>
              </div>
              {order.payment_method && (
                <div className="text-sm text-slate-600">
                  Méthode: {order.payment_method}
                </div>
              )}
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  )
}
