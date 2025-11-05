import 'package:flutter/material.dart';
import '../models/filter_options.dart';

class ModernFilterModal extends StatefulWidget {
  final FilterOptions initialOptions;
  final List<String> availableBrands;
  final List<String> availableCategories;

  const ModernFilterModal({
    super.key,
    required this.initialOptions,
    this.availableBrands = const [],
    this.availableCategories = const [],
  });

  @override
  State<ModernFilterModal> createState() => _ModernFilterModalState();

  static Future<FilterOptions?> show({
    required BuildContext context,
    required FilterOptions initialOptions,
    List<String> availableBrands = const [],
    List<String> availableCategories = const [],
  }) {
    return showModalBottomSheet<FilterOptions>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ModernFilterModal(
        initialOptions: initialOptions,
        availableBrands: availableBrands,
        availableCategories: availableCategories,
      ),
    );
  }
}

class _ModernFilterModalState extends State<ModernFilterModal> {
  late FilterOptions _options;

  // Tire dimensions options
  final List<String> _widthOptions = ['185', '195', '205', '215', '225', '235', '245', '255', '265', '275', '285', '295', '305'];
  final List<String> _heightOptions = ['35', '40', '45', '50', '55', '60', '65', '70', '75', '80'];
  final List<String> _diameterOptions = ['13', '14', '15', '16', '17', '18', '19', '20', '21', '22'];

  @override
  void initState() {
    super.initState();
    _options = widget.initialOptions;
  }

  void _apply() {
    Navigator.of(context).pop(_options);
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

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filtres',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Content
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                children: [
                  // Brands (Marques)
                  _buildSectionTitle('Marques'),
                  const SizedBox(height: 12),
                  _buildBrandChips(),
                  const SizedBox(height: 24),

                  // Vehicle Types (Types de véhicules)
                  _buildSectionTitle('Types de véhicules'),
                  const SizedBox(height: 12),
                  _buildVehicleTypeChips(),
                  const SizedBox(height: 24),

                  // Tire Types (Types de pneus)
                  _buildSectionTitle('Types de pneus'),
                  const SizedBox(height: 12),
                  _buildTireTypeChips(),
                  const SizedBox(height: 24),

                  // Dimensions
                  _buildSectionTitle('Dimensions'),
                  const SizedBox(height: 12),
                  _buildDimensionDropdowns(),
                  const SizedBox(height: 24),

                  // Price Range
                  _buildSectionTitle('Fourchette de prix'),
                  const SizedBox(height: 12),
                  _buildPriceRange(),
                  const SizedBox(height: 24),

                  // Stock availability
                  SwitchListTile(
                    title: const Text(
                      'En stock uniquement',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    value: _options.inStockOnly,
                    onChanged: (value) {
                      setState(() {
                        _options = _options.copyWith(inStockOnly: value);
                      });
                    },
                    activeThumbColor: Colors.black,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(20),
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
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _apply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _options.activeFilterCount > 0
                          ? 'Valider (${_options.activeFilterCount})'
                          : 'Valider',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildBrandChips() {
    // Use predefined brands if available, otherwise use common tire brands
    final brands = widget.availableBrands.isNotEmpty
        ? widget.availableBrands
        : ['Michelin', 'Hankook', 'Continental', 'GoodYear', 'Bridgestone', 'Maxxis'];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: brands.map((brand) {
        final isSelected = _options.selectedBrands.contains(brand);
        return FilterChip(
          label: Text(brand),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              final updatedBrands = List<String>.from(_options.selectedBrands);
              if (selected) {
                updatedBrands.add(brand);
              } else {
                updatedBrands.remove(brand);
              }
              _options = _options.copyWith(selectedBrands: updatedBrands);
            });
          },
          backgroundColor: Colors.white,
          selectedColor: Colors.black,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
          side: BorderSide(
            color: isSelected ? Colors.black : Colors.grey[300]!,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        );
      }).toList(),
    );
  }

  Widget _buildVehicleTypeChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: VehicleType.values.map((type) {
        final isSelected = _options.selectedVehicleTypes.contains(type);
        return FilterChip(
          label: Text(type.label),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              final updatedTypes = List<VehicleType>.from(_options.selectedVehicleTypes);
              if (selected) {
                updatedTypes.add(type);
              } else {
                updatedTypes.remove(type);
              }
              _options = _options.copyWith(selectedVehicleTypes: updatedTypes);
            });
          },
          backgroundColor: Colors.white,
          selectedColor: Colors.black,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
          side: BorderSide(
            color: isSelected ? Colors.black : Colors.grey[300]!,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        );
      }).toList(),
    );
  }

  Widget _buildTireTypeChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: TireType.values.map((type) {
        final isSelected = _options.selectedTireTypes.contains(type);
        return FilterChip(
          label: Text(type.label),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              final updatedTypes = List<TireType>.from(_options.selectedTireTypes);
              if (selected) {
                updatedTypes.add(type);
              } else {
                updatedTypes.remove(type);
              }
              _options = _options.copyWith(selectedTireTypes: updatedTypes);
            });
          },
          backgroundColor: Colors.white,
          selectedColor: Colors.black,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
          side: BorderSide(
            color: isSelected ? Colors.black : Colors.grey[300]!,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        );
      }).toList(),
    );
  }

  Widget _buildDimensionDropdowns() {
    return Row(
      children: [
        Expanded(
          child: _buildDimensionDropdown(
            label: 'Largeur',
            value: _options.width,
            items: _widthOptions,
            onChanged: (value) {
              setState(() {
                _options = _options.copyWith(width: value);
              });
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDimensionDropdown(
            label: 'Hauteur',
            value: _options.height,
            items: _heightOptions,
            onChanged: (value) {
              setState(() {
                _options = _options.copyWith(height: value);
              });
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDimensionDropdown(
            label: 'Diamètre',
            value: _options.diameter,
            items: _diameterOptions,
            onChanged: (value) {
              setState(() {
                _options = _options.copyWith(diameter: value);
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDimensionDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('Tous'),
        ),
        ...items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }),
      ],
      onChanged: onChanged,
    );
  }

  Widget _buildPriceRange() {
    return Column(
      children: [
        RangeSlider(
          values: RangeValues(_options.minPrice, _options.maxPrice),
          min: 0,
          max: 1000000,
          divisions: 100,
          labels: RangeLabels(
            '${_options.minPrice.toInt()} F',
            '${_options.maxPrice.toInt()} F',
          ),
          onChanged: (values) {
            setState(() {
              _options = _options.copyWith(
                minPrice: values.start,
                maxPrice: values.end,
              );
            });
          },
          activeColor: Colors.black,
          inactiveColor: Colors.grey[300],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_options.minPrice.toInt()} F',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${_options.maxPrice.toInt()} F',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
