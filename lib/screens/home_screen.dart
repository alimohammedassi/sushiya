import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sushiaya/database/database.dart';
import 'package:sushiaya/models/sushi_item.dart';
import 'package:sushiaya/providers/cart_provider.dart';
import 'package:sushiaya/screens/sushi_item_detail.dart';

// Responsive Helper
class ResponsiveHelper {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return baseSize * 0.85;
    if (width < 600) return baseSize;
    if (width < 1200) return baseSize * 1.15;
    return baseSize * 1.25;
  }

  static int getGridCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 2;
    if (width < 900) return 3;
    if (width < 1200) return 4;
    return 5;
  }

  static double getResponsivePadding(BuildContext context) {
    if (isMobile(context)) return 16;
    if (isTablet(context)) return 24;
    return 32;
  }
}

// Enhanced Home Tab Screen
class HomeTabScreen extends StatefulWidget {
  const HomeTabScreen({Key? key}) : super(key: key);

  @override
  State<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen>
    with TickerProviderStateMixin {
  // Controllers
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late AnimationController _searchAnimationController;

  // State variables
  String selectedCategory = 'All';
  String searchQuery = '';
  List<SushiItem> allProducts = [];
  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;
  bool showScrollToTop = false;

  // Search debounce
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadData();
    _setupScrollListener();
  }

