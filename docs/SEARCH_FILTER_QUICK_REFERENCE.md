# Search & Filter Quick Reference Guide

## UI Components Overview

### Search Results Screen
```
┌─────────────────────────────────────┐
│  ← Rechercher                       │
├─────────────────────────────────────┤
│  🔍 Pneus              ✕      🎤    │
│                                     │
│  [Tout] [Filtres ▼] [Trier par ▼] │
│                                     │
│  Résultats (64 Résultats)      ⊞   │
├─────────────────────────────────────┤
│  ┌──────────────────────────────┐  │
│  │ 🖼️  Product Name             │  │
│  │     Pneu hiver               │  │
│  │     59 000 F    [Ajouter]    │  │
│  └──────────────────────────────┘  │
│  ┌──────────────────────────────┐  │
│  │ 🖼️  Product Name             │  │
│  └──────────────────────────────┘  │
└─────────────────────────────────────┘
```

### Filter Modal (Bottom Sheet)
```
┌─────────────────────────────────────┐
│               ━━━                   │
│  Filtres                       ✕    │
├─────────────────────────────────────┤
│  Marques                            │
│  [Michelin] [Hankook] [Continental] │
│  [GoodYear] [Bridgestone] [Maxxis]  │
│                                     │
│  Types de véhicules                 │
│  [Auto] [4X4/SUV] [Camion léger]    │
│  [Camion] [Moto/Scooter]            │
│                                     │
│  Types de pneus                     │
│  [Toutes saisons] [Pneus été]       │
│  [Pneus hiver]                      │
│                                     │
│  Dimensions                         │
│  [Largeur▼] [Hauteur▼] [Diamètre▼] │
│                                     │
│  Fourchette de prix                 │
│  ◯────────────────────────●         │
│  0 F                    1,000,000 F │
│                                     │
│  ◯ En stock uniquement              │
├─────────────────────────────────────┤
│     [Valider (3)]                   │
└─────────────────────────────────────┘
```

### Sort Modal (Bottom Sheet)
```
┌─────────────────────────────────────┐
│  Options de tri              ✕      │
│  Trier par                          │
├─────────────────────────────────────┤
│  ◉ Pertinence                       │
│  ○ Prix croissant                   │
│  ○ Prix décroissant                 │
│  ○ Popularité                       │
│  ○ Meilleures notes                 │
│  ○ Nouveautés                       │
├─────────────────────────────────────┤
│     [Valider]                       │
└─────────────────────────────────────┘
```

## Key User Flows

### 1. Basic Search Flow
```
Catalog Screen
    ↓ (tap search bar)
Search Results Screen (empty search)
    ↓ (type query)
Debounced suggestions appear
    ↓ (select suggestion or press enter)
Filtered results displayed
```

### 2. Filter Application Flow
```
Search Results Screen
    ↓ (tap "Filtres" button)
Filter Modal opens
    ↓ (select filters)
Active filter count updates
    ↓ (tap "Valider")
Results filtered immediately
Badge shows active filter count
```

### 3. Sort Flow
```
Search Results Screen
    ↓ (tap "Trier par" button)
Sort Modal opens
    ↓ (select sort option)
Radio button updates
    ↓ (tap "Valider")
Results re-sorted immediately
```

## Component Props

### FilterOptions
```dart
FilterOptions(
  sortBy: SortOption.relevance,
  minPrice: 0,
  maxPrice: 1000000,
  selectedBrands: ['Michelin', 'Continental'],
  selectedVehicleTypes: [VehicleType.auto],
  selectedTireTypes: [TireType.allSeason],
  width: '205',
  height: '55',
  diameter: '16',
  inStockOnly: true,
  condition: ProductCondition.new_,
)
```

### ModernFilterModal
```dart
ModernFilterModal.show(
  context: context,
  initialOptions: FilterOptions(),
  availableBrands: ['Michelin', 'Continental'],
  availableCategories: ['Pneus', 'Freinage'],
)
```

### ModernSortModal
```dart
ModernSortModal.show(
  context: context,
  currentSort: SortOption.priceAscending,
)
```

### Debouncer
```dart
final debouncer = Debouncer(
  delay: Duration(milliseconds: 300),
);

debouncer(() {
  performSearch(query);
});

debouncer.dispose(); // In dispose()
```

## Color Scheme

```dart
Primary Action: Colors.black
Secondary Action: Colors.white
Border/Outline: Colors.grey[300]
Background: Colors.grey[100]
Text Primary: Colors.black
Text Secondary: Colors.grey[600]
Active Indicator: Colors.black
Chip Selected: Colors.black (background)
Chip Selected Text: Colors.white
```

## Common Patterns

### Opening a Modal
```dart
final result = await ModernFilterModal.show(
  context: context,
  initialOptions: _filterOptions,
);

if (result != null) {
  setState(() {
    _filterOptions = result;
  });
  _applyFilters();
}
```

### Updating Filter State
```dart
setState(() {
  _filterOptions = _filterOptions.copyWith(
    selectedBrands: ['Michelin'],
    inStockOnly: true,
  );
});
_applyFilters();
```

### Applying Filters to List
```dart
void _applyFilters() {
  setState(() {
    _filteredProducts = _allProducts.where((product) {
      // Price filter
      if (product['price'] < _filterOptions.minPrice ||
          product['price'] > _filterOptions.maxPrice) {
        return false;
      }
      
      // Stock filter
      if (_filterOptions.inStockOnly && !product['inStock']) {
        return false;
      }
      
      // Category filter
      if (_filterOptions.selectedCategories.isNotEmpty &&
          !_filterOptions.selectedCategories.contains(product['category'])) {
        return false;
      }
      
      return true;
    }).toList();
    
    _applySorting();
  });
}
```

### Applying Sort
```dart
void _applySorting() {
  setState(() {
    switch (_filterOptions.sortBy) {
      case SortOption.priceAscending:
        _filteredProducts.sort((a, b) => 
          a['price'].compareTo(b['price']));
        break;
      case SortOption.priceDescending:
        _filteredProducts.sort((a, b) => 
          b['price'].compareTo(a['price']));
        break;
      case SortOption.rating:
        _filteredProducts.sort((a, b) => 
          b['rating'].compareTo(a['rating']));
        break;
      // ... other cases
    }
  });
}
```

## Tips & Tricks

1. **Always use debouncing for search inputs** (300-500ms is optimal)
2. **Show active filter count** to help users know what's applied
3. **Provide clear "Clear All" option** for easy filter reset
4. **Use FilterChip for multi-select**, Radio for single-select
5. **Make modals draggable** for better UX
6. **Show loading states** during async operations
7. **Preserve scroll position** when returning from detail screens
8. **Consider filter persistence** across sessions
9. **Add filter presets** for common use cases
10. **Track filter analytics** to understand user behavior

## Performance Notes

- Debouncing reduces state updates by ~90%
- Filter application is O(n) - scales linearly
- Modal widgets are only built when shown
- Proper disposal prevents memory leaks
- Immutable state prevents unnecessary rebuilds
