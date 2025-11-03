'use client'

import { useState, useMemo } from 'react'
import Link from 'next/link'
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
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import { MoreHorizontal, Pencil, Trash2, Search, ChevronLeft, ChevronRight, Filter } from 'lucide-react'
import { Card, CardContent } from '@/components/ui/card'
import Image from 'next/image'

interface Product {
  id: string
  name: string
  price: number
  stock_quantity: number
  in_stock: boolean
  is_active: boolean
  is_featured: boolean
  image_url: string | null
  categories: { name: string } | null
}

export function ProductsTable({ products }: { products: Product[] }) {
  const router = useRouter()
  const supabase = createClient()
  const [deleting, setDeleting] = useState<string | null>(null)
  const [searchQuery, setSearchQuery] = useState('')
  const [categoryFilter, setCategoryFilter] = useState<string>('all')
  const [stockFilter, setStockFilter] = useState<string>('all')
  const [statusFilter, setStatusFilter] = useState<string>('all')
  const [currentPage, setCurrentPage] = useState(1)
  const [itemsPerPage, setItemsPerPage] = useState(10)

  // Get unique categories
  const categories = useMemo(() => {
    const uniqueCategories = new Set(products.map(p => p.categories?.name).filter(Boolean))
    return Array.from(uniqueCategories)
  }, [products])

  // Filter and paginate products
  const { filteredProducts, totalPages, paginatedProducts } = useMemo(() => {
    // Filter by search query
    let filtered = products.filter(product => {
      const searchLower = searchQuery.toLowerCase()
      const matchesSearch = product.name.toLowerCase().includes(searchLower)
      const matchesCategory = categoryFilter === 'all' || product.categories?.name === categoryFilter
      const matchesStatus = statusFilter === 'all' || 
        (statusFilter === 'active' && product.is_active) ||
        (statusFilter === 'inactive' && !product.is_active)
      
      let matchesStock = true
      if (stockFilter === 'in_stock') {
        matchesStock = product.stock_quantity > 10
      } else if (stockFilter === 'low_stock') {
        matchesStock = product.stock_quantity > 0 && product.stock_quantity <= 10
      } else if (stockFilter === 'out_of_stock') {
        matchesStock = product.stock_quantity === 0
      }
      
      return matchesSearch && matchesCategory && matchesStatus && matchesStock
    })

    // Calculate pagination
    const total = Math.ceil(filtered.length / itemsPerPage)
    const startIndex = (currentPage - 1) * itemsPerPage
    const paginated = filtered.slice(startIndex, startIndex + itemsPerPage)

    return {
      filteredProducts: filtered,
      totalPages: total,
      paginatedProducts: paginated
    }
  }, [products, searchQuery, categoryFilter, stockFilter, statusFilter, currentPage, itemsPerPage])

  // Reset to page 1 when filters change
  const handleSearchChange = (value: string) => {
    setSearchQuery(value)
    setCurrentPage(1)
  }

  const handleCategoryFilterChange = (value: string) => {
    setCategoryFilter(value)
    setCurrentPage(1)
  }

  const handleStockFilterChange = (value: string) => {
    setStockFilter(value)
    setCurrentPage(1)
  }

  const handleStatusFilterChange = (value: string) => {
    setStatusFilter(value)
    setCurrentPage(1)
  }

  const handleItemsPerPageChange = (value: string) => {
    setItemsPerPage(Number(value))
    setCurrentPage(1)
  }

  const handleDelete = async (id: string) => {
    if (!confirm('Êtes-vous sûr de vouloir supprimer ce produit ?')) return

    setDeleting(id)
    try {
      const { error } = await supabase.from('products').delete().eq('id', id)
      
      if (error) throw error
      
      router.refresh()
    } catch (error) {
      console.error('Error deleting product:', error)
      alert('Erreur lors de la suppression du produit')
    } finally {
      setDeleting(null)
    }
  }

  const toggleStatus = async (id: string, currentStatus: boolean) => {
    try {
      const { error } = await supabase
        .from('products')
        .update({ is_active: !currentStatus })
        .eq('id', id)
      
      if (error) throw error
      
      router.refresh()
    } catch (error) {
      console.error('Error updating product:', error)
      alert('Erreur lors de la mise à jour du produit')
    }
  }

  if (products.length === 0) {
    return (
      <Card>
        <CardContent className="flex flex-col items-center justify-center py-12">
          <p className="text-slate-500 mb-4">Aucun produit trouvé</p>
          <Link href="/dashboard/products/new">
            <Button>Ajouter votre premier produit</Button>
          </Link>
        </CardContent>
      </Card>
    )
  }

  return (
    <Card>
      {/* Search and Filters */}
      <CardContent className="p-6 border-b">
        <div className="flex flex-col gap-4">
          <div className="flex flex-col sm:flex-row gap-4">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-slate-400" />
              <Input
                placeholder="Rechercher un produit..."
                value={searchQuery}
                onChange={(e) => handleSearchChange(e.target.value)}
                className="pl-10"
              />
            </div>
            <Select value={itemsPerPage.toString()} onValueChange={handleItemsPerPageChange}>
              <SelectTrigger className="w-[140px]">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="10">10 par page</SelectItem>
                <SelectItem value="25">25 par page</SelectItem>
                <SelectItem value="50">50 par page</SelectItem>
                <SelectItem value="100">100 par page</SelectItem>
              </SelectContent>
            </Select>
          </div>
          
          <div className="flex flex-col sm:flex-row gap-4">
            <div className="flex items-center gap-2 flex-1 flex-wrap">
              <Filter className="h-4 w-4 text-slate-500" />
              <Select value={categoryFilter} onValueChange={handleCategoryFilterChange}>
                <SelectTrigger className="w-full sm:w-[160px]">
                  <SelectValue placeholder="Catégorie" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">Toutes catégories</SelectItem>
                  {categories.map(cat => (
                    <SelectItem key={cat} value={cat!}>{cat}</SelectItem>
                  ))}
                </SelectContent>
              </Select>
              
              <Select value={stockFilter} onValueChange={handleStockFilterChange}>
                <SelectTrigger className="w-full sm:w-[160px]">
                  <SelectValue placeholder="Stock" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">Tous les stocks</SelectItem>
                  <SelectItem value="in_stock">En stock (&gt;10)</SelectItem>
                  <SelectItem value="low_stock">Stock faible (1-10)</SelectItem>
                  <SelectItem value="out_of_stock">Épuisé (0)</SelectItem>
                </SelectContent>
              </Select>
              
              <Select value={statusFilter} onValueChange={handleStatusFilterChange}>
                <SelectTrigger className="w-full sm:w-[160px]">
                  <SelectValue placeholder="Statut" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">Tous les statuts</SelectItem>
                  <SelectItem value="active">Actif</SelectItem>
                  <SelectItem value="inactive">Inactif</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>
        </div>
        
        <div className="mt-3 text-sm text-slate-600">
          {filteredProducts.length} produit{filteredProducts.length !== 1 ? 's' : ''} trouvé{filteredProducts.length !== 1 ? 's' : ''}
        </div>
      </CardContent>

      <CardContent className="p-0">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Produit</TableHead>
              <TableHead>Catégorie</TableHead>
              <TableHead>Prix</TableHead>
              <TableHead>Stock</TableHead>
              <TableHead>Statut</TableHead>
              <TableHead className="text-right">Actions</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {paginatedProducts.map((product) => (
              <TableRow key={product.id}>
                <TableCell>
                  <div className="flex items-center gap-3">
                    <div className="w-12 h-12 bg-slate-100 rounded-lg overflow-hidden flex-shrink-0">
                      {product.image_url ? (
                        <Image
                          src={product.image_url}
                          alt={product.name}
                          width={48}
                          height={48}
                          className="object-cover w-full h-full"
                        />
                      ) : (
                        <div className="w-full h-full flex items-center justify-center text-slate-400">
                          📦
                        </div>
                      )}
                    </div>
                    <div>
                      <p className="font-medium text-slate-900">{product.name}</p>
                      {product.is_featured && (
                        <Badge variant="secondary" className="mt-1">
                          En vedette
                        </Badge>
                      )}
                    </div>
                  </div>
                </TableCell>
                <TableCell>
                  <span className="text-slate-600">
                    {product.categories?.name || 'Non catégorisé'}
                  </span>
                </TableCell>
                <TableCell>
                  <span className="font-medium">{product.price.toLocaleString('fr-FR')} FCFA</span>
                </TableCell>
                <TableCell>
                  <Badge variant={product.stock_quantity > 10 ? 'default' : 'destructive'}>
                    {product.stock_quantity} unités
                  </Badge>
                </TableCell>
                <TableCell>
                  <button
                    onClick={() => toggleStatus(product.id, product.is_active)}
                    className={`px-2 py-1 text-xs rounded-full font-medium ${
                      product.is_active
                        ? 'bg-green-100 text-green-800 hover:bg-green-200'
                        : 'bg-slate-100 text-slate-800 hover:bg-slate-200'
                    }`}
                  >
                    {product.is_active ? 'Actif' : 'Inactif'}
                  </button>
                </TableCell>
                <TableCell className="text-right">
                  <DropdownMenu>
                    <DropdownMenuTrigger asChild>
                      <Button variant="ghost" size="sm">
                        <MoreHorizontal className="h-4 w-4" />
                      </Button>
                    </DropdownMenuTrigger>
                    <DropdownMenuContent align="end">
                      <DropdownMenuItem asChild>
                        <Link href={`/dashboard/products/${product.id}`}>
                          <Pencil className="mr-2 h-4 w-4" />
                          Modifier
                        </Link>
                      </DropdownMenuItem>
                      <DropdownMenuItem
                        onClick={() => handleDelete(product.id)}
                        disabled={deleting === product.id}
                        className="text-red-600"
                      >
                        <Trash2 className="mr-2 h-4 w-4" />
                        Supprimer
                      </DropdownMenuItem>
                    </DropdownMenuContent>
                  </DropdownMenu>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </CardContent>

      {/* Pagination */}
      {totalPages > 1 && (
        <CardContent className="p-6 border-t">
          <div className="flex items-center justify-between">
            <div className="text-sm text-slate-600">
              Page {currentPage} sur {totalPages}
            </div>
            <div className="flex gap-2">
              <Button
                variant="outline"
                size="sm"
                onClick={() => setCurrentPage(p => Math.max(1, p - 1))}
                disabled={currentPage === 1}
              >
                <ChevronLeft className="h-4 w-4" />
                Précédent
              </Button>
              <Button
                variant="outline"
                size="sm"
                onClick={() => setCurrentPage(p => Math.min(totalPages, p + 1))}
                disabled={currentPage === totalPages}
              >
                Suivant
                <ChevronRight className="h-4 w-4" />
              </Button>
            </div>
          </div>
        </CardContent>
      )}
    </Card>
  )
}
