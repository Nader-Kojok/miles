'use client'

import { Package, ShoppingCart, Users, TrendingUp, LucideIcon } from 'lucide-react'
import { Card, CardContent } from '@/components/ui/card'
import { cn } from '@/lib/utils'

// Icon mapping
const iconMap: Record<string, LucideIcon> = {
  package: Package,
  'shopping-cart': ShoppingCart,
  users: Users,
  'trending-up': TrendingUp,
}

interface StatCardProps {
  title: string
  value: string | number
  iconName: string
  trend?: {
    value: number
    isPositive: boolean
  }
  color?: 'blue' | 'green' | 'purple' | 'orange' | 'red'
  delay?: number
}

const colorVariants = {
  blue: {
    bg: 'from-blue-500/10 to-blue-600/5',
    icon: 'text-blue-600',
    iconBg: 'bg-blue-500/10',
    glow: 'shadow-blue-500/20',
  },
  green: {
    bg: 'from-green-500/10 to-green-600/5',
    icon: 'text-green-600',
    iconBg: 'bg-green-500/10',
    glow: 'shadow-green-500/20',
  },
  purple: {
    bg: 'from-purple-500/10 to-purple-600/5',
    icon: 'text-purple-600',
    iconBg: 'bg-purple-500/10',
    glow: 'shadow-purple-500/20',
  },
  orange: {
    bg: 'from-orange-500/10 to-orange-600/5',
    icon: 'text-orange-600',
    iconBg: 'bg-orange-500/10',
    glow: 'shadow-orange-500/20',
  },
  red: {
    bg: 'from-red-500/10 to-red-600/5',
    icon: 'text-red-600',
    iconBg: 'bg-red-500/10',
    glow: 'shadow-red-500/20',
  },
}

export function StatCard({
  title,
  value,
  iconName,
  trend,
  color = 'blue',
  delay = 0,
}: StatCardProps) {
  const colors = colorVariants[color]
  const Icon = iconMap[iconName] || Package

  return (
    <Card
      className={cn(
        'card-hover animate-slide-in-up border-0',
        `bg-gradient-to-br ${colors.bg}`,
        'backdrop-blur-sm relative overflow-hidden group'
      )}
      style={{ animationDelay: `${delay}ms` }}
    >
      {/* Animated background gradient */}
      <div className="absolute inset-0 bg-gradient-to-r from-transparent via-white/5 to-transparent -translate-x-full group-hover:translate-x-full transition-transform duration-1000" />
      
      <CardContent className="p-6 relative">
        <div className="flex items-start justify-between">
          <div className="flex-1">
            <p className="text-sm font-medium text-gray-600 mb-1">{title}</p>
            <div className="flex items-baseline gap-2">
              <h3 className="text-3xl font-bold text-gray-900">
                {typeof value === 'number' ? value.toLocaleString('fr-FR') : value}
              </h3>
              {trend && (
                <span
                  className={cn(
                    'text-sm font-medium flex items-center gap-1',
                    trend.isPositive ? 'text-green-600' : 'text-red-600'
                  )}
                >
                  {trend.isPositive ? '↑' : '↓'} {Math.abs(trend.value)}%
                </span>
              )}
            </div>
          </div>
          
          <div className={cn(
            'p-3 rounded-xl smooth-transition group-hover:scale-110',
            colors.iconBg
          )}>
            <Icon className={cn('h-6 w-6', colors.icon)} />
          </div>
        </div>
      </CardContent>
      
      {/* Bottom glow effect */}
      <div className={cn(
        'absolute bottom-0 left-0 right-0 h-1 bg-gradient-to-r opacity-0 group-hover:opacity-100 transition-opacity',
        colors.bg
      )} />
    </Card>
  )
}
