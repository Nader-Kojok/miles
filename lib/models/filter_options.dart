class FilterOptions {
  // Sort options
  final SortOption sortBy;
  
  // Price range
  final double minPrice;
  final double maxPrice;
  
  // Categories
  final List<String> selectedCategories;
  
  // Brands (Marques)
  final List<String> selectedBrands;
  
  // Vehicle types (Types de véhicules)
  final List<VehicleType> selectedVehicleTypes;
  
  // Tire types (Types de pneus)
  final List<TireType> selectedTireTypes;
  
  // Dimensions (for tires)
  final String? width; // Largeur
  final String? height; // Hauteur
  final String? diameter; // Diamètre
  
  // Availability
  final bool inStockOnly;
  
  // Condition
  final ProductCondition condition;

  const FilterOptions({
    this.sortBy = SortOption.relevance,
    this.minPrice = 0,
    this.maxPrice = 1000000,
    this.selectedCategories = const [],
    this.selectedBrands = const [],
    this.selectedVehicleTypes = const [],
    this.selectedTireTypes = const [],
    this.width,
    this.height,
    this.diameter,
    this.inStockOnly = false,
    this.condition = ProductCondition.all,
  });

  FilterOptions copyWith({
    SortOption? sortBy,
    double? minPrice,
    double? maxPrice,
    List<String>? selectedCategories,
    List<String>? selectedBrands,
    List<VehicleType>? selectedVehicleTypes,
    List<TireType>? selectedTireTypes,
    String? width,
    String? height,
    String? diameter,
    bool? inStockOnly,
    ProductCondition? condition,
  }) {
    return FilterOptions(
      sortBy: sortBy ?? this.sortBy,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      selectedBrands: selectedBrands ?? this.selectedBrands,
      selectedVehicleTypes: selectedVehicleTypes ?? this.selectedVehicleTypes,
      selectedTireTypes: selectedTireTypes ?? this.selectedTireTypes,
      width: width ?? this.width,
      height: height ?? this.height,
      diameter: diameter ?? this.diameter,
      inStockOnly: inStockOnly ?? this.inStockOnly,
      condition: condition ?? this.condition,
    );
  }

  bool get hasActiveFilters {
    return minPrice > 0 ||
        maxPrice < 1000000 ||
        selectedCategories.isNotEmpty ||
        selectedBrands.isNotEmpty ||
        selectedVehicleTypes.isNotEmpty ||
        selectedTireTypes.isNotEmpty ||
        width != null ||
        height != null ||
        diameter != null ||
        inStockOnly ||
        condition != ProductCondition.all;
  }

  int get activeFilterCount {
    int count = 0;
    if (minPrice > 0 || maxPrice < 1000000) count++;
    if (selectedCategories.isNotEmpty) count++;
    if (selectedBrands.isNotEmpty) count++;
    if (selectedVehicleTypes.isNotEmpty) count++;
    if (selectedTireTypes.isNotEmpty) count++;
    if (width != null || height != null || diameter != null) count++;
    if (inStockOnly) count++;
    if (condition != ProductCondition.all) count++;
    return count;
  }

  FilterOptions clearAll() {
    return const FilterOptions();
  }
}

enum SortOption {
  relevance,
  priceAscending,
  priceDescending,
  popularity,
  rating,
  newest;

  String get label {
    switch (this) {
      case SortOption.relevance:
        return 'Pertinence';
      case SortOption.priceAscending:
        return 'Prix croissant';
      case SortOption.priceDescending:
        return 'Prix décroissant';
      case SortOption.popularity:
        return 'Popularité';
      case SortOption.rating:
        return 'Meilleures notes';
      case SortOption.newest:
        return 'Nouveautés';
    }
  }
}

enum VehicleType {
  auto,
  suv4x4,
  lightTruck,
  truck,
  motoScooter;

  String get label {
    switch (this) {
      case VehicleType.auto:
        return 'Auto';
      case VehicleType.suv4x4:
        return '4X4/SUV';
      case VehicleType.lightTruck:
        return 'Camion léger';
      case VehicleType.truck:
        return 'Camion';
      case VehicleType.motoScooter:
        return 'Moto/Scooter';
    }
  }
}

enum TireType {
  allSeason,
  summer,
  winter;

  String get label {
    switch (this) {
      case TireType.allSeason:
        return 'Toutes saisons';
      case TireType.summer:
        return 'Pneus été';
      case TireType.winter:
        return 'Pneus hiver';
    }
  }
}

enum ProductCondition {
  all,
  new_,
  used,
  refurbished;

  String get label {
    switch (this) {
      case ProductCondition.all:
        return 'Tous';
      case ProductCondition.new_:
        return 'Neuf';
      case ProductCondition.used:
        return 'Occasion';
      case ProductCondition.refurbished:
        return 'Reconditionné';
    }
  }
}
