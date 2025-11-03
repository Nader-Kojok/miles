import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../services/cart_service.dart';
import '../services/product_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _currentImageIndex = 0;
  bool _isFavorite = false;
  late PageController _pageController;
  final ScrollController _thumbnailScrollController = ScrollController();
  bool _showZoomHint = true;
  bool _isDescriptionExpanded = false;
  Category? _category;
  Category? _parentCategory;
  bool _isLoadingCategory = true;
  final ProductService _productService = ProductService();

  // Simule plusieurs images du produit (TODO: charger depuis la base de données)
  List<String> get _productImages => [
    widget.product.imageUrl ?? 'https://via.placeholder.com/600',
    'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600',
    'https://images.unsplash.com/photo-1609521263047-f8f205293f24?w=600',
    'https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?w=600',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadCategoryData();
    
    // Hide zoom hint after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showZoomHint = false;
        });
      }
    });
  }

  Future<void> _loadCategoryData() async {
    if (widget.product.categoryId == null) {
      setState(() {
        _isLoadingCategory = false;
      });
      return;
    }

    try {
      final category = await _productService.getCategoryById(widget.product.categoryId!);
      if (category != null && category.parentId != null) {
        final parentCategory = await _productService.getCategoryById(category.parentId!);
        setState(() {
          _category = category;
          _parentCategory = parentCategory;
          _isLoadingCategory = false;
        });
      } else {
        setState(() {
          _category = category;
          _isLoadingCategory = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingCategory = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _thumbnailScrollController.dispose();
    super.dispose();
  }

  void _onImageChanged(int index) {
    setState(() {
      _currentImageIndex = index;
    });
    _scrollThumbnailToIndex(index);
  }

  void _scrollThumbnailToIndex(int index) {
    final double thumbnailWidth = 80.0 + 8.0; // width + margin
    final double scrollPosition = (index * thumbnailWidth) - (MediaQuery.of(context).size.width / 2 - thumbnailWidth / 2);
    
    if (_thumbnailScrollController.hasClients) {
      _thumbnailScrollController.animateTo(
        scrollPosition.clamp(0.0, _thumbnailScrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _openImageGallery(int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullScreenGallery(
          images: _productImages,
          initialIndex: initialIndex,
        ),
      ),
    );
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
          'Détails produit',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nom et saison
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (!_isLoadingCategory && _category != null)
                          Row(
                            children: [
                              Icon(_category!.iconData, size: 16, color: Colors.orange),
                              const SizedBox(width: 4),
                              Text(
                                _parentCategory != null
                                    ? '${_parentCategory!.name} › ${_category!.name}'
                                    : _category!.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.red : Colors.black,
                    ),
                    onPressed: () {
                      setState(() {
                        _isFavorite = !_isFavorite;
                      });
                    },
                  ),
                ],
              ),
            ),

            // Main Image Gallery with Zoom
            Stack(
              children: [
                GestureDetector(
                  onTap: () => _openImageGallery(_currentImageIndex),
                  child: SizedBox(
                    height: 350,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _productImages.length,
                      onPageChanged: _onImageChanged,
                      itemBuilder: (context, index) {
                        return Hero(
                          tag: 'product_image_$index',
                          child: CachedNetworkImage(
                            imageUrl: _productImages[index],
                            fit: BoxFit.contain,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[100],
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[100],
                              child: const Icon(
                                Icons.car_repair,
                                size: 100,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                // Zoom Hint Overlay
                if (_showZoomHint)
                  Positioned(
                    top: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: AnimatedOpacity(
                        opacity: _showZoomHint ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 500),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.touch_app,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Appuyez pour zoomer',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Thumbnail Gallery
            SizedBox(
              height: 80,
              child: ListView.builder(
                controller: _thumbnailScrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _productImages.length,
                itemBuilder: (context, index) {
                  final isSelected = index == _currentImageIndex;
                  return GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? Colors.black : Colors.grey[300]!,
                          width: isSelected ? 3 : 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: CachedNetworkImage(
                          imageUrl: _productImages[index],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.car_repair,
                              size: 30,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Prix et bouton Ajouter
                  Row(
                    children: [
                      Text(
                        '${widget.product.price.toStringAsFixed(0)} F',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          final cartService = Provider.of<CartService>(context, listen: false);
                          cartService.addItem(widget.product);
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${widget.product.name} ajouté au panier'),
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 2),
                              action: SnackBarAction(
                                label: 'VOIR',
                                textColor: Colors.white,
                                onPressed: () {
                                  Navigator.pushNamed(context, '/cart');
                                },
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Ajouter',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.description ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                        maxLines: _isDescriptionExpanded ? null : 3,
                        overflow: _isDescriptionExpanded ? null : TextOverflow.ellipsis,
                      ),
                      if (widget.product.description != null && widget.product.description!.length > 100)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isDescriptionExpanded = !_isDescriptionExpanded;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              _isDescriptionExpanded ? 'Lire moins' : 'Lire plus',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Caractéristiques
                  const Text(
                    'Caractéristiques',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: _buildCharacteristics(),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCharacteristics() {
    final List<Widget> characteristics = [];

    // Helper function to add a characteristic with divider
    void addCharacteristic(String label, String value, bool isLast) {
      characteristics.add(
        _CharacteristicItem(
          label: label,
          value: value,
        ),
      );
      if (!isLast) {
        characteristics.add(const Divider(height: 1));
      }
    }

    // Build characteristics from product data
    final List<Map<String, String>> items = [];

    // Add dimensions if available
    if (widget.product.dimensions != null && widget.product.dimensions!.isNotEmpty) {
      final dims = widget.product.dimensions!;
      if (dims['length'] != null) {
        items.add({'label': 'Longueur', 'value': '${dims['length']} cm'});
      }
      if (dims['width'] != null) {
        items.add({'label': 'Largeur', 'value': '${dims['width']} cm'});
      }
      if (dims['height'] != null) {
        items.add({'label': 'Hauteur', 'value': '${dims['height']} cm'});
      }
    }

    // Add weight if available
    if (widget.product.weight != null) {
      items.add({'label': 'Poids', 'value': '${widget.product.weight} kg'});
    }

    // Add brand if available
    if (widget.product.brand != null && widget.product.brand!.isNotEmpty) {
      items.add({'label': 'Marque', 'value': widget.product.brand!});
    }

    // Add SKU if available
    if (widget.product.sku != null && widget.product.sku!.isNotEmpty) {
      items.add({'label': 'Réf. fabriquant', 'value': widget.product.sku!});
    }

    // If no characteristics found, show at least the SKU or a default message
    if (items.isEmpty) {
      items.add({'label': 'Référence', 'value': widget.product.sku ?? 'N/A'});
    }

    // Build the widgets
    for (int i = 0; i < items.length; i++) {
      addCharacteristic(items[i]['label']!, items[i]['value']!, i == items.length - 1);
    }

    return characteristics;
  }
}

class _CharacteristicItem extends StatelessWidget {
  final String label;
  final String value;

  const _CharacteristicItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Full-Screen Zoomable Gallery
class _FullScreenGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _FullScreenGallery({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<_FullScreenGallery> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Zoomable Image Gallery
          PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            builder: (BuildContext context, int index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: CachedNetworkImageProvider(
                  widget.images[index],
                ),
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained * 0.8,
                maxScale: PhotoViewComputedScale.covered * 3,
                heroAttributes: PhotoViewHeroAttributes(
                  tag: 'product_image_$index',
                ),
              );
            },
            itemCount: widget.images.length,
            loadingBuilder: (context, event) => Center(
              child: CircularProgressIndicator(
                value: event == null
                    ? 0
                    : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1),
                color: Colors.white,
              ),
            ),
            backgroundDecoration: const BoxDecoration(
              color: Colors.black,
            ),
            pageController: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),

          // Close Button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Image Counter
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentIndex + 1} / ${widget.images.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  // Close Button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Zoom Instructions (appears briefly)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.pinch,
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Pincez pour zoomer • Glissez pour naviguer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
