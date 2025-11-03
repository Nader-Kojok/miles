'use client'

import { useState, Fragment, useMemo } from 'react'
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
import { Input } from '@/components/ui/input'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { Pencil, Trash2, ChevronDown, ChevronRight, Search, ChevronLeft, Filter } from 'lucide-react'
import { CategoryIcon } from '@/components/category-icon'

interface Category {
  id: string
  name: string
  slug: string
  icon: string | null
  description: string | null
  display_order: number
  is_active: boolean
  parent_id: string | null
}

export function CategoriesTable({ 
  mainCategories, 
  subcategories,
  onEdit
}: { 
  mainCategories: Category[]
  subcategories: Category[]
  onEdit: (category: Category) => void
}) {
  const router = useRouter()
  const supabase = createClient()
  const [expandedCategories, setExpandedCategories] = useState<Set<string>>(new Set())
  const [searchQuery, setSearchQuery] = useState('')
  const [statusFilter, setStatusFilter] = useState<string>('all')
  const [currentPage, setCurrentPage] = useState(1)
  const [itemsPerPage, setItemsPerPage] = useState(10)

  const toggleCategory = (categoryId: string) => {
    const newExpanded = new Set(expandedCategories)
    if (newExpanded.has(categoryId)) {
      newExpanded.delete(categoryId)
    } else {
      newExpanded.add(categoryId)
    }
    setExpandedCategories(newExpanded)
  }

  const handleDelete = async (id: string) => {
    if (!confirm('Êtes-vous sûr de vouloir supprimer cette catégorie ?')) return

    try {
      const { error } = await supabase.from('categories').delete().eq('id', id)
      if (error) throw error
      router.refresh()
    } catch (error) {
      console.error('Error deleting category:', error)
      alert('Erreur lors de la suppression')
    }
  }

  // Get subcategories for a parent
  const getSubcategories = (parentId: string) => {
    return subcategories.filter(sub => sub.parent_id === parentId)
  }

  // Filter and paginate categories
  const { filteredMainCategories, totalPages, paginatedCategories } = useMemo(() => {
    // Filter by search and status
    const filtered = mainCategories.filter(cat => {
      const matchesSearch = (
        cat.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
        cat.slug.toLowerCase().includes(searchQuery.toLowerCase())
      )
      const matchesStatus = statusFilter === 'all' || 
        (statusFilter === 'active' && cat.is_active) ||
        (statusFilter === 'inactive' && !cat.is_active)
      
      return matchesSearch && matchesStatus
    })

    // Calculate pagination
    const total = Math.ceil(filtered.length / itemsPerPage)
    const startIndex = (currentPage - 1) * itemsPerPage
    const paginated = filtered.slice(startIndex, startIndex + itemsPerPage)

    return {
      filteredMainCategories: filtered,
      totalPages: total,
      paginatedCategories: paginated
    }
  }, [mainCategories, searchQuery, statusFilter, currentPage, itemsPerPage])

  // Reset to page 1 when filters change
  const handleSearchChange = (value: string) => {
    setSearchQuery(value)
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

  if (mainCategories.length === 0) {
    return (
      <Card>
        <CardContent className="flex flex-col items-center justify-center py-12">
          <p className="text-slate-500">Aucune catégorie trouvée</p>
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
                placeholder="Rechercher une catégorie..."
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
              </SelectContent>
            </Select>
          </div>
          
          <div className="flex items-center gap-2">
            <Filter className="h-4 w-4 text-slate-500" />
            <Select value={statusFilter} onValueChange={handleStatusFilterChange}>
              <SelectTrigger className="w-full sm:w-[180px]">
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
        
        <div className="mt-3 text-sm text-slate-600">
          {filteredMainCategories.length} catégorie{filteredMainCategories.length !== 1 ? 's' : ''} trouvée{filteredMainCategories.length !== 1 ? 's' : ''}
        </div>
      </CardContent>

      <CardContent className="p-0">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead className="w-12"></TableHead>
              <TableHead>Nom</TableHead>
              <TableHead>Slug</TableHead>
              <TableHead>Sous-catégories</TableHead>
              <TableHead>Statut</TableHead>
              <TableHead className="text-right">Actions</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {paginatedCategories.map((category) => {
              const subs = getSubcategories(category.id)
              const isExpanded = expandedCategories.has(category.id)

              return (
                <Fragment key={category.id}>
                  {/* Main Category Row */}
                  <TableRow className="bg-slate-50/50">
                    <TableCell>
                      {subs.length > 0 && (
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => toggleCategory(category.id)}
                          className="h-8 w-8 p-0"
                        >
                          {isExpanded ? (
                            <ChevronDown className="h-4 w-4" />
                          ) : (
                            <ChevronRight className="h-4 w-4" />
                          )}
                        </Button>
                      )}
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-lg bg-gradient-to-br from-blue-500 to-blue-600 flex items-center justify-center text-white">
                          <CategoryIcon iconName={category.icon} className="h-5 w-5" />
                        </div>
                        <span className="font-semibold">{category.name}</span>
                      </div>
                    </TableCell>
                    <TableCell>
                      <code className="text-sm text-slate-600">{category.slug}</code>
                    </TableCell>
                    <TableCell>
                      <Badge variant="secondary" className="bg-blue-100 text-blue-700">
                        {subs.length} sous-catégories
                      </Badge>
                    </TableCell>
                    <TableCell>
                      <Badge variant={category.is_active ? 'default' : 'secondary'}>
                        {category.is_active ? 'Actif' : 'Inactif'}
                      </Badge>
                    </TableCell>
                    <TableCell className="text-right">
                      <div className="flex justify-end gap-2">
                        <Button variant="ghost" size="sm" onClick={() => onEdit(category)}>
                          <Pencil className="h-4 w-4" />
                        </Button>
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => handleDelete(category.id)}
                          className="text-red-600 hover:text-red-700"
                        >
                          <Trash2 className="h-4 w-4" />
                        </Button>
                      </div>
                    </TableCell>
                  </TableRow>

                  {/* Subcategories Rows */}
                  {isExpanded && subs.map((subcat) => (
                    <TableRow key={subcat.id} className="bg-white">
                      <TableCell></TableCell>
                      <TableCell>
                        <div className="flex items-center gap-3 pl-8">
                          <div className="w-2 h-2 rounded-full bg-slate-300"></div>
                          <span className="text-sm">{subcat.name}</span>
                        </div>
                      </TableCell>
                      <TableCell>
                        <code className="text-xs text-slate-500">{subcat.slug}</code>
                      </TableCell>
                      <TableCell>
                        <Badge variant="outline" className="text-xs">
                          #{subcat.display_order}
                        </Badge>
                      </TableCell>
                      <TableCell>
                        <Badge variant={subcat.is_active ? 'default' : 'secondary'} className="text-xs">
                          {subcat.is_active ? 'Actif' : 'Inactif'}
                        </Badge>
                      </TableCell>
                      <TableCell className="text-right">
                        <div className="flex justify-end gap-2">
                          <Button variant="ghost" size="sm" onClick={() => onEdit(subcat)}>
                            <Pencil className="h-3 w-3" />
                          </Button>
                          <Button
                            variant="ghost"
                            size="sm"
                            onClick={() => handleDelete(subcat.id)}
                            className="text-red-600 hover:text-red-700"
                          >
                            <Trash2 className="h-3 w-3" />
                          </Button>
                        </div>
                      </TableCell>
                    </TableRow>
                  ))}
                </Fragment>
              )
            })}
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
