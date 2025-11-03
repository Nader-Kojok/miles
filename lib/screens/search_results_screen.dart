import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/debouncer.dart';
import '../models/filter_options.dart';
import '../models/vehicle.dart';
import '../models/product.dart';
import '../widgets/modern_filter_modal.dart';
import '../widgets/modern_sort_modal.dart';
import '../services/product_service.dart';
import '../services/search_service.dart';
import '../services/voice_search_service.dart';

class SearchResultsScreen extends StatefulWidget {
  final String initialQuery;
  final Vehicle? vehicleFilter;

  const SearchResultsScreen({
    super.key,
    this.initialQuery = '',
    this.vehicleFilter,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late TextEditingController _searchController;
  late Debouncer _debouncer;
  late ProductService _productService;
  late SearchService _searchService;
  late VoiceSearchService _voiceSearchService;
  
  bool _isGridView = false;
  FilterOptions _filterOptions = const FilterOptions();
  
  List<String> _recentSearches = [];
  List<String> _trendingSearches = [];
  List<String> _suggestions = [];
  bool _showSuggestions = false;
  
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  bool _isVoiceListening = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _debouncer = Debouncer(delay: const Duration(milliseconds: 500));
    _productService = ProductService();
    _searchService = SearchService();
    _voiceSearchService = VoiceSearchService();
    
    _initializeServices();
    if (widget.initialQuery.isNotEmpty) {
      _performSearch(widget.initialQuery);
    }
  }
  
  Future<void> _initializeServices() async {
    try {
      await _searchService.initialize();
      await _voiceSearchService.initialize();
      await _loadSearchHistory();
      await _loadTrendingSearches();
    } catch (e) {
      print('Error initializing services: $e');
    }
  }
  
  Future<void> _loadSearchHistory() async {
    final history = await _searchService.getSearchHistoryQueries(limit: 5);
    setState(() {
      _recentSearches = history;
    });
  }
  
  Future<void> _loadTrendingSearches() async {
    final trending = await _searchService.getTrendingSearches(limit: 3);
    setState(() {
      _trendingSearches = trending;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _filteredProducts = [];
        _showSuggestions = false;
        _isLoading = false;
        _errorMessage = null;
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _showSuggestions = false;
    });
    
    try {
      // Save to search history
      await _searchService.saveSearchHistory(query);
      await _loadSearchHistory();
      
      // Perform advanced search with filters
      final results = await _productService.advancedSearch(
        query: query,
        minPrice: _filterOptions.minPrice,
        maxPrice: _filterOptions.maxPrice,
        inStockOnly: _filterOptions.inStockOnly,
        sortBy: _getSortByString(),
      );
      
      setState(() {
        _filteredProducts = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de recherche: $e';
        _isLoading = false;
        _filteredProducts = [];
      });
    }
  }
  
  String _getSortByString() {
    switch (_filterOptions.sortBy) {
      case SortOption.priceAscending:
        return 'price_asc';
      case SortOption.priceDescending:
        return 'price_desc';
      case SortOption.newest:
        return 'newest';
      default:
        return 'newest';
    }
  }

  void _onSearchChanged(String query) {
    // Real-time search with debouncing
    _debouncer(() {
      if (query.trim().isEmpty) {
        setState(() {
          _showSuggestions = false;
          _suggestions = [];
        });
      } else {
        // Get suggestions from search history
        _loadSuggestions(query);
        // Perform actual search in real-time
        _performSearch(query);
      }
    });
  }
  
  Future<void> _loadSuggestions(String query) async {
    final suggestions = await _searchService.getSearchSuggestions(query);
    setState(() {
      _suggestions = suggestions;
      _showSuggestions = suggestions.isNotEmpty && query.isNotEmpty;
    });
  }

  void _applySorting() {
    // Re-search with new sort order
    if (_searchController.text.isNotEmpty) {
      _performSearch(_searchController.text);
    }
  }

  Future<void> _showSortModal() async {
    final result = await ModernSortModal.show(
      context: context,
      currentSort: _filterOptions.sortBy,
    );

    if (result != null) {
      setState(() {
        _filterOptions = _filterOptions.copyWith(sortBy: result);
      });
      _applySorting();
    }
  }

  Future<void> _showFilterModal() async {
    final result = await ModernFilterModal.show(
      context: context,
      initialOptions: _filterOptions,
      availableBrands: ['Michelin', 'Continental', 'Bridgestone', 'GoodYear'],
    );

    if (result != null) {
      setState(() {
        _filterOptions = result;
      });
      _applyFilters();
    }
  }

  void _applyFilters() {
    // Re-search with new filters
    if (_searchController.text.isNotEmpty) {
      _performSearch(_searchController.text);
    }
  }
  
  // Voice search functionality
  Future<void> _startVoiceSearch() async {
    if (!_voiceSearchService.isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recherche vocale non disponible')),
      );
      return;
    }
    
    setState(() => _isVoiceListening = true);
    
    try {
      await _voiceSearchService.startListening(
        onResult: (text) {
          setState(() {
            _searchController.text = text;
            _isVoiceListening = false;
          });
          _performSearch(text);
        },
        localeId: 'fr-FR',
      );
    } catch (e) {
      setState(() => _isVoiceListening = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de recherche vocale: $e')),
      );
    }
  }
  
