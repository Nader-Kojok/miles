'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Checkbox } from '@/components/ui/checkbox'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'

export function PromoCodeForm() {
  const router = useRouter()
  const supabase = createClient()
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const [formData, setFormData] = useState({
    code: '',
    description: '',
    type: 'percentage' as 'percentage' | 'fixed_amount',
    value: 0,
    min_purchase_amount: 0,
    max_discount_amount: 0,
    usage_limit: 0,
    is_active: true,
    valid_from: '',
    valid_until: '',
    has_min_purchase: false,
    has_max_discount: false,
    has_usage_limit: false,
    has_validity: false,
  })

  const generateCode = () => {
    const code = Math.random().toString(36).substring(2, 10).toUpperCase()
    setFormData({ ...formData, code })
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError(null)

    try {
      const promoData = {
        code: formData.code.toUpperCase(),
        description: formData.description || null,
        type: formData.type,
        value: Number(formData.value),
        min_purchase_amount: formData.has_min_purchase ? Number(formData.min_purchase_amount) : null,
        max_discount_amount: formData.has_max_discount ? Number(formData.max_discount_amount) : null,
        usage_limit: formData.has_usage_limit ? Number(formData.usage_limit) : null,
        is_active: formData.is_active,
        valid_from: formData.has_validity && formData.valid_from ? new Date(formData.valid_from).toISOString() : null,
        valid_until: formData.has_validity && formData.valid_until ? new Date(formData.valid_until).toISOString() : null,
      }

      const { error } = await supabase.from('promo_codes').insert([promoData])

      if (error) throw error

      router.push('/dashboard/promo-codes')
      router.refresh()
    } catch (err: any) {
      setError(err.message || 'Une erreur est survenue')
      console.error('Error creating promo code:', err)
    } finally {
      setLoading(false)
    }
  }

  return (
    <form onSubmit={handleSubmit}>
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2 space-y-6">
          <Card>
            <CardHeader>
              <CardTitle>Informations du code</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div>
                <Label htmlFor="code">Code promo *</Label>
                <div className="flex gap-2">
                  <Input
                    id="code"
                    value={formData.code}
                    onChange={(e) => setFormData({ ...formData, code: e.target.value.toUpperCase() })}
                    required
                    placeholder="BIENVENUE10"
                    className="uppercase"
                  />
                  <Button type="button" variant="outline" onClick={generateCode}>
                    Générer
                  </Button>
                </div>
              </div>

              <div>
                <Label htmlFor="description">Description</Label>
                <Textarea
                  id="description"
                  value={formData.description}
                  onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                  rows={3}
                  placeholder="Décrivez la promotion..."
                />
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Réduction</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div>
                <Label>Type de réduction *</Label>
                <Select
                  value={formData.type}
                  onValueChange={(value: 'percentage' | 'fixed_amount') =>
                    setFormData({ ...formData, type: value })
                  }
                >
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="percentage">Pourcentage (%)</SelectItem>
                    <SelectItem value="fixed_amount">Montant fixe (FCFA)</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              <div>
                <Label htmlFor="value">
                  Valeur * {formData.type === 'percentage' ? '(%)' : '(FCFA)'}
                </Label>
                <Input
                  id="value"
                  type="number"
                  value={formData.value}
                  onChange={(e) => setFormData({ ...formData, value: Number(e.target.value) })}
                  required
                  min="0"
                  max={formData.type === 'percentage' ? 100 : undefined}
                  step={formData.type === 'percentage' ? 1 : 100}
                />
              </div>

              <div className="space-y-4 pt-4 border-t">
                <div className="flex items-center space-x-2">
                  <Checkbox
                    id="has_min_purchase"
                    checked={formData.has_min_purchase}
                    onCheckedChange={(checked) =>
                      setFormData({ ...formData, has_min_purchase: checked === true })
                    }
                  />
                  <Label htmlFor="has_min_purchase" className="cursor-pointer">
                    Montant minimum d&apos;achat
                  </Label>
                </div>
                {formData.has_min_purchase && (
                  <Input
                    type="number"
                    value={formData.min_purchase_amount}
                    onChange={(e) =>
                      setFormData({ ...formData, min_purchase_amount: Number(e.target.value) })
                    }
                    min="0"
                    step="100"
                    placeholder="Ex: 10000 FCFA"
                  />
                )}

                {formData.type === 'percentage' && (
                  <>
                    <div className="flex items-center space-x-2">
                      <Checkbox
                        id="has_max_discount"
                        checked={formData.has_max_discount}
                        onCheckedChange={(checked) =>
                          setFormData({ ...formData, has_max_discount: checked === true })
                        }
                      />
                      <Label htmlFor="has_max_discount" className="cursor-pointer">
                        Réduction maximale
                      </Label>
                    </div>
                    {formData.has_max_discount && (
                      <Input
                        type="number"
                        value={formData.max_discount_amount}
                        onChange={(e) =>
                          setFormData({ ...formData, max_discount_amount: Number(e.target.value) })
                        }
                        min="0"
                        step="100"
                        placeholder="Ex: 5000 FCFA"
                      />
                    )}
                  </>
                )}
              </div>
            </CardContent>
          </Card>
        </div>

        <div className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle>Limitations</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="flex items-center space-x-2">
                <Checkbox
                  id="has_usage_limit"
                  checked={formData.has_usage_limit}
                  onCheckedChange={(checked) =>
                    setFormData({ ...formData, has_usage_limit: checked === true })
                  }
                />
                <Label htmlFor="has_usage_limit" className="cursor-pointer">
                  Limiter les utilisations
                </Label>
              </div>
              {formData.has_usage_limit && (
                <Input
                  type="number"
                  value={formData.usage_limit}
                  onChange={(e) => setFormData({ ...formData, usage_limit: Number(e.target.value) })}
                  min="1"
                  placeholder="Ex: 100"
                />
              )}
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Validité</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="flex items-center space-x-2">
                <Checkbox
                  id="has_validity"
                  checked={formData.has_validity}
                  onCheckedChange={(checked) =>
                    setFormData({ ...formData, has_validity: checked === true })
                  }
                />
                <Label htmlFor="has_validity" className="cursor-pointer">
                  Définir une période
                </Label>
              </div>
              {formData.has_validity && (
                <>
                  <div>
                    <Label htmlFor="valid_from">Date de début</Label>
                    <Input
                      id="valid_from"
                      type="datetime-local"
                      value={formData.valid_from}
                      onChange={(e) => setFormData({ ...formData, valid_from: e.target.value })}
                    />
                  </div>
                  <div>
                    <Label htmlFor="valid_until">Date de fin</Label>
                    <Input
                      id="valid_until"
                      type="datetime-local"
                      value={formData.valid_until}
                      onChange={(e) => setFormData({ ...formData, valid_until: e.target.value })}
                    />
                  </div>
                </>
              )}
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Statut</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="flex items-center space-x-2">
                <Checkbox
                  id="is_active"
                  checked={formData.is_active}
                  onCheckedChange={(checked) =>
                    setFormData({ ...formData, is_active: checked === true })
                  }
                />
                <Label htmlFor="is_active" className="cursor-pointer">
                  Activer immédiatement
                </Label>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>

      {error && (
        <div className="mt-6 text-sm text-red-600 bg-red-50 p-4 rounded-md">
          {error}
        </div>
      )}

      <div className="flex items-center gap-4 mt-6">
        <Button type="submit" disabled={loading} size="lg">
          {loading ? 'Création...' : 'Créer le code promo'}
        </Button>
        <Button
          type="button"
          variant="outline"
          onClick={() => router.push('/dashboard/promo-codes')}
          disabled={loading}
        >
          Annuler
        </Button>
      </div>
    </form>
  )
}
