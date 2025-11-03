'use client'

import { useEffect, useState } from 'react'
import { createClient } from '@/lib/supabase/client'
import { CategoriesTable } from './categories-table'
import { CategoryForm } from './category-form'
import { Button } from '@/components/ui/button'
import { Card, CardContent } from '@/components/ui/card'
import { Plus, FolderTree, Layers } from 'lucide-react'

interface Category {
  id: string
  name: string
  slug: string
  icon: string | null
  description: string | null
  parent_id: string | null
  display_order: number
  is_active: boolean
}

export default function CategoriesPage() {
  const supabase = createClient()
  const [mainCategories, setMainCategories] = useState<Category[]>([])
  const [subcategories, setSubcategories] = useState<Category[]>([])
  const [stats, setStats] = useState({ total: 0, main: 0, sub: 0 })
  const [modalOpen, setModalOpen] = useState(false)
  const [editingCategory, setEditingCategory] = useState<Category | undefined>(undefined)

  const fetchCategories = async () => {
    const { data: categories, error } = await supabase
      .from('categories')
      .select('*')
      .order('display_order', { ascending: true })

    if (error) {
      console.error('Error fetching categories:', error)
      return
    }

    const main = categories?.filter(cat => !cat.parent_id) || []
    const sub = categories?.filter(cat => cat.parent_id) || []

    setMainCategories(main)
    setSubcategories(sub)
    setStats({
      total: categories?.length || 0,
      main: main.length,
      sub: sub.length
    })
  }

  useEffect(() => {
    fetchCategories()
  }, [])

  const handleOpenNew = () => {
    setEditingCategory(undefined)
    setModalOpen(true)
  }

  const handleOpenEdit = (category: Category) => {
    setEditingCategory(category)
    setModalOpen(true)
  }

  const handleSuccess = () => {
    fetchCategories()
  }

  return (
    <div className="p-8">
      {/* Header */}
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-3xl font-bold text-slate-900">Catégories</h1>
          <p className="text-slate-600 mt-1">
            Gérez vos {stats.main} catégories principales et {stats.sub} sous-catégories
          </p>
        </div>
        <Button onClick={handleOpenNew}>
          <Plus className="mr-2 h-4 w-4" />
          Nouvelle catégorie
        </Button>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <Card className="card-hover">
          <CardContent className="p-6">
            <div className="flex items-center gap-4">
              <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-blue-500 to-blue-600 flex items-center justify-center text-white">
                <Layers className="h-6 w-6" />
              </div>
              <div>
                <p className="text-sm text-slate-600">Total</p>
                <p className="text-2xl font-bold text-slate-900">{stats.total}</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="card-hover">
          <CardContent className="p-6">
            <div className="flex items-center gap-4">
              <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-green-500 to-green-600 flex items-center justify-center text-white">
                <FolderTree className="h-6 w-6" />
              </div>
              <div>
                <p className="text-sm text-slate-600">Catégories principales</p>
                <p className="text-2xl font-bold text-slate-900">{stats.main}</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="card-hover">
          <CardContent className="p-6">
            <div className="flex items-center gap-4">
              <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-purple-500 to-purple-600 flex items-center justify-center text-white">
                <Layers className="h-6 w-6" />
              </div>
              <div>
                <p className="text-sm text-slate-600">Sous-catégories</p>
                <p className="text-2xl font-bold text-slate-900">{stats.sub}</p>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Categories Table */}
      <CategoriesTable 
        mainCategories={mainCategories} 
        subcategories={subcategories}
        onEdit={handleOpenEdit}
      />

      {/* Category Form Modal */}
      <CategoryForm
        category={editingCategory}
        categories={mainCategories}
        open={modalOpen}
        onOpenChange={setModalOpen}
        onSuccess={handleSuccess}
      />
    </div>
  )
}
