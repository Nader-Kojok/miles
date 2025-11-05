# Pagination Enhancement

## ✅ What Was Done

Enhanced all pagination components in the admin dashboard with advanced navigation features.

### New Features

1. **Page Number Buttons** - Click directly on page numbers (1, 2, 3, etc.)
2. **First/Last Page Navigation** - Jump to first or last page instantly
3. **Page Jump Input** - Type a specific page number and press OK
4. **Smart Page Display** - Shows relevant page numbers with ellipsis for large page counts
5. **Responsive Design** - Adapts to different screen sizes

### Components Updated

✅ **Products Table** (`/dashboard/products/products-table.tsx`)
✅ **Orders Table** (`/dashboard/orders/orders-table.tsx`)
✅ **Users Table** (`/dashboard/users/users-table.tsx`)
✅ **Categories Table** (`/dashboard/categories/categories-table.tsx`)

### New Reusable Component

Created `/components/pagination.tsx` - A reusable pagination component with:

```tsx
<Pagination
  currentPage={currentPage}
  totalPages={totalPages}
  onPageChange={setCurrentPage}
/>
```

## Features Breakdown

### 1. Page Number Buttons
- Shows up to 5 page numbers at a time
- Current page is highlighted
- Click any number to jump to that page
- Hidden on mobile (md breakpoint)

### 2. First/Last Page Buttons
- `<<` button jumps to page 1
- `>>` button jumps to last page
- Disabled when already on first/last page
- Hidden on small screens (sm breakpoint)

### 3. Previous/Next Buttons
- Always visible
- Show text on larger screens ("Précédent" / "Suivant")
- Icon-only on mobile
- Disabled at boundaries

### 4. Page Jump Input
- Type any page number (1 to totalPages)
- Press OK or Enter to jump
- Input validates the range
- Hidden on smaller screens (lg breakpoint)
- Clears after successful jump

### 5. Smart Page Display Logic

For 8 or fewer pages:
```
[1] [2] [3] [4] [5] [6] [7] [8]
```

For many pages (current page in middle):
```
[1] ... [5] [6] [7] ... [20]
```

For many pages (current page near start):
```
[1] [2] [3] [4] ... [20]
```

For many pages (current page near end):
```
[1] ... [17] [18] [19] [20]
```

## Responsive Behavior

| Feature | Mobile | Tablet (md) | Desktop (lg) |
|---------|--------|-------------|--------------|
| Prev/Next | ✓ (icon only) | ✓ (with text) | ✓ (with text) |
| First/Last | ✗ | ✓ | ✓ |
| Page Numbers | ✗ | ✓ | ✓ |
| Page Jump | ✗ | ✗ | ✓ |
| Page Info | ✓ | ✓ | ✓ |

## Usage Example

```tsx
import { Pagination } from '@/components/pagination'

function MyTable() {
  const [currentPage, setCurrentPage] = useState(1)
  const totalPages = Math.ceil(totalItems / itemsPerPage)

  return (
    <>
      {/* Your table content */}
      
      <Pagination
        currentPage={currentPage}
        totalPages={totalPages}
        onPageChange={setCurrentPage}
      />
    </>
  )
}
```

## Benefits

1. **Better UX** - Users can navigate large datasets more efficiently
2. **Accessibility** - Keyboard navigation supported (Tab + Enter)
3. **Consistency** - Same pagination experience across all tables
4. **Maintainability** - Single reusable component
5. **Performance** - Only renders visible page numbers

## Testing

To test the enhanced pagination:

1. Go to any table with multiple pages (Products, Orders, Users, Categories)
2. Try clicking page numbers
3. Use First/Last page buttons
4. Type a page number in the jump input (desktop only)
5. Test on different screen sizes

## Future Enhancements

Potential improvements:
- Add items-per-page selector (10, 25, 50, 100)
- Add keyboard shortcuts (Ctrl+Left/Right for prev/next)
- Add URL query params for page state
- Add loading states during page transitions
- Add page prefetching for faster navigation
