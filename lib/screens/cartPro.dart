import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'button.dart'; // Import your SushiayaButton

// Cart Item Model
class CartItem {
  final int id;
  final String name;
  final double price;
  final String image;
  final String category;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.category,
    this.quantity = 1,
  });

  // Calculate total price for this item
  double get totalPrice => price * quantity;

  // Convert from SushiItem to CartItem
  factory CartItem.fromSushiItem(dynamic sushiItem, {int quantity = 1}) {
    return CartItem(
      id: sushiItem.id,
      name: sushiItem.name,
      price: sushiItem.price,
      image: sushiItem.image,
      category: sushiItem.category,
      quantity: quantity,
    );
  }
}

// Cart Provider
class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  // Getters
  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (total, item) => total + item.quantity);

  double get totalAmount =>
      _items.fold(0.0, (total, item) => total + item.totalPrice);

  bool get isEmpty => _items.isEmpty;

  int get uniqueItemCount => _items.length;

  // Add item to cart
  void addItem(dynamic sushiItem, {int quantity = 1}) {
    final existingIndex = _items.indexWhere((item) => item.id == sushiItem.id);

    if (existingIndex >= 0) {
      // Item already exists, update quantity
      _items[existingIndex].quantity += quantity;
    } else {
      // Add new item
      _items.add(CartItem.fromSushiItem(sushiItem, quantity: quantity));
    }

    notifyListeners();
  }

  // Remove item from cart completely
  void removeItem(int itemId) {
    _items.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  // Decrease quantity of an item
  void decreaseQuantity(int itemId) {
    final existingIndex = _items.indexWhere((item) => item.id == itemId);

    if (existingIndex >= 0) {
      if (_items[existingIndex].quantity > 1) {
        _items[existingIndex].quantity--;
      } else {
        _items.removeAt(existingIndex);
      }
      notifyListeners();
    }
  }

  // Increase quantity of an item
  void increaseQuantity(int itemId) {
    final existingIndex = _items.indexWhere((item) => item.id == itemId);

    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
      notifyListeners();
    }
  }

  // Update quantity of an item
  void updateQuantity(int itemId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(itemId);
      return;
    }

    final existingIndex = _items.indexWhere((item) => item.id == itemId);

    if (existingIndex >= 0) {
      _items[existingIndex].quantity = newQuantity;
      notifyListeners();
    }
  }

  // Clear all items from cart
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // Check if item exists in cart
  bool isInCart(int itemId) {
    return _items.any((item) => item.id == itemId);
  }

  // Get quantity of specific item in cart
  int getItemQuantity(int itemId) {
    final item = _items.firstWhere(
      (item) => item.id == itemId,
      orElse: () => CartItem(
        id: -1,
        name: '',
        price: 0,
        image: '',
        category: '',
        quantity: 0,
      ),
    );
    return item.quantity;
  }

  // Get specific item from cart
  CartItem? getCartItem(int itemId) {
    try {
      return _items.firstWhere((item) => item.id == itemId);
    } catch (e) {
      return null;
    }
  }
}

// Cart Screen Widget
class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFD5860F), Color(0xFFB46E0A)],
        ),
      ),
      child: SafeArea(
        child: Consumer<CartProvider>(
          builder: (context, cartProvider, child) {
            if (cartProvider.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 80,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your cart is empty',
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add some delicious sushi to get started!',
                      style: GoogleFonts.lato(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Cart',
                        style: GoogleFonts.lato(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'items${cartProvider.uniqueItemCount} ',
                          style: GoogleFonts.lato(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Cart Items List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: cartProvider.items.length,
                    itemBuilder: (context, index) {
                      final item = cartProvider.items[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Image
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                image: DecorationImage(
                                  image: NetworkImage(item.image),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: GoogleFonts.lato(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item.price.toStringAsFixed(2)}',
                                    style: GoogleFonts.lato(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFD5860F),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Quantity Controls
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () =>
                                        cartProvider.decreaseQuantity(item.id),
                                    icon: const Icon(
                                      Icons.remove_circle_outline_rounded,
                                      size: 21,
                                      color: Colors.red,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 35,
                                      minHeight: 35,
                                    ),
                                  ),
                                  Container(
                                    width: 30,
                                    alignment: Alignment.center,
                                    child: Text(
                                      item.quantity.toString(),
                                      style: GoogleFonts.lato(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        cartProvider.increaseQuantity(item.id),
                                    color: const Color.fromARGB(
                                      255,
                                      45,
                                      179,
                                      19,
                                    ),
                                    icon: const Icon(
                                      Icons.add_circle_outline_outlined,
                                      size: 30,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 35,
                                      minHeight: 35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Total and Checkout
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: GoogleFonts.lato(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${cartProvider.totalAmount.toStringAsFixed(2)} L.E',
                            style: GoogleFonts.lato(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFD5860F),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SushiayaButton(
                        text: 'Proceed to Checkout',
                        width: double.infinity,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Checkout functionality to be implemented',
                                style: GoogleFonts.lato(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              backgroundColor: const Color(0xFFD5860F),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