  Future<void> _stopVoiceSearch() async {
    await _voiceSearchService.stopListening();
    setState(() => _isVoiceListening = false);
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
        title: const Text(
          'Rechercher',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  autofocus: false,
                  decoration: InputDecoration(
                    hintText: 'Rechercher des pièces...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isVoiceListening)
                          IconButton(
                            icon: const Icon(Icons.mic, color: Colors.red),
                            onPressed: _stopVoiceSearch,
                            tooltip: 'Arrêter',
                          )
                        else
                          IconButton(
                            icon: const Icon(Icons.mic_none),
                            onPressed: _startVoiceSearch,
                            tooltip: 'Recherche vocale',
                          ),
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _performSearch('');
                            },
                          ),
                      ],
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: _onSearchChanged,
                  onSubmitted: _performSearch,
                ),
                
                // Trending and Recent Searches
                if (_searchController.text.isEmpty) ...[
                  if (_trendingSearches.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Tendances',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _trendingSearches.map((search) {
                        return ActionChip(
                          label: Text(search),
                          avatar: const Icon(Icons.trending_up, size: 16),
                          onPressed: () {
                            _searchController.text = search;
                            _performSearch(search);
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ]
                else if (_searchController.text.isEmpty && _recentSearches.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _recentSearches.map((search) {
                        return GestureDetector(
                          onTap: () {
                            _searchController.text = search;
                            _performSearch(search);
                          },
                          child: Chip(
                            label: Text(search),
                            avatar: const Icon(Icons.history, size: 16),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () async {
                              await _searchService.deleteSearchByQuery(search);
                              await _loadSearchHistory();
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
                
                // Action Buttons Row - matching screenshot with Tout, Filtres, Trier par
                if (_searchController.text.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Tout button
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _filterOptions = const FilterOptions();
                            });
                            _performSearch(_searchController.text);
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.black),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'Tout',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Filtres button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _showFilterModal,
                          icon: const Icon(Icons.tune, size: 18),
                          label: Text(
                            _filterOptions.activeFilterCount > 0
                                ? 'Filtres (${_filterOptions.activeFilterCount})'
                                : 'Filtres',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black,
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Trier par button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _showSortModal,
                          icon: const Icon(Icons.swap_vert, size: 18),
                          label: const Text(
                            'Trier par',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black,
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Suggestions
          if (_showSuggestions && _suggestions.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!),
                ),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.search, size: 18),
                    title: Text(
                      _suggestions[index],
                      style: const TextStyle(fontSize: 14),
                    ),
                    trailing: const Icon(Icons.arrow_outward, size: 14),
                    onTap: () {
                      _searchController.text = _suggestions[index];
                      _performSearch(_suggestions[index]);
                    },
                  );
                },
              ),
            )
          else if (!_isLoading) ...[
            // Results Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _searchController.text.isEmpty
                        ? 'Recherchez des pièces'
                        : '${_filteredProducts.length} résultat${_filteredProducts.length > 1 ? "s" : ""}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isGridView ? Icons.view_list : Icons.grid_view,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _isGridView = !_isGridView;
                      });
                    },
                    tooltip: 'Changer la vue',
                  ),
                ],
              ),
            ),

            // Results
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? _buildErrorState()
                      : _filteredProducts.isEmpty
                          ? _buildEmptyState()
                          : _isGridView
                              ? _buildGridView()
                              : _buildListView(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'Une erreur s\'est produite',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => _performSearch(_searchController.text),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isEmpty
                ? 'Commencez à rechercher des pièces'
                : 'Aucun résultat pour "${_searchController.text}"',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Essayez avec d\'autres mots-clés',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          if (_searchController.text.isNotEmpty) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _filteredProducts = [];
                  _errorMessage = null;
                });
              },
              child: const Text('Effacer la recherche'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return _buildProductListTile(product);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: product.imageUrl ?? 'https://via.placeholder.com/300',
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(Icons.car_repair, size: 50, color: Colors.grey),
                ),
              ),
            ),
          ),
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
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (product.brand != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    product.brand!,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text('Ajouter', style: TextStyle(fontSize: 12, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductListTile(Product product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: product.imageUrl ?? 'https://via.placeholder.com/300',
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(Icons.car_repair, size: 40, color: Colors.grey),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 4),
                  if (product.brand != null)
                    Text(
                      product.brand!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  if (product.sku != null)
                    Text(
                      'SKU: ${product.sku}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (!product.inStock)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Rupture',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.red[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'En stock',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      const Spacer(),
                      Text(
                        '${product.price.toStringAsFixed(0)} F',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