  Widget _buildBrandHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SUSHIAYA',
              style: GoogleFonts.poppins(
                color: const Color(0xFFD5860F),
                fontWeight: FontWeight.w800,
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 35),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'What would you like\nto eat today?',
              style: GoogleFonts.poppins(
                color: Colors.black87,
                fontWeight: FontWeight.w700,
                height: 1.1,
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 22),
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animationController.forward();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.offset > 200 && !showScrollToTop) {
        setState(() => showScrollToTop = true);
      } else if (_scrollController.offset <= 200 && showScrollToTop) {
        setState(() => showScrollToTop = false);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    _searchAnimationController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        searchQuery = query;
      });
    });
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    try {
      // Simulate loading with better UX
      await Future.delayed(const Duration(milliseconds: 800));

      final categoriesData = await DatabaseHelper.instance.getCategories();
      final products = await DatabaseHelper.instance.getAllProducts();

      if (mounted) {
        setState(() {
          categories = [
            {'emoji': '🍽️', 'title': 'All', 'key': 'All'},
            ...categoriesData
                .where(
                  (cat) =>
                      (cat['name'] ?? '').toString().toLowerCase() != 'all',
                )
                .map(
                  (cat) => {
                    'emoji': cat['emoji'] ?? '🍽️',
                    'title': cat['name'],
                    'key': cat['name'],
                  },
                )
                .toList(),
          ];
          allProducts = products;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        _showErrorSnackBar('Error loading data');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  List<SushiItem> getFilteredItems() {
    var filtered = allProducts;

    if (selectedCategory != 'All') {
      filtered = filtered
          .where((item) => item.category == selectedCategory)
          .toList();
    }

    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (item) =>
                item.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                item.description.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveHelper.getResponsivePadding(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _loadData,
            color: const Color(0xFFD5860F),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Responsive App Bar
                SliverToBoxAdapter(
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(padding, 20, padding, 0),
                      child: Column(
                        children: [
                          _buildBrandHeader(),
                          const SizedBox(height: 12),
                          _buildEnhancedSearchBar(),
                          const SizedBox(height: 24),
                          _buildResponsiveBanner(),
                          if (categories.isNotEmpty) ...[
                            const SizedBox(height: 26),
                            _buildCategoriesSection(),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                // Section Header
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(padding, 26, padding, 14),
                  sliver: SliverToBoxAdapter(child: _buildSectionHeader()),
                ),

                // Products Grid
                if (isLoading)
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    sliver: SliverToBoxAdapter(child: _buildLoadingGrid()),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(padding, 0, padding, 100),
                    sliver: _buildResponsiveGrid(),
                  ),
              ],
            ),
          ),

          // Floating Action Button for Scroll to Top
          _buildScrollToTopButton(),
        ],
      ),
    );
  }

  Widget _buildEnhancedSearchBar() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        color: Colors.grey[600],
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          style: GoogleFonts.poppins(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              16,
                            ),
                          ),
                          decoration: InputDecoration(
                            hintText: 'home.search_placeholder'.tr(),
                            hintStyle: GoogleFonts.poppins(
                              color: Colors.grey[500],
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context,
                                16,
                              ),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() => searchQuery = '');
                          },
                          icon: Icon(
                            Icons.clear_rounded,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResponsiveBanner() {
    final isTablet = ResponsiveHelper.isTablet(context);
    final isMobile = ResponsiveHelper.isMobile(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          height: isMobile ? 170 : (isTablet ? 200 : 220),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFFD5860F), const Color(0xFFE8941C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD5860F).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _scrollToProducts(),
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  // Decorative circles
                  ...List.generate(3, (index) {
                    final positions = [
                      {'right': -30.0, 'top': -30.0, 'size': 120.0},
                      {'left': -20.0, 'bottom': -20.0, 'size': 80.0},
                      {'right': 50.0, 'bottom': 30.0, 'size': 60.0},
                    ];
                    final pos = positions[index];
                    return Positioned(
                      right: pos['right'],
                      left: pos['left'],
                      top: pos['top'],
                      bottom: pos['bottom'],
                      child: Container(
                        width: pos['size'],
                        height: pos['size'],
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }),

                  // Content
                  Padding(
                    padding: EdgeInsets.all(isMobile ? 20 : 28),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildBadge('🍣 Fresh Daily'),
                              SizedBox(height: isMobile ? 8 : 12),
                              Text(
                                'Premium\nSushi',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                        context,
                                        isMobile ? 28 : 32,
                                      ),
                                  fontWeight: FontWeight.w800,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Authentic Japanese flavors',
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                        context,
                                        14,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isMobile) ...[
                          const SizedBox(width: 20),
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 800),
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.restaurant_menu_rounded,
                                    size: isTablet ? 50 : 60,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            'home.categories'.tr(),
            style: GoogleFonts.poppins(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 22),
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return _buildEnhancedCategoryCard(categories[index], index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedCategoryCard(Map<String, dynamic> category, int index) {
    final isSelected = selectedCategory == category['key'];

    return GestureDetector(
      onTap: () {
        setState(() => selectedCategory = category['key']);
        HapticFeedback.lightImpact();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.only(right: 12, left: index == 0 ? 0 : 0),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [const Color(0xFFD5860F), const Color(0xFFE8941C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFFD5860F).withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 15 : 10,
              offset: const Offset(0, 5),
            ),
          ],
          border: isSelected
              ? null
              : Border.all(color: Colors.grey[200]!, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: isSelected ? 1.2 : 1),
              duration: const Duration(milliseconds: 200),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Text(
                    category['emoji'],
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        28,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              category['title'],
              style: GoogleFonts.poppins(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 13),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              selectedCategory == 'All'
                  ? 'home.popular_today'.tr()
                  : selectedCategory,
              style: GoogleFonts.poppins(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 24),
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            Text(
              '${getFilteredItems().length} ${'items'.tr()}',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        TextButton.icon(
          onPressed: () {
            setState(() => selectedCategory = 'All');
          },
          icon: const Icon(Icons.filter_list_rounded, size: 20),
          label: Text('home.see_all'.tr()),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFD5860F),
            textStyle: GoogleFonts.poppins(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResponsiveGrid() {
    final filteredItems = getFilteredItems();

    if (filteredItems.isEmpty) {
      return SliverToBoxAdapter(child: _buildEmptyState());
    }

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveHelper.getGridCrossAxisCount(context),
        crossAxisSpacing: ResponsiveHelper.isMobile(context) ? 12 : 16,
        mainAxisSpacing: ResponsiveHelper.isMobile(context) ? 12 : 16,
        childAspectRatio: ResponsiveHelper.isMobile(context) ? 0.75 : 0.8,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: Interval(
                    (index / filteredItems.length) * 0.5,
                    1.0,
                    curve: Curves.easeOut,
                  ),
                ),
              ),
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 0.1),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: Interval(
                          (index / filteredItems.length) * 0.5,
                          1.0,
                          curve: Curves.easeOut,
                        ),
                      ),
                    ),
                child: _buildEnhancedFoodCard(filteredItems[index], index),
              ),
            );
          },
        );
      }, childCount: filteredItems.length),
    );
  }

  Widget _buildEnhancedFoodCard(SushiItem item, int index) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: () => _navigateToDetail(item),
          child: Hero(
            tag: 'sushi-${item.id}',
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Section
                  Expanded(
                    flex: 3,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          child: _buildOptimizedImage(item),
                        ),
                      ],
                    ),
                  ),

                  // Content Section
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: GoogleFonts.poppins(
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                        context,
                                        15,
                                      ),
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.category,
                                style: GoogleFonts.poppins(
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                        context,
                                        12,
                                      ),
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${item.price.toStringAsFixed(2)} L.E',
                                style: GoogleFonts.poppins(
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                        context,
                                        18,
                                      ),
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFD5860F),
                                ),
                              ),
                              _buildAddToCartButton(item),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptimizedImage(SushiItem item) {
    if (item.image.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: Center(
          child: Icon(Icons.restaurant_menu, size: 40, color: Colors.grey[400]),
        ),
      );
    }

    if (item.image.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: item.image,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(color: Colors.white),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[200],
          child: const Icon(Icons.error_outline, color: Colors.grey),
        ),
      );
    }

    return Image.asset(
      item.image,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) => Container(
        color: Colors.grey[200],
        child: const Icon(Icons.error_outline, color: Colors.grey),
      ),
    );
  }

  Widget _buildAddToCartButton(SushiItem item) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        final cart = Provider.of<CartProvider>(context, listen: false);
        cart.addItem(item, quantity: 1);
        _showAddToCartAnimation();
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFD5860F), Color(0xFFE8941C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD5860F).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveHelper.getGridCrossAxisCount(context),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      searchQuery.isNotEmpty
                          ? Icons.search_off_rounded
                          : Icons.restaurant_menu_rounded,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              searchQuery.isNotEmpty
                  ? 'No results found'
                  : 'No items available',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20),
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              searchQuery.isNotEmpty
                  ? 'Try searching with different keywords'
                  : 'Check back later for our delicious menu!',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            if (searchQuery.isNotEmpty) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  setState(() => searchQuery = '');
                },
                icon: const Icon(Icons.clear_rounded),
                label: const Text('Clear Search'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD5860F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScrollToTopButton() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      bottom: showScrollToTop ? 100 : -60,
      right: 20,
      child: GestureDetector(
        onTap: _scrollToTop,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFD5860F), Color(0xFFE8941C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD5860F).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_upward_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  void _scrollToProducts() {
    _scrollController.animateTo(
      600,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _navigateToDetail(SushiItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SushiItemDetailScreen(item: item)),
    );
  }

  void _showAddToCartAnimation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text('Added to cart successfully!', style: GoogleFonts.poppins()),
          ],
        ),
        backgroundColor: const Color(0xFFD5860F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
