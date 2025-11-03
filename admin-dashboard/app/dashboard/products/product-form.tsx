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

interface Category {
  id: string
  name: string
  parent_id: string | null
}

interface Product {
  id?: string
  name: string
  slug: string
  description: string | null
  price: number
  compare_at_price: number | null
  category_id: string | null
  image_url: string | null
  in_stock: boolean
  stock_quantity: number
  sku: string | null
  brand: string | null
  is_featured: boolean
  is_active: boolean
  tags: string[] | null
}

interface ProductFormProps {
  product?: Product
  categories: Category[]
}

export function ProductForm({ product, categories }: ProductFormProps) {
  const router = useRouter()
  const supabase = createClient()
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  // Initialize parent category based on product's category
  const getInitialParentCategory = () => {
    if (!product?.category_id || categories.length === 0) return ''
    const selectedCategory = categories.find(cat => cat.id === product.category_id)
    if (selectedCategory?.parent_id) {
      return selectedCategory.parent_id
    } else if (selectedCategory) {
      return selectedCategory.id
    }
    return ''
  }

  const [selectedParentCategory, setSelectedParentCategory] = useState<string>(getInitialParentCategory())
  const [formData, setFormData] = useState({
    name: product?.name || '',
    slug: product?.slug || '',
    description: product?.description || '',
    price: product?.price || 0,
    compare_at_price: product?.compare_at_price || 0,
    category_id: product?.category_id || '',
    image_url: product?.image_url || '',
    in_stock: product?.in_stock ?? true,
    stock_quantity: product?.stock_quantity || 0,
    sku: product?.sku || '',
    brand: product?.brand || '',
    is_featured: product?.is_featured ?? false,
    is_active: product?.is_active ?? true,
    tags: product?.tags?.join(', ') || '',
  })

  // Get parent categories
  const parentCategories = categories.filter(cat => !cat.parent_id)
  
  // Get subcategories for selected parent
  const subcategories = selectedParentCategory 
    ? categories.filter(cat => cat.parent_id === selectedParentCategory)
    : []

  // Initialize parent category selection when editing
  useEffect(() => {
    if (product?.category_id && categories.length > 0) {
      const selectedCategory = categories.find(cat => cat.id === product.category_id)
      if (selectedCategory) {
        if (selectedCategory.parent_id) {
          // If product has a subcategory selected, set the parent
          setSelectedParentCategory(selectedCategory.parent_id)
        } else {
          // If product has a parent category selected
          setSelectedParentCategory(selectedCategory.id)
        }
      }
    }
  }, [product?.category_id, categories])

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
      slug: product ? prev.slug : generateSlug(name),
    }))
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError(null)

    try {
      const tagsArray = formData.tags
        ? formData.tags.split(',').map((tag) => tag.trim()).filter(Boolean)
        : null

      const productData = {
        name: formData.name,
        slug: formData.slug,
        description: formData.description || null,
        price: Number(formData.price),
        compare_at_price: formData.compare_at_price ? Number(formData.compare_at_price) : null,
        category_id: formData.category_id || null,
        image_url: formData.image_url || null,
        in_stock: formData.in_stock,
        stock_quantity: Number(formData.stock_quantity),
        sku: formData.sku || null,
        brand: formData.brand || null,
        is_featured: formData.is_featured,
        is_active: formData.is_active,
        tags: tagsArray,
        updated_at: new Date().toISOString(),
      }

      if (product?.id) {
        // Update existing product
        const { error } = await supabase
          .from('products')
          .update(productData)
          .eq('id', product.id)

        if (error) throw error
      } else {
        // Create new product
        const { error } = await supabase
          .from('products')
          .insert([productData])

        if (error) throw error
      }

      router.push('/dashboard/products')
      router.refresh()
    } catch (err: any) {
      setError(err.message || 'Une erreur est survenue')
      console.error('Error saving product:', err)
    } finally {
      setLoading(false)
    }
  }

  return (
    <form onSubmit={handleSubmit}>
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Main Form */}
        <div className="lg:col-span-2 space-y-6">
          <Card>
            <CardHeader>
              <CardTitle>Informations générales</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div>
                <Label htmlFor="name">Nom du produit *</Label>
                <Input
                  id="name"
                  value={formData.name}
                  onChange={(e) => handleNameChange(e.target.value)}
                  required
                  placeholder="Ex: Plaquettes de frein avant"
                />
              </div>

              <div>
                <Label htmlFor="slug">Slug (URL) *</Label>
                <Input
                  id="slug"
                  value={formData.slug}
                  onChange={(e) => setFormData({ ...formData, slug: e.target.value })}
                  required
                  placeholder="plaquettes-frein-avant"
                />
              </div>

              <div>
                <Label htmlFor="description">Description</Label>
                <Textarea
                  id="description"
                  value={formData.description}
                  onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                  rows={5}
                  placeholder="Décrivez le produit en détail..."
                />
              </div>

              <div>
                <Label htmlFor="brand">Marque</Label>
                <Input
                  id="brand"
                  value={formData.brand}
                  onChange={(e) => setFormData({ ...formData, brand: e.target.value })}
                  placeholder="Ex: Brembo, Bosch, etc."
                />
              </div>

              <div>
                <Label htmlFor="tags">Tags (séparés par des virgules)</Label>
                <Input
                  id="tags"
                  value={formData.tags}
                  onChange={(e) => setFormData({ ...formData, tags: e.target.value })}
                  placeholder="freinage, ceramique, performance"
                />
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Prix et inventaire</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <Label htmlFor="price">Prix (FCFA) *</Label>
                  <Input
                    id="price"
                    type="number"
                    value={formData.price}
                    onChange={(e) => setFormData({ ...formData, price: Number(e.target.value) })}
                    required
                    min="0"
                    step="1"
                  />
                </div>

                <div>
                  <Label htmlFor="compare_at_price">Prix barré (FCFA)</Label>
                  <Input
                    id="compare_at_price"
                    type="number"
                    value={formData.compare_at_price}
                    onChange={(e) => setFormData({ ...formData, compare_at_price: Number(e.target.value) })}
                    min="0"
                    step="1"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <Label htmlFor="stock_quantity">Quantité en stock *</Label>
                  <Input
                    id="stock_quantity"
                    type="number"
                    value={formData.stock_quantity}
                    onChange={(e) => setFormData({ ...formData, stock_quantity: Number(e.target.value) })}
                    required
                    min="0"
                  />
                </div>

                <div>
                  <Label htmlFor="sku">SKU</Label>
                  <Input
                    id="sku"
                    value={formData.sku}
                    onChange={(e) => setFormData({ ...formData, sku: e.target.value })}
                    placeholder="BRK-001"
                  />
                </div>
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Sidebar */}
        <div className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle>Statut</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="flex items-center space-x-2">
                <Checkbox
                  id="is_active"
                  checked={formData.is_active}
                  onCheckedChange={(checked) =>
                    setFormData({ ...formData, is_active: checked === true })
                  }
                />
                <Label htmlFor="is_active" className="cursor-pointer">
                  Produit actif
                </Label>
              </div>

              <div className="flex items-center space-x-2">
                <Checkbox
                  id="in_stock"
                  checked={formData.in_stock}
                  onCheckedChange={(checked) =>
                    setFormData({ ...formData, in_stock: checked === true })
                  }
                />
                <Label htmlFor="in_stock" className="cursor-pointer">
                  En stock
                </Label>
              </div>

              <div className="flex items-center space-x-2">
                <Checkbox
                  id="is_featured"
                  checked={formData.is_featured}
                  onCheckedChange={(checked) =>
                    setFormData({ ...formData, is_featured: checked === true })
                  }
                />
                <Label htmlFor="is_featured" className="cursor-pointer">
                  Produit en vedette
                </Label>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Catégorie</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              {/* Parent Category Dropdown */}
              <div>
                <Label htmlFor="parent_category">Catégorie principale *</Label>
                <Select
                  value={selectedParentCategory}
                  onValueChange={(value) => {
                    setSelectedParentCategory(value)
                    // Reset subcategory selection when parent changes
                    setFormData({ ...formData, category_id: value })
                  }}
                >
                  <SelectTrigger id="parent_category">
                    <SelectValue placeholder="Sélectionnez une catégorie principale" />
                  </SelectTrigger>
                  <SelectContent>
                    {parentCategories.map((category) => (
                      <SelectItem key={category.id} value={category.id}>
                        {category.name}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>

              {/* Subcategory Dropdown - Only shown if parent has subcategories */}
              {subcategories.length > 0 && (
                <div>
                  <Label htmlFor="subcategory">Sous-catégorie (optionnel)</Label>
                  <Select
                    value={formData.category_id}
                    onValueChange={(value) => setFormData({ ...formData, category_id: value })}
                  >
                    <SelectTrigger id="subcategory">
                      <SelectValue placeholder="Sélectionnez une sous-catégorie" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value={selectedParentCategory}>
                        Aucune (utiliser la catégorie principale)
                      </SelectItem>
                      {subcategories.map((category) => (
                        <SelectItem key={category.id} value={category.id}>
                          {category.name}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
              )}
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Image</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-2">
                <Label htmlFor="image_url">URL de l&apos;image</Label>
                <Input
                  id="image_url"
                  value={formData.image_url}
                  onChange={(e) => setFormData({ ...formData, image_url: e.target.value })}
                  placeholder="https://..."
                />
                {formData.image_url && (
                  <div className="mt-4">
                    <img
                      src={formData.image_url}
                      alt="Preview"
                      className="w-full h-48 object-cover rounded-lg border"
                    />
                  </div>
                )}
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
          {loading ? 'Enregistrement...' : product ? 'Mettre à jour' : 'Créer le produit'}
        </Button>
        <Button
          type="button"
          variant="outline"
          onClick={() => router.push('/dashboard/products')}
          disabled={loading}
        >
          Annuler
        </Button>
      </div>
    </form>
  )
}
