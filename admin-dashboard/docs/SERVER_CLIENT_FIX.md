# 🔧 Server/Client Component Serialization Fix

## Issue

**Error Type**: Console Error + Runtime Error

**Error Message**:
```
Only plain objects can be passed to Client Components from Server Components. 
Classes or other objects with methods are not supported.

Functions cannot be passed directly to Client Components unless you explicitly 
expose it by marking it with "use server".
```

**Root Cause**: Passing Lucide icon components (which are React components/functions) from Server Components to Client Components.

---

## The Problem

In Next.js 13+ with Server Components, you cannot pass:
- ❌ React components
- ❌ Functions
- ❌ Class instances
- ❌ Objects with methods

From Server Components to Client Components.

### What Was Happening

```tsx
// ❌ WRONG - Server Component
import { Package } from 'lucide-react'

export default async function DashboardPage() {
  return (
    <StatCard
      title="Products"
      icon={Package}  // ❌ Passing component function
    />
  )
}
```

The `Package` component is a function, which cannot be serialized and passed from server to client.

---

## The Solution

### Strategy: Icon Name Mapping

Instead of passing icon components, pass **icon names as strings** and map them in the Client Component.

### Implementation

#### 1. Updated StatCard Component (Client Component)

**File**: `components/stat-card.tsx`

```tsx
'use client'

import { Package, ShoppingCart, Users, TrendingUp, LucideIcon } from 'lucide-react'

// Icon mapping in the client component
const iconMap: Record<string, LucideIcon> = {
  package: Package,
  'shopping-cart': ShoppingCart,
  users: Users,
  'trending-up': TrendingUp,
}

interface StatCardProps {
  title: string
  value: string | number
  iconName: string  // ✅ Changed from icon: LucideIcon
  // ... other props
}

export function StatCard({ iconName, ...props }: StatCardProps) {
  const Icon = iconMap[iconName] || Package  // Lookup icon by name
  
  return (
    // ... render with Icon component
    <Icon className="h-6 w-6" />
  )
}
```

#### 2. Updated Dashboard Page (Server Component)

**File**: `app/dashboard/page.tsx`

```tsx
// ✅ CORRECT - Server Component
export default async function DashboardPage() {
  return (
    <StatCard
      title="Total Produits"
      iconName="package"  // ✅ Passing string
      color="blue"
    />
  )
}
```

---

## Files Modified

### 1. `components/stat-card.tsx`
**Changes**:
- Added icon mapping object
- Changed prop from `icon: LucideIcon` to `iconName: string`
- Lookup icon from map using the string name

### 2. `app/dashboard/page.tsx`
**Changes**:
- Removed icon component imports (Package, Users, TrendingUp)
- Changed all `icon={IconComponent}` to `iconName="icon-name"`
- Kept only icons used directly in server component (Clock, ArrowUpRight, ShoppingCart)

---

## Icon Name Reference

Current icon mappings in `StatCard`:

| Icon Name | Lucide Component | Usage |
|-----------|------------------|-------|
| `package` | Package | Products stat |
| `shopping-cart` | ShoppingCart | Orders stat |
| `users` | Users | Users stat |
| `trending-up` | TrendingUp | Revenue stat |

---

## Pattern for Future Components

### When Creating New Components

**If passing icons from Server to Client:**

1. **Client Component** - Define icon map:
```tsx
'use client'

import { Icon1, Icon2 } from 'lucide-react'

const iconMap = {
  'icon-1': Icon1,
  'icon-2': Icon2,
}

interface Props {
  iconName: string  // Use string, not component
}

export function MyComponent({ iconName }: Props) {
  const Icon = iconMap[iconName] || DefaultIcon
  return <Icon />
}
```

2. **Server Component** - Pass string:
```tsx
export default async function Page() {
  return <MyComponent iconName="icon-1" />
}
```

---

## Why This Works

### Serialization Rules

✅ **Can be passed from Server to Client:**
- Strings
- Numbers
- Booleans
- Plain objects (JSON-serializable)
- Arrays of serializable values
- null/undefined

❌ **Cannot be passed:**
- Functions
- React components
- Class instances
- Symbols
- Objects with methods

### Our Solution

By passing **strings** (serializable) instead of **components** (not serializable), we comply with Next.js serialization rules while maintaining the same functionality.

---

## Testing

### Verify Fix

1. **Check Console**: No serialization errors
2. **Check UI**: Icons display correctly
3. **Check Network**: No hydration mismatches

### Test Cases

- ✅ Dashboard stats cards show correct icons
- ✅ No console errors about serialization
- ✅ Icons render on initial page load
- ✅ Icons render after navigation
- ✅ Hover effects work correctly

---

## Related Patterns

### CategoryIcon Component

Similar pattern used in `components/category-icon.tsx`:

```tsx
// Maps Material Icons names to Lucide icons
const iconMap: Record<string, LucideIcon> = {
  build: Wrench,
  speed: Gauge,
  // ...
}

export function CategoryIcon({ iconName }: { iconName: string | null }) {
  const Icon = iconMap[iconName] || Settings
  return <Icon />
}
```

This allows the Flutter app to use Material Icons while the admin dashboard uses Lucide icons.

---

## Best Practices

### Do's ✅

1. **Pass primitive values** (strings, numbers) from Server to Client
2. **Define icon maps** in Client Components
3. **Use descriptive icon names** (kebab-case recommended)
4. **Provide fallback icons** for unknown names
5. **Document icon mappings** for team reference

### Don'ts ❌

1. **Don't pass React components** from Server to Client
2. **Don't pass functions** across the boundary
3. **Don't use dynamic imports** for this pattern (unnecessary)
4. **Don't forget the 'use client'** directive
5. **Don't pass complex objects** with methods

---

## Performance Impact

**Zero performance impact**:
- Icon lookup is O(1) (object property access)
- No additional network requests
- No dynamic imports needed
- Icons tree-shaken by bundler

---

## Alternative Solutions (Not Recommended)

### 1. Make Everything Client-Side
❌ Loses Server Component benefits (streaming, reduced JS bundle)

### 2. Dynamic Imports
❌ Adds complexity, slower, unnecessary for this use case

### 3. Icon Strings/SVG Paths
❌ Loses type safety, harder to maintain

### 4. Separate Icon Components
❌ Code duplication, maintenance burden

**Our solution is the best balance** of simplicity, performance, and maintainability.

---

## Future Enhancements

### Potential Improvements:

1. **Type-safe icon names**:
```tsx
type IconName = 'package' | 'shopping-cart' | 'users' | 'trending-up'
iconName: IconName  // Instead of string
```

2. **Centralized icon registry**:
```tsx
// lib/icons.ts
export const iconRegistry = { /* all icons */ }
```

3. **Icon preview in Storybook**:
- Document all available icons
- Visual reference for developers

---

**Status**: ✅ Fixed
**Date**: November 2, 2025
**Next.js Version**: 16.0.1 (Turbopack)
