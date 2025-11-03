import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../services/cart_service.dart';
import 'product_detail_screen.dart';

class BrandProductsScreen extends StatefulWidget {
  final String brand;

  const BrandProductsScreen({super.key, required this.brand});

  @override
  State<BrandProductsScreen> createState() => _BrandProductsScreenState();
}

class _BrandProductsScreenState extends State<BrandProductsScreen> {
  final ProductService _productService = ProductService();
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  List<String> _availableCategories = [];
  bool _isLoading = true;
  String? _error;

  // Filter and sort state
  String _sortBy = 'default'; // default, price_low, price_high, name
  final Set<String> _selectedCategories = {};
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final products = await _productService.getProductsByBrand(widget.brand);
      
      // Extract unique categories (filter out nulls)
      final categories = products
          .map((p) => p.categoryId)
          .whereType<String>()
          .toSet()
          .toList();

      setState(() {
        _allProducts = products;
        _filteredProducts = products;
        _availableCategories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFiltersAndSort() {
    setState(() {
      // Apply filters
      _filteredProducts = _allProducts.where((product) {
        // Category filter
        if (_selectedCategories.isNotEmpty) {
          if (!_selectedCategories.contains(product.categoryId)) {
            return false;
          }
        }
        return true;
      }).toList();

      // Apply sorting
      switch (_sortBy) {
        case 'price_low':
          _filteredProducts.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'price_high':
          _filteredProducts.sort((a, b) => b.price.compareTo(a.price));
          break;
        case 'name':
          _filteredProducts.sort((a, b) => a.name.compareTo(b.name));
          break;
        default:
          // Keep default order
          break;
      }
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedCategories.clear();
      _sortBy = 'default';
      _applyFiltersAndSort();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.brand,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            if (!_isLoading)
              Text(
                '${_filteredProducts.length} produits',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list : Icons.filter_list_outlined,
              color: Colors.black,
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Erreur: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadProducts,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Breadcrumb
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: Colors.grey[50],
                      child: Text(
                        'Accueil > Marques > ${widget.brand}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),

                    // Filters panel
                    if (_showFilters)
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(color: Colors.grey[200]!),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Sort options
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Trier par',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _resetFilters,
                                    child: const Text('Réinitialiser'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: [
                                  _SortChip(
                                    label: 'Par défaut',
                                    value: 'default',
                                    selected: _sortBy == 'default',
                                    onSelected: (value) {
                                      setState(() {
                                        _sortBy = value;
                                        _applyFiltersAndSort();
                                      });
                                    },
                                  ),
                                  _SortChip(
                                    label: 'Prix croissant',
                                    value: 'price_low',
                                    selected: _sortBy == 'price_low',
                                    onSelected: (value) {
                                      setState(() {
                                        _sortBy = value;
                                        _applyFiltersAndSort();
                                      });
                                    },
                                  ),
                                  _SortChip(
                                    label: 'Prix décroissant',
                                    value: 'price_high',
                                    selected: _sortBy == 'price_high',
                                    onSelected: (value) {
                                      setState(() {
                                        _sortBy = value;
                                        _applyFiltersAndSort();
                                      });
                                    },
                                  ),
                                  _SortChip(
                                    label: 'Nom',
                                    value: 'name',
                                    selected: _sortBy == 'name',
                                    onSelected: (value) {
                                      setState(() {
                                        _sortBy = value;
                                        _applyFiltersAndSort();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Products grid
                    Expanded(
                      child: _filteredProducts.isEmpty
                          ? const Center(
                              child: Text('Aucun produit trouvé'),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.7,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: _filteredProducts.length,
                              itemBuilder: (context, index) {
                                return _ProductCard(product: _filteredProducts[index]);
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final Function(String) onSelected;

  const _SortChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(value),
      backgroundColor: Colors.white,
      selectedColor: Colors.black,
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black,
        fontSize: 12,
      ),
      side: BorderSide(
        color: selected ? Colors.black : Colors.grey[300]!,
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: product),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl ?? 'https://via.placeholder.com/300',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.car_repair,
                      size: 50,
                    ),
                  ),
                ),
              ),
            ),

            // Product info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (product.brand != null)
                    Text(
                      product.brand!,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    '${product.price.toStringAsFixed(0)} F',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final cartService = Provider.of<CartService>(context, listen: false);
                        cartService.addItem(product);
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.name} ajouté au panier'),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Ajouter',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
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
}
