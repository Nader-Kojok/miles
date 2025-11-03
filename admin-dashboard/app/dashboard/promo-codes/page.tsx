import { createServerSupabaseClient } from '@/lib/supabase/server'
import { PromoCodesTable } from './promo-codes-table'
import { Button } from '@/components/ui/button'
import { Plus } from 'lucide-react'
import Link from 'next/link'

async function getPromoCodes() {
  const supabase = await createServerSupabaseClient()
  
  const { data: promoCodes, error } = await supabase
    .from('promo_codes')
    .select('*')
    .order('created_at', { ascending: false })

  if (error) {
    console.error('Error fetching promo codes:', error)
    return []
  }

  return promoCodes || []
}

export default async function PromoCodesPage() {
  const promoCodes = await getPromoCodes()

  return (
    <div className="p-8">
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-3xl font-bold text-slate-900">Codes promo</h1>
          <p className="text-slate-600 mt-1">
            Créez et gérez vos codes promotionnels
          </p>
        </div>
        <Link href="/dashboard/promo-codes/new">
          <Button>
            <Plus className="mr-2 h-4 w-4" />
            Nouveau code promo
          </Button>
        </Link>
      </div>

      <PromoCodesTable promoCodes={promoCodes} />
    </div>
  )
}
