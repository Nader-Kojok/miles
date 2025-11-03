import { createServerSupabaseClient } from '@/lib/supabase/server'
import { Button } from '@/components/ui/button'
import { Plus } from 'lucide-react'
import Link from 'next/link'
import { ProductsTable } from './products-table'

async function getProducts() {
  const supabase = await createServerSupabaseClient()
  
  const { data: products, error } = await supabase
    .from('products')
    .select('*, categories(name)')
    .order('created_at', { ascending: false })

  if (error) {
    console.error('Error fetching products:', error)
    return []
  }

  return products || []
}

export default async function ProductsPage() {
  const products = await getProducts()

  return (
    <div className="p-8">
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-3xl font-bold text-slate-900">Produits</h1>
          <p className="text-slate-600 mt-1">
            Gérez votre catalogue de pièces détachées
          </p>
        </div>
        <Link href="/dashboard/products/new">
          <Button>
            <Plus className="mr-2 h-4 w-4" />
            Nouveau produit
          </Button>
        </Link>
      </div>

      <ProductsTable products={products} />
    </div>
  )
}
