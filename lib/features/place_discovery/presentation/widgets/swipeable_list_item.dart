import 'package:flutter/material.dart';
import 'package:locus_flutter/features/place_discovery/domain/entities/place_with_distance.dart';

class SwipeableListItem extends StatefulWidget {
  final PlaceWithDistance placeWithDistance;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final VoidCallback? onTap;

  const SwipeableListItem({
    super.key,
    required this.placeWithDistance,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onTap,
  });

  @override
  State<SwipeableListItem> createState() => _SwipeableListItemState();
}

class _SwipeableListItemState extends State<SwipeableListItem>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  double _dragExtent = 0;
  bool _dragUnderway = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final place = widget.placeWithDistance.place;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_dragExtent, 0),
          child: Stack(
            children: [
              // Background actions
              _buildBackground(),

              // Main card
              GestureDetector(
                onTap: widget.onTap,
                onHorizontalDragStart: _onDragStart,
                onHorizontalDragUpdate: _onDragUpdate,
                onHorizontalDragEnd: _onDragEnd,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Category icon
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _getCategoryColor(place.categoryId),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Icon(
                            _getCategoryIcon(place.categoryId),
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Place info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                place.name,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),

                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.placeWithDistance.formattedDistance,
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          widget
                                                      .placeWithDistance
                                                      .proximityLabel ==
                                                  '매우 가까움'
                                              ? Colors.green
                                              : widget
                                                      .placeWithDistance
                                                      .proximityLabel ==
                                                  '가까움'
                                              ? Colors.orange
                                              : Colors.grey,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      widget.placeWithDistance.proximityLabel,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              if (place.address?.isNotEmpty == true) ...[
                                const SizedBox(height: 4),
                                Text(
                                  place.address ?? '',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],

                              if (place.description?.isNotEmpty == true) ...[
                                const SizedBox(height: 4),
                                Text(
                                  place.description ?? '',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 12,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Swipe indicator
                        if (_dragUnderway)
                          Icon(
                            _dragExtent > 0 ? Icons.favorite : Icons.close,
                            color: _dragExtent > 0 ? Colors.green : Colors.red,
                            size: 24,
                          )
                        else
                          Icon(
                            Icons.drag_handle,
                            color: Colors.grey[400],
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBackground() {
    // final screenWidth = MediaQuery.of(context).size.width; // Currently unused

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 120, // Approximate height of the list item
      child: Row(
        children: [
          // Left action (dislike)
          if (_dragExtent < 0)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.close, color: Colors.white, size: 24),
                      SizedBox(width: 8),
                      Text(
                        '싫어요',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Right action (like)
          if (_dragExtent > 0)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite, color: Colors.white, size: 24),
                      SizedBox(width: 8),
                      Text(
                        '좋아요',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
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

  Color _getCategoryColor(String categoryId) {
    switch (categoryId) {
      case 'cat_restaurant':
        return const Color(0xFF2196F3);
      case 'cat_cafe':
        return const Color(0xFF8D6E63);
      case 'cat_shopping':
        return const Color(0xFFE91E63);
      case 'cat_entertainment':
        return const Color(0xFF9C27B0);
      case 'cat_travel':
        return const Color(0xFF4CAF50);
      case 'cat_healthcare':
        return const Color(0xFFF44336);
      case 'cat_education':
        return const Color(0xFF607D8B);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  IconData _getCategoryIcon(String categoryId) {
    switch (categoryId) {
      case 'cat_restaurant':
        return Icons.restaurant;
      case 'cat_cafe':
        return Icons.local_cafe;
      case 'cat_shopping':
        return Icons.shopping_bag;
      case 'cat_entertainment':
        return Icons.movie;
      case 'cat_travel':
        return Icons.place;
      case 'cat_healthcare':
        return Icons.local_hospital;
      case 'cat_education':
        return Icons.school;
      default:
        return Icons.category;
    }
  }

  void _onDragStart(DragStartDetails details) {
    setState(() {
      _dragUnderway = true;
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final delta = details.primaryDelta ?? 0;
    // final screenWidth = MediaQuery.of(context).size.width; // Currently unused
    const maxDragExtent = 150.0;

    setState(() {
      _dragExtent = (_dragExtent + delta).clamp(-maxDragExtent, maxDragExtent);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    const threshold = 80.0;

    if (_dragExtent.abs() > threshold) {
      // Complete the swipe
      if (_dragExtent > 0) {
        _completeSwipeRight();
      } else {
        _completeSwipeLeft();
      }
    } else {
      // Return to center
      _resetPosition();
    }
  }

  void _completeSwipeRight() {
    _animationController.forward().then((_) {
      widget.onSwipeRight?.call();
      _resetAfterSwipe();
    });

    final animation = Tween<double>(
      begin: _dragExtent,
      end: MediaQuery.of(context).size.width,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    animation.addListener(() {
      setState(() {
        _dragExtent = animation.value;
      });
    });
  }

  void _completeSwipeLeft() {
    _animationController.forward().then((_) {
      widget.onSwipeLeft?.call();
      _resetAfterSwipe();
    });

    final animation = Tween<double>(
      begin: _dragExtent,
      end: -MediaQuery.of(context).size.width,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    animation.addListener(() {
      setState(() {
        _dragExtent = animation.value;
      });
    });
  }

  void _resetPosition() {
    _animationController.forward().then((_) {
      _animationController.reset();
      setState(() {
        _dragUnderway = false;
      });
    });

    final animation = Tween<double>(begin: _dragExtent, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    animation.addListener(() {
      setState(() {
        _dragExtent = animation.value;
      });
    });
  }

  void _resetAfterSwipe() {
    _animationController.reset();
    setState(() {
      _dragExtent = 0;
      _dragUnderway = false;
    });
  }
}
