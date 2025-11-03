import 'package:flutter/material.dart';

class FilterOptions {
  final String sortBy;
  final double minPrice;
  final double maxPrice;
  final List<String> categories;
  final List<String> brands;
  final bool inStockOnly;
  final String condition;

  FilterOptions({
    this.sortBy = 'relevance',
    this.minPrice = 0,
    this.maxPrice = 500000,
    this.categories = const [],
    this.brands = const [],
    this.inStockOnly = false,
    this.condition = 'all',
  });
}

class FilterSortModal extends StatefulWidget {
  final FilterOptions initialOptions;
  final Function(FilterOptions) onApply;

  const FilterSortModal({
    super.key,
    required this.initialOptions,
    required this.onApply,
  });

  @override
  State<FilterSortModal> createState() => _FilterSortModalState();

  static Future<FilterOptions?> show(BuildContext context, FilterOptions initialOptions) {
    return showModalBottomSheet<FilterOptions>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterSortModal(
        initialOptions: initialOptions,
        onApply: (options) => Navigator.pop(context, options),
      ),
    );
  }
}

class _FilterSortModalState extends State<FilterSortModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String _sortBy;
  late RangeValues _priceRange;
  late Set<String> _selectedCategories;
  late Set<String> _selectedBrands;
  late bool _inStockOnly;
  late String _condition;
  
  // Hardcoded categories and brands for now
  final List<String> _categories = [
    'Électronique',
    'Mode',
    'Maison',
    'Sports',
    'Livres',
    'Jouets',
  ];
  final List<String> _brands = [
    'Samsung',
    'Apple',
    'Nike',
    'Adidas',
    'Sony',
    'LG',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _sortBy = widget.initialOptions.sortBy;
    _priceRange = RangeValues(widget.initialOptions.minPrice, widget.initialOptions.maxPrice);
    _selectedCategories = widget.initialOptions.categories.toSet();
    _selectedBrands = widget.initialOptions.brands.toSet();
    _inStockOnly = widget.initialOptions.inStockOnly;
    _condition = widget.initialOptions.condition;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _clearAll() {
    setState(() {
      _sortBy = 'relevance';
      _priceRange = const RangeValues(0, 500000);
      _selectedCategories.clear();
      _selectedBrands.clear();
      _inStockOnly = false;
      _condition = 'all';
    });
  }

  void _apply() {
    final options = FilterOptions(
      sortBy: _sortBy,
      minPrice: _priceRange.start,
      maxPrice: _priceRange.end,
      categories: _selectedCategories.toList(),
      brands: _selectedBrands.toList(),
      inStockOnly: _inStockOnly,
      condition: _condition,
    );
    widget.onApply(options);
  }

  int get _activeFiltersCount {
    int count = 0;
    if (_priceRange.start > 0 || _priceRange.end < 500000) count++;
    if (_selectedCategories.isNotEmpty) count++;
    if (_selectedBrands.isNotEmpty) count++;
    if (_inStockOnly) count++;
    if (_condition != 'all') count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Tabs
            TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.black,
              tabs: const [
                Tab(text: 'Trier'),
                Tab(text: 'Filtrer'),
              ],
            ),

            const Divider(height: 1),

            // Tab views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSortTab(scrollController),
                  _buildFilterTab(scrollController),
                ],
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clearAll,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Effacer tout'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _apply,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        _activeFiltersCount > 0
                            ? 'Appliquer ($_activeFiltersCount)'
                            : 'Appliquer',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortTab(ScrollController scrollController) {
    return RadioGroup<String>(
      groupValue: _sortBy,
      onChanged: (value) => setState(() => _sortBy = value!),
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        children: [
          RadioListTile<String>(
            title: const Text('Pertinence'),
            value: 'relevance',
            activeColor: Colors.black,
          ),
          RadioListTile<String>(
            title: const Text('Prix croissant'),
            value: 'price_low',
            activeColor: Colors.black,
          ),
          RadioListTile<String>(
            title: const Text('Prix décroissant'),
            value: 'price_high',
            activeColor: Colors.black,
          ),
          RadioListTile<String>(
            title: const Text('Nouveautés'),
            value: 'newest',
            activeColor: Colors.black,
          ),
          RadioListTile<String>(
            title: const Text('Meilleures ventes'),
            value: 'bestselling',
            activeColor: Colors.black,
          ),
          RadioListTile<String>(
            title: const Text('Meilleures notes'),
            value: 'rating',
            activeColor: Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(ScrollController scrollController) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        // Price Range
        ExpansionTile(
          title: const Text('Prix', style: TextStyle(fontWeight: FontWeight.w600)),
          initiallyExpanded: true,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 500000,
                    divisions: 50,
                    labels: RangeLabels(
                      '${_priceRange.start.toInt()} F',
                      '${_priceRange.end.toInt()} F',
                    ),
                    onChanged: (values) => setState(() => _priceRange = values),
                    activeColor: Colors.black,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Min',
                            suffixText: 'F',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          controller: TextEditingController(
                            text: _priceRange.start.toInt().toString(),
                          ),
                          onChanged: (value) {
                            final min = double.tryParse(value) ?? 0;
                            setState(() => _priceRange = RangeValues(min, _priceRange.end));
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Max',
                            suffixText: 'F',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          controller: TextEditingController(
                            text: _priceRange.end.toInt().toString(),
                          ),
                          onChanged: (value) {
                            final max = double.tryParse(value) ?? 500000;
                            setState(() => _priceRange = RangeValues(_priceRange.start, max));
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),

        // Categories
        ExpansionTile(
          title: const Text('Catégories', style: TextStyle(fontWeight: FontWeight.w600)),
          children: _categories.map((category) {
            return CheckboxListTile(
              title: Text(category),
              value: _selectedCategories.contains(category),
              onChanged: (checked) {
                setState(() {
                  if (checked!) {
                    _selectedCategories.add(category);
                  } else {
                    _selectedCategories.remove(category);
                  }
                });
              },
              activeColor: Colors.black,
            );
          }).toList(),
        ),

        // Brands
        ExpansionTile(
          title: const Text('Marques', style: TextStyle(fontWeight: FontWeight.w600)),
          children: _brands.map((brand) {
            return CheckboxListTile(
              title: Text(brand),
              value: _selectedBrands.contains(brand),
              onChanged: (checked) {
                setState(() {
                  if (checked!) {
                    _selectedBrands.add(brand);
                  } else {
                    _selectedBrands.remove(brand);
                  }
                });
              },
              activeColor: Colors.black,
            );
          }).toList(),
        ),

        // Availability
        SwitchListTile(
          title: const Text('En stock uniquement'),
          value: _inStockOnly,
          onChanged: (value) => setState(() => _inStockOnly = value),
          activeTrackColor: Colors.black,
        ),

        // Condition
        ExpansionTile(
          title: const Text('État', style: TextStyle(fontWeight: FontWeight.w600)),
          children: [
            RadioGroup<String>(
              groupValue: _condition,
              onChanged: (value) => setState(() => _condition = value!),
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('Tous'),
                    value: 'all',
                    activeColor: Colors.black,
                  ),
                  RadioListTile<String>(
                    title: const Text('Neuf'),
                    value: 'new',
                    activeColor: Colors.black,
                  ),
                  RadioListTile<String>(
                    title: const Text('Occasion'),
                    value: 'used',
                    activeColor: Colors.black,
                  ),
                  RadioListTile<String>(
                    title: const Text('Reconditionné'),
                    value: 'refurbished',
                    activeColor: Colors.black,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

