import { createServerSupabaseClient } from '@/lib/supabase/server'
import { ProductForm } from '../product-form'
import { notFound } from 'next/navigation'

async function getProduct(id: string) {
  const supabase = await createServerSupabaseClient()
  const { data } = await supabase
    .from('products')
    .select('*')
    .eq('id', id)
    .single()
  return data
}

async function getCategories() {
  const supabase = await createServerSupabaseClient()
  const { data } = await supabase
    .from('categories')
    .select('*')
    .eq('is_active', true)
    .order('display_order')
  return data || []
}

export default async function EditProductPage({ 
  params 
}: { 
  params: Promise<{ id: string }> 
}) {
  const { id } = await params
  const [product, categories] = await Promise.all([
    getProduct(id),
    getCategories(),
  ])

  if (!product) {
    notFound()
  }

  return (
    <div className="p-8">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-slate-900">Modifier le produit</h1>
        <p className="text-slate-600 mt-1">
          Mettez à jour les informations du produit
        </p>
      </div>

      <ProductForm product={product} categories={categories} />
    </div>
  )
}
