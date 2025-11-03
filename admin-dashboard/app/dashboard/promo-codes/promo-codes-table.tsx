'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import { Badge } from '@/components/ui/badge'
import { Card, CardContent } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Copy, Trash2 } from 'lucide-react'
import { format } from 'date-fns'
import { fr } from 'date-fns/locale'

interface PromoCode {
  id: string
  code: string
  description: string | null
  type: 'percentage' | 'fixed_amount'
  value: number
  min_purchase_amount: number | null
  usage_limit: number | null
  usage_count: number
  is_active: boolean
  valid_from: string | null
  valid_until: string | null
  created_at: string
}

export function PromoCodesTable({ promoCodes }: { promoCodes: PromoCode[] }) {
  const router = useRouter()
  const supabase = createClient()
  const [copying, setCopying] = useState<string | null>(null)

  const handleCopy = async (code: string) => {
    setCopying(code)
    await navigator.clipboard.writeText(code)
    setTimeout(() => setCopying(null), 2000)
  }

  const handleDelete = async (id: string) => {
    if (!confirm('Êtes-vous sûr de vouloir supprimer ce code promo ?')) return

    try {
      const { error } = await supabase.from('promo_codes').delete().eq('id', id)
      if (error) throw error
      router.refresh()
    } catch (error) {
      console.error('Error deleting promo code:', error)
      alert('Erreur lors de la suppression')
    }
  }

  const toggleStatus = async (id: string, currentStatus: boolean) => {
    try {
      const { error } = await supabase
        .from('promo_codes')
        .update({ is_active: !currentStatus })
        .eq('id', id)
      
      if (error) throw error
      router.refresh()
    } catch (error) {
      console.error('Error updating promo code:', error)
      alert('Erreur lors de la mise à jour')
    }
  }

  const isExpired = (validUntil: string | null) => {
    if (!validUntil) return false
    return new Date(validUntil) < new Date()
  }

  if (promoCodes.length === 0) {
    return (
      <Card>
        <CardContent className="flex flex-col items-center justify-center py-12">
          <p className="text-slate-500 mb-4">Aucun code promo trouvé</p>
        </CardContent>
      </Card>
    )
  }

  return (
    <Card>
      <CardContent className="p-0">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Code</TableHead>
              <TableHead>Réduction</TableHead>
              <TableHead>Utilisations</TableHead>
              <TableHead>Validité</TableHead>
              <TableHead>Statut</TableHead>
              <TableHead className="text-right">Actions</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {promoCodes.map((promo) => (
              <TableRow key={promo.id}>
                <TableCell>
                  <div className="flex items-center gap-2">
                    <code className="bg-slate-100 px-2 py-1 rounded font-mono font-semibold text-sm">
                      {promo.code}
                    </code>
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => handleCopy(promo.code)}
                      className="h-6 w-6 p-0"
                    >
                      <Copy className="h-3 w-3" />
                    </Button>
                  </div>
                  {promo.description && (
                    <p className="text-sm text-slate-500 mt-1">{promo.description}</p>
                  )}
                </TableCell>
                <TableCell>
                  <div className="font-medium">
                    {promo.type === 'percentage'
                      ? `${promo.value}%`
                      : `${promo.value.toLocaleString('fr-FR')} FCFA`}
                  </div>
                  {promo.min_purchase_amount && (
                    <p className="text-xs text-slate-500">
                      Min: {promo.min_purchase_amount.toLocaleString('fr-FR')} FCFA
                    </p>
                  )}
                </TableCell>
                <TableCell>
                  <div>
                    <span className="font-medium">{promo.usage_count}</span>
                    {promo.usage_limit && (
                      <span className="text-slate-500"> / {promo.usage_limit}</span>
                    )}
                  </div>
                </TableCell>
                <TableCell>
                  {promo.valid_until ? (
                    <div className="text-sm">
                      <div>Jusqu&apos;au</div>
                      <div className="font-medium">
                        {format(new Date(promo.valid_until), 'dd MMM yyyy', { locale: fr })}
                      </div>
                    </div>
                  ) : (
                    <span className="text-slate-500">Illimité</span>
                  )}
                </TableCell>
                <TableCell>
                  <button
                    onClick={() => toggleStatus(promo.id, promo.is_active)}
                    className={`px-2 py-1 text-xs rounded-full font-medium ${
                      isExpired(promo.valid_until)
                        ? 'bg-slate-100 text-slate-600'
                        : promo.is_active
                        ? 'bg-green-100 text-green-800 hover:bg-green-200'
                        : 'bg-slate-100 text-slate-800 hover:bg-slate-200'
                    }`}
                    disabled={isExpired(promo.valid_until)}
                  >
                    {isExpired(promo.valid_until)
                      ? 'Expiré'
                      : promo.is_active
                      ? 'Actif'
                      : 'Inactif'}
                  </button>
                </TableCell>
                <TableCell className="text-right">
                  <Button
                    variant="ghost"
                    size="sm"
                    onClick={() => handleDelete(promo.id)}
                    className="text-red-600 hover:text-red-700"
                  >
                    <Trash2 className="h-4 w-4" />
                  </Button>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </CardContent>
    </Card>
  )
}
