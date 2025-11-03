'use client'

import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Checkbox } from '@/components/ui/checkbox'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'

interface Category {
  id?: string
  name: string
  slug: string
  icon: string | null
  description: string | null
  parent_id: string | null
  display_order: number
  is_active: boolean
}

interface CategoryFormProps {
  category?: Category
  categories?: Category[]
  open: boolean
  onOpenChange: (open: boolean) => void
  onSuccess?: () => void
}

export function CategoryForm({ category, categories = [], open, onOpenChange, onSuccess }: CategoryFormProps) {
  const router = useRouter()
  const supabase = createClient()
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const [formData, setFormData] = useState({
    name: category?.name || '',
    slug: category?.slug || '',
    icon: category?.icon || '',
    description: category?.description || '',
    parent_id: category?.parent_id || 'none',
    display_order: category?.display_order || 0,
    is_active: category?.is_active ?? true,
  })

  // Reset form when category changes or modal opens
  useEffect(() => {
    if (open) {
      setFormData({
        name: category?.name || '',
        slug: category?.slug || '',
        icon: category?.icon || '',
        description: category?.description || '',
        parent_id: category?.parent_id || 'none',
        display_order: category?.display_order || 0,
        is_active: category?.is_active ?? true,
      })
      setError(null)
    }
  }, [category, open])

  const generateSlug = (name: string) => {
    return name
      .toLowerCase()
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/(^-|-$)/g, '')
  }

  const handleNameChange = (name: string) => {
    setFormData((prev) => ({
      ...prev,
      name,
      slug: category ? prev.slug : generateSlug(name),
    }))
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError(null)

    try {
      const categoryData = {
        name: formData.name,
        slug: formData.slug,
        icon: formData.icon || null,
        description: formData.description || null,
        parent_id: formData.parent_id === 'none' ? null : formData.parent_id,
        display_order: Number(formData.display_order),
        is_active: formData.is_active,
      }

      if (category?.id) {
        // Update existing category
        const { error } = await supabase
          .from('categories')
          .update(categoryData)
          .eq('id', category.id)

        if (error) throw error
      } else {
        // Create new category
        const { error } = await supabase
          .from('categories')
          .insert([categoryData])

        if (error) throw error
      }

      onOpenChange(false)
      router.refresh()
      if (onSuccess) onSuccess()
    } catch (err: any) {
      setError(err.message || 'Une erreur est survenue')
    } finally {
      setLoading(false)
    }
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>{category ? 'Modifier la catégorie' : 'Nouvelle catégorie'}</DialogTitle>
          <DialogDescription>
            {category ? 'Mettez à jour les informations de la catégorie' : 'Ajoutez une nouvelle catégorie ou sous-catégorie'}
          </DialogDescription>
        </DialogHeader>

        <form onSubmit={handleSubmit} className="space-y-6">
          {error && (
            <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded">
              {error}
            </div>
          )}

          <Card>
        <CardHeader>
          <CardTitle>Informations générales</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div>
            <Label htmlFor="name">Nom de la catégorie *</Label>
            <Input
              id="name"
              value={formData.name}
              onChange={(e) => handleNameChange(e.target.value)}
              required
              placeholder="Ex: Pièces de moteur"
            />
          </div>

          <div>
            <Label htmlFor="slug">Slug *</Label>
            <Input
              id="slug"
              value={formData.slug}
              onChange={(e) => setFormData({ ...formData, slug: e.target.value })}
              required
              placeholder="pieces-de-moteur"
            />
            <p className="text-sm text-slate-500 mt-1">
              URL-friendly version du nom (généré automatiquement)
            </p>
          </div>

          <div>
            <Label htmlFor="icon">Icône (Material Icon name)</Label>
            <Input
              id="icon"
              value={formData.icon}
              onChange={(e) => setFormData({ ...formData, icon: e.target.value })}
              placeholder="build, speed, settings, etc."
            />
            <p className="text-sm text-slate-500 mt-1">
              Nom de l'icône Material (ex: build, speed, settings)
            </p>
          </div>

          <div>
            <Label htmlFor="description">Description</Label>
            <Textarea
              id="description"
              value={formData.description}
              onChange={(e) => setFormData({ ...formData, description: e.target.value })}
              placeholder="Description de la catégorie..."
              rows={4}
            />
          </div>

          <div>
            <Label htmlFor="parent_id">Catégorie parente</Label>
            <Select
              value={formData.parent_id}
              onValueChange={(value) => setFormData({ ...formData, parent_id: value })}
            >
              <SelectTrigger>
                <SelectValue placeholder="Aucune (catégorie principale)" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="none">Aucune (catégorie principale)</SelectItem>
                {categories
                  .filter(cat => !cat.parent_id && cat.id !== category?.id)
                  .map((cat) => (
                    <SelectItem key={cat.id} value={cat.id!}>
                      {cat.name}
                    </SelectItem>
                  ))}
              </SelectContent>
            </Select>
          </div>

          <div>
            <Label htmlFor="display_order">Ordre d'affichage</Label>
            <Input
              id="display_order"
              type="number"
              value={formData.display_order}
              onChange={(e) => setFormData({ ...formData, display_order: parseInt(e.target.value) })}
              min="0"
            />
          </div>

          <div className="flex items-center space-x-2">
            <Checkbox
              id="is_active"
              checked={formData.is_active}
              onCheckedChange={(checked: boolean) => setFormData({ ...formData, is_active: checked })}
            />
            <Label htmlFor="is_active">Catégorie active</Label>
          </div>
        </CardContent>
      </Card>

          <div className="flex gap-4">
            <Button type="submit" disabled={loading}>
              {loading ? 'Enregistrement...' : category ? 'Mettre à jour' : 'Créer la catégorie'}
            </Button>
            <Button type="button" variant="outline" onClick={() => onOpenChange(false)}>
              Annuler
            </Button>
          </div>
        </form>
      </DialogContent>
    </Dialog>
  )
}
