'use client'

import Link from 'next/link'
import { usePathname, useRouter } from 'next/navigation'
import { cn } from '@/lib/utils'
import { 
  LayoutDashboard, 
  Package, 
  FolderTree, 
  ShoppingCart, 
  Users, 
  Tag,
  Bell,
  Settings,
  LogOut,
  Zap,
  BarChart3,
  Activity
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { createClient } from '@/lib/supabase/client'

const navigation = [
  { name: 'Tableau de bord', href: '/dashboard', icon: LayoutDashboard },
  { name: 'Analytics', href: '/dashboard/analytics', icon: BarChart3 },
  { name: 'État Système', href: '/dashboard/system-health', icon: Activity },
  { name: 'Produits', href: '/dashboard/products', icon: Package },
  { name: 'Catégories', href: '/dashboard/categories', icon: FolderTree },
  { name: 'Commandes', href: '/dashboard/orders', icon: ShoppingCart },
  { name: 'Utilisateurs', href: '/dashboard/users', icon: Users },
  { name: 'Codes promo', href: '/dashboard/promo-codes', icon: Tag },
  { name: 'Notifications', href: '/dashboard/notifications', icon: Bell },
  { name: 'Paramètres', href: '/dashboard/settings', icon: Settings },
]

export function Sidebar() {
  const pathname = usePathname()
  const router = useRouter()
  const supabase = createClient()

  const handleLogout = async () => {
    await supabase.auth.signOut()
    router.push('/login')
    router.refresh()
  }

  return (
    <div className="flex h-full w-64 flex-col bg-slate-900 text-white border-r border-slate-700">
      <div className="flex h-full flex-col">
        {/* Logo Header */}
        <div className="flex h-20 items-center justify-center px-6 border-b border-slate-700">
          <div className="flex items-center gap-3">
            <div className="relative">
              <div className="w-12 h-12 rounded-full bg-white flex items-center justify-center font-bold text-2xl text-black">
                B
              </div>
              <div className="absolute -top-1 -right-1 w-4 h-4 bg-green-500 rounded-full border-2 border-slate-900" />
            </div>
            <div>
              <h1 className="text-xl font-bold text-white">Bolide</h1>
              <p className="text-xs text-slate-400">Admin Dashboard</p>
            </div>
          </div>
        </div>
        {/* Navigation */}
        <nav className="flex-1 space-y-1 px-3 py-6 overflow-y-auto">
          {navigation.map((item) => {
            const isActive = pathname === item.href || (pathname?.startsWith(item.href + '/') && item.href !== '/dashboard')
            return (
              <Link
                key={item.name}
                href={item.href}
                className={cn(
                  'flex items-center gap-3 rounded-lg px-4 py-3 text-sm font-medium',
                  isActive
                    ? 'bg-white text-slate-900'
                    : 'text-slate-300 hover:bg-slate-800 hover:text-white'
                )}
              >
                <item.icon className="h-5 w-5" />
                <span>{item.name}</span>
              </Link>
            )
          })}
        </nav>
        {/* Logout Section */}
        <div className="border-t border-slate-700 p-4">
          <Button
            variant="ghost"
            className="w-full justify-start text-slate-300 hover:bg-slate-800 hover:text-white rounded-lg px-4 py-3"
            onClick={handleLogout}
          >
            <LogOut className="mr-3 h-5 w-5" />
            <span className="font-medium">Déconnexion</span>
          </Button>
          
          {/* Version info */}
          <div className="mt-3 text-center">
            <p className="text-xs text-slate-500 flex items-center justify-center gap-1">
              <Zap className="h-3 w-3" />
              v1.0.0
            </p>
          </div>
        </div>
      </div>
    </div>
  )
}
