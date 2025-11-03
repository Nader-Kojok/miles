import 'package:flutter/material.dart';

class ProductReviewsScreen extends StatefulWidget {
  final String productName;

  const ProductReviewsScreen({
    super.key,
    this.productName = 'Plaquettes de frein avant',
  });

  @override
  State<ProductReviewsScreen> createState() => _ProductReviewsScreenState();
}

class _ProductReviewsScreenState extends State<ProductReviewsScreen> {
  String _filterRating = 'all';
  String _sortBy = 'recent';

  // Mock reviews data
  final List<Review> _allReviews = [
    Review(
      id: '1',
      userName: 'Moussa Diop',
      rating: 5,
      date: DateTime.now().subtract(const Duration(days: 2)),
      title: 'Excellent produit',
      comment: 'Très bonne qualité, installation facile. Je recommande vivement !',
      helpful: 12,
      notHelpful: 1,
    ),
    Review(
      id: '2',
      userName: 'Aminata Sall',
      rating: 4,
      date: DateTime.now().subtract(const Duration(days: 5)),
      title: 'Bon rapport qualité-prix',
      comment: 'Produit conforme à la description. Livraison rapide.',
      helpful: 8,
      notHelpful: 0,
    ),
    Review(
      id: '3',
      userName: 'Ibrahima Fall',
      rating: 5,
      date: DateTime.now().subtract(const Duration(days: 10)),
      title: 'Parfait',
      comment: 'Correspond exactement à ce que je cherchais. Excellente qualité.',
      helpful: 15,
      notHelpful: 2,
    ),
    Review(
      id: '4',
      userName: 'Fatou Ndiaye',
      rating: 3,
      date: DateTime.now().subtract(const Duration(days: 15)),
      title: 'Correct',
      comment: 'Produit correct mais j\'attendais un peu mieux pour ce prix.',
      helpful: 5,
      notHelpful: 3,
    ),
  ];

  double get _averageRating {
    if (_allReviews.isEmpty) return 0;
    return _allReviews.map((r) => r.rating).reduce((a, b) => a + b) / _allReviews.length;
  }

  Map<int, int> get _ratingDistribution {
    final Map<int, int> dist = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (var review in _allReviews) {
      dist[review.rating] = (dist[review.rating] ?? 0) + 1;
    }
    return dist;
  }

  List<Review> get _filteredReviews {
    var reviews = _allReviews;
    
    // Filter by rating
    if (_filterRating != 'all') {
      final rating = int.parse(_filterRating);
      reviews = reviews.where((r) => r.rating == rating).toList();
    }
    
    // Sort
    if (_sortBy == 'recent') {
      reviews.sort((a, b) => b.date.compareTo(a.date));
    } else if (_sortBy == 'helpful') {
      reviews.sort((a, b) => b.helpful.compareTo(a.helpful));
    }
    
    return reviews;
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
          'Avis clients',
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
          // Rating Summary
          _buildRatingSummary(),
          
          const Divider(height: 1),
          
          // Filters and Sort
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('Tout', 'all'),
                        const SizedBox(width: 8),
                        _buildFilterChip('5★', '5'),
                        const SizedBox(width: 8),
                        _buildFilterChip('4★', '4'),
                        const SizedBox(width: 8),
                        _buildFilterChip('3★', '3'),
                        const SizedBox(width: 8),
                        _buildFilterChip('2★', '2'),
                        const SizedBox(width: 8),
                        _buildFilterChip('1★', '1'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.sort),
                  onSelected: (value) => setState(() => _sortBy = value),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'recent',
                      child: Text('Plus récents'),
                    ),
                    const PopupMenuItem(
                      value: 'helpful',
                      child: Text('Plus utiles'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Reviews List
          Expanded(
            child: _filteredReviews.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredReviews.length,
                    itemBuilder: (context, index) {
                      return _ReviewCard(review: _filteredReviews[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _writeReview,
        icon: const Icon(Icons.edit, color: Colors.white),
        label: const Text('Écrire un avis', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildRatingSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Average rating
              Column(
                children: [
                  Text(
                    _averageRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        index < _averageRating.round()
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.orange,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_allReviews.length} avis',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 32),
              // Rating bars
              Expanded(
                child: Column(
                  children: [5, 4, 3, 2, 1].map((rating) {
                    final count = _ratingDistribution[rating] ?? 0;
                    final percentage = _allReviews.isEmpty
                        ? 0.0
                        : count / _allReviews.length;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Text('$rating', style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          const Icon(Icons.star, size: 12, color: Colors.orange),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: percentage,
                                backgroundColor: Colors.grey[200],
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.orange,
                                ),
                                minHeight: 8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 20,
                            child: Text(
                              '$count',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterRating == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filterRating = value);
      },
      selectedColor: Colors.black,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.rate_review, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Aucun avis pour ce filtre',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'Soyez le premier à donner votre avis',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  void _writeReview() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _WriteReviewSheet(productName: widget.productName),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey[300],
                child: Text(
                  review.userName[0],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (index) => Icon(
                            index < review.rating ? Icons.star : Icons.star_border,
                            color: Colors.orange,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(review.date),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            review.comment,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton.icon(
                icon: const Icon(Icons.thumb_up_outlined, size: 16),
                label: Text('Utile (${review.helpful})'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
                onPressed: () {},
              ),
              TextButton.icon(
                icon: const Icon(Icons.thumb_down_outlined, size: 16),
                label: Text('(${review.notHelpful})'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    if (difference == 0) return 'Aujourd\'hui';
    if (difference == 1) return 'Hier';
    if (difference < 30) return 'Il y a $difference jours';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _WriteReviewSheet extends StatefulWidget {
  final String productName;

  const _WriteReviewSheet({required this.productName});

  @override
  State<_WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends State<_WriteReviewSheet> {
  int _rating = 0;
  final _titleController = TextEditingController();
  final _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Écrire un avis',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.productName,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            const Text(
              'Votre note',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    size: 40,
                  ),
                  color: Colors.orange,
                  onPressed: () => setState(() => _rating = index + 1),
                );
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Titre de l\'avis',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Votre commentaire',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: _rating > 0 ? _submitReview : null,
              child: const Text('Publier l\'avis'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitReview() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Avis publié avec succès'),
          ],
        ),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class Review {
  final String id;
  final String userName;
  final int rating;
  final DateTime date;
  final String title;
  final String comment;
  final int helpful;
  final int notHelpful;

  Review({
    required this.id,
    required this.userName,
    required this.rating,
    required this.date,
    required this.title,
    required this.comment,
    required this.helpful,
    required this.notHelpful,
  });
}
