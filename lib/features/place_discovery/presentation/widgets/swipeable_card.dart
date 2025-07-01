import 'package:flutter/material.dart';
import 'package:locus_flutter/features/place_discovery/domain/entities/place_with_distance.dart';

class SwipeableCard extends StatefulWidget {
  final PlaceWithDistance placeWithDistance;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final VoidCallback? onTap;
  final bool isTopCard;

  const SwipeableCard({
    super.key,
    required this.placeWithDistance,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onTap,
    this.isTopCard = true,
  });

  @override
  State<SwipeableCard> createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<SwipeableCard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _scaleController;
  Offset _offset = Offset.zero;
  double _rotation = 0;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isTopCard) {
      _scale = 0.9;
    }

    return GestureDetector(
      onTap: widget.onTap,
      onPanStart: widget.isTopCard ? _onPanStart : null,
      onPanUpdate: widget.isTopCard ? _onPanUpdate : null,
      onPanEnd: widget.isTopCard ? _onPanEnd : null,
      child: Transform.translate(
        offset: _offset,
        child: Transform.rotate(
          angle: _rotation,
          child: Transform.scale(
            scale: _scale,
            child: _buildCard(),
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    final place = widget.placeWithDistance.place;
    final overlayColor = _getOverlayColor();

    return Container(
      width: double.infinity,
      height: 500,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            // Background image placeholder
            Container(
              height: 250,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getCategoryColor(place.categoryId),
                    _getCategoryColor(place.categoryId).withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Icon(
                  _getCategoryIcon(place.categoryId),
                  size: 80,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ),

            // Content
            Positioned.fill(
              top: 200,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.placeWithDistance.formattedDistance,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: widget.placeWithDistance.proximityLabel == '매우 가까움'
                                ? Colors.green
                                : widget.placeWithDistance.proximityLabel == '가까움'
                                    ? Colors.orange
                                    : Colors.grey,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.placeWithDistance.proximityLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (place.address?.isNotEmpty == true) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.home,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              place.address ?? '',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],

                    if (place.description?.isNotEmpty == true) ...[
                      const SizedBox(height: 12),
                      Text(
                        place.description ?? '',
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Overlay for swipe feedback
            if (overlayColor != null)
              Container(
                decoration: BoxDecoration(
                  color: overlayColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(
                    _offset.dx > 0 ? Icons.favorite : Icons.close,
                    size: 100,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color? _getOverlayColor() {
    const threshold = 100.0;
    
    if (_offset.dx > threshold) {
      return Colors.green.withOpacity(0.7);
    } else if (_offset.dx < -threshold) {
      return Colors.red.withOpacity(0.7);
    }
    return null;
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

  void _onPanStart(DragStartDetails details) {
    _scaleController.forward();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _offset += details.delta;
      _rotation = _offset.dx / 300 * 0.3;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _scaleController.reverse();
    
    const threshold = 100.0;
    
    if (_offset.dx.abs() > threshold) {
      // Swipe completed
      if (_offset.dx > 0) {
        _swipeRight();
      } else {
        _swipeLeft();
      }
    } else {
      // Return to center
      _resetPosition();
    }
  }

  void _swipeRight() {
    _animationController.forward().then((_) {
      widget.onSwipeRight?.call();
    });
    
    final animation = Tween<Offset>(
      begin: _offset,
      end: Offset(MediaQuery.of(context).size.width, _offset.dy),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    animation.addListener(() {
      setState(() {
        _offset = animation.value;
        _rotation = _offset.dx / 300 * 0.3;
      });
    });
  }

  void _swipeLeft() {
    _animationController.forward().then((_) {
      widget.onSwipeLeft?.call();
    });
    
    final animation = Tween<Offset>(
      begin: _offset,
      end: Offset(-MediaQuery.of(context).size.width, _offset.dy),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    animation.addListener(() {
      setState(() {
        _offset = animation.value;
        _rotation = _offset.dx / 300 * 0.3;
      });
    });
  }

  void _resetPosition() {
    _animationController.forward().then((_) {
      _animationController.reset();
    });
    
    final animation = Tween<Offset>(
      begin: _offset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    animation.addListener(() {
      setState(() {
        _offset = animation.value;
        _rotation = _offset.dx / 300 * 0.3;
      });
    });
  }
}