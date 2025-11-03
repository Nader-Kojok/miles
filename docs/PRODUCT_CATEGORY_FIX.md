# Product Category Selection - Two-Level Dropdown

## Issue
The product form needed a way to select both parent categories and subcategories in a simple, logical manner.

## Solution
Implemented a two-dropdown system:
1. **First dropdown**: Select parent category (required)
2. **Second dropdown**: Select subcategory (optional, only appears if parent has subcategories)

## Changes Made

### 1. New Product Page
**File:** `admin-dashboard/app/dashboard/products/new/page.tsx`

Fetch ALL categories (both parent and subcategories):
```typescript
async function getCategories() {
  const supabase = await createServerSupabaseClient()
  const { data } = await supabase
    .from('categories')
    .select('*')
    .eq('is_active', true)
    .order('display_order')
  return data || []
}
```

### 2. Edit Product Page
**File:** `admin-dashboard/app/dashboard/products/[id]/page.tsx`

Same change - fetch all categories:
```typescript
async function getCategories() {
  const supabase = await createServerSupabaseClient()
  const { data } = await supabase
    .from('categories')
    .select('*')
    .eq('is_active', true)
    .order('display_order')
  return data || []
}
```

### 3. Product Form Component
**File:** `admin-dashboard/app/dashboard/products/product-form.tsx`

Added two separate dropdowns with smart filtering:
```typescript
// State for parent category selection
const [selectedParentCategory, setSelectedParentCategory] = useState<string>('')

// Filter categories
const parentCategories = categories.filter(cat => !cat.parent_id)
const subcategories = selectedParentCategory 
  ? categories.filter(cat => cat.parent_id === selectedParentCategory)
  : []

// First dropdown: Parent category
<Select
  value={selectedParentCategory}
  onValueChange={(value) => {
    setSelectedParentCategory(value)
    setFormData({ ...formData, category_id: value })
  }}
>
  {parentCategories.map((category) => (
    <SelectItem key={category.id} value={category.id}>
      {category.name}
    </SelectItem>
  ))}
</Select>

// Second dropdown: Subcategory (only shown if parent has subcategories)
{subcategories.length > 0 && (
  <Select
    value={formData.category_id}
    onValueChange={(value) => setFormData({ ...formData, category_id: value })}
  >
    <SelectItem value={selectedParentCategory}>
      Aucune (utiliser la catégorie principale)
    </SelectItem>
    {subcategories.map((category) => (
      <SelectItem key={category.id} value={category.id}>
        {category.name}
      </SelectItem>
    ))}
  </Select>
)}
```

## Result
- ✅ Simple, logical two-step selection process
- ✅ First select parent category (required)
- ✅ Then optionally select subcategory (only shown if available)
- ✅ Subcategory dropdown only shows relevant subcategories for selected parent
- ✅ Can choose to use parent category or drill down to subcategory
- ✅ Clean, uncluttered interface

## Database Structure
The `categories` table supports hierarchical categories with the `parent_id` field:
- Parent categories: `parent_id` is `null`
- Subcategories: `parent_id` references a parent category's `id`

## Example Usage

### Step 1: Select Parent Category
The first dropdown shows all 30 parent categories:
- Moteur
- Équipement auto
- Outillage
- Frein
- Suspension
- etc.

### Step 2: Select Subcategory (if available)
After selecting "Moteur", a second dropdown appears with its subcategories:
- Aucune (utiliser la catégorie principale)
- Bouchon de vidange
- Filtre à huile
- Joint de culasse
- etc.

If you select "Outillage" (which has no subcategories), no second dropdown appears.

### Final Result
- If you only select parent: Product is assigned to parent category
- If you select subcategory: Product is assigned to that specific subcategory
