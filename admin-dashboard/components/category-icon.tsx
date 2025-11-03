import { 
  Wrench, 
  Zap, 
  Settings, 
  Car, 
  Filter, 
  Lightbulb, 
  Snowflake,
  Gauge,
  LucideIcon
} from 'lucide-react'

// Map Material Icons names to Lucide icons
const iconMap: Record<string, LucideIcon> = {
  build: Wrench,
  speed: Gauge,
  settings: Settings,
  flash_on: Zap,
  directions_car: Car,
  filter_list: Filter,
  lightbulb: Lightbulb,
  ac_unit: Snowflake,
}

interface CategoryIconProps {
  iconName: string | null
  className?: string
}

export function CategoryIcon({ iconName, className = "h-5 w-5" }: CategoryIconProps) {
  if (!iconName) return null
  
  const Icon = iconMap[iconName]
  
  if (!Icon) {
    // Fallback for unknown icons
    return <Settings className={className} />
  }
  
  return <Icon className={className} />
}
