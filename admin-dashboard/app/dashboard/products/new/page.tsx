import { createServerSupabaseClient } from '@/lib/supabase/server'
import { ProductForm } from '../product-form'

async function getCategories() {
  const supabase = await createServerSupabaseClient()
  const { data } = await supabase
    .from('categories')
    .select('*')
    .eq('is_active', true)
    .order('display_order')
  return data || []
}

export default async function NewProductPage() {
  const categories = await getCategories()

  return (
    <div className="p-8">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-slate-900">Nouveau produit</h1>
        <p className="text-slate-600 mt-1">
          Ajoutez un nouveau produit à votre catalogue
        </p>
      </div>

      <ProductForm categories={categories} />
    </div>
  )
}
