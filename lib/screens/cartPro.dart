import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
// import 'package:shimmer/main.dart';
import 'package:sushiaya/screens/home_screen.dart';
import 'button.dart'; // Your SushiayaButton
import 'package:sushiaya/providers/cart_provider.dart';
import 'package:sushiaya/services/location_service.dart';
import 'package:sushiaya/screens/order_status_screen.dart';

// ==================== MAIN CART SCREEN ====================

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFD5860F), Color(0xFFB46E0A), Color(0xFF8B5A08)],
          ),
        ),
        child: SafeArea(
          child: Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              if (cartProvider.isEmpty) {
                return _buildEmptyCart();
              }

              return FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    _buildHeader(cartProvider),
                    _buildCartItemsList(cartProvider),
                    _buildCartSummary(cartProvider),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 80,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your cart is empty',
              style: GoogleFonts.lato(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Discover our delicious sushi collection and add your favorites to get started!',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Cart',
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${cartProvider.itemCount} items in cart',
                style: GoogleFonts.lato(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Row(
            children: [
              if (cartProvider.uniqueItemCount > 0)
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: IconButton(
                    onPressed: () => _showClearCartDialog(cartProvider),
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.white.withOpacity(0.8),
                      size: 24,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  '${cartProvider.uniqueItemCount}',
                  style: GoogleFonts.lato(
                    color: const Color(0xFFD5860F),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemsList(CartProvider cartProvider) {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: cartProvider.items.length,
        itemBuilder: (context, index) {
          final item = cartProvider.items[index];
          return Dismissible(
            key: Key('cart_item_${item.id}'),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              cartProvider.removeItem(item.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${item.name} removed from cart',
                    style: GoogleFonts.lato(),
                  ),
                  backgroundColor: const Color(0xFFD5860F),
                ),
              );
            },
            background: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.red.shade400,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.centerRight,
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
            child: _buildCartItem(item, cartProvider),
          );
        },
      ),
    );
  }

  Widget _buildCartItem(CartItem item, CartProvider cartProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Hero(
            tag: 'cart_item_${item.id}',
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: item.image.startsWith('http')
                    ? Image.network(
                        item.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.grey.shade400,
                            size: 30,
                          ),
                        ),
                      )
                    : Image.asset(
                        item.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.grey.shade400,
                            size: 30,
                          ),
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD5860F).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.category,
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      color: const Color(0xFFD5860F),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '${item.price.toStringAsFixed(2)} L.E',
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFD5860F),
                      ),
                    ),
                    Text(
                      ' × ${item.quantity}',
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Total: ${item.totalPrice.toStringAsFixed(2)} L.E',
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                IconButton(
                  onPressed: () => cartProvider.increaseQuantity(item.id),
                  icon: Icon(
                    Icons.add_rounded,
                    color: Colors.green.shade600,
                    size: 20,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD5860F).withOpacity(0.1),
                  ),
                  child: Text(
                    item.quantity.toString(),
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFD5860F),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => cartProvider.decreaseQuantity(item.id),
                  icon: Icon(
                    Icons.remove_rounded,
                    color: Colors.red.shade600,
                    size: 20,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartSummary(CartProvider cartProvider) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.receipt_long_rounded,
                  color: const Color(0xFFD5860F),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Order Summary',
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(
              'Subtotal',
              '${cartProvider.totalAmount.toStringAsFixed(2)} L.E',
            ),
            _buildSummaryRow('Delivery Fee', 'Free'),
            _buildSummaryRow('Service Fee', '5.00 L.E'),
            Divider(height: 24, thickness: 1, color: Colors.grey.shade300),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: GoogleFonts.lato(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  '${(cartProvider.totalAmount + 5).toStringAsFixed(2)} L.E',
                  style: GoogleFonts.lato(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFD5860F),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SushiayaButton(
              text: 'Proceed to Checkout',
              width: double.infinity,
              onPressed: () => _showCheckoutBottomSheet(cartProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.lato(fontSize: 16, color: Colors.grey.shade600),
          ),
          Text(
            value,
            style: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(CartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Clear Cart',
            style: GoogleFonts.lato(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to remove all items from your cart?',
            style: GoogleFonts.lato(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.lato(color: Colors.grey.shade600),
              ),
            ),
            TextButton(
              onPressed: () {
                cartProvider.clearCart();
                Navigator.of(context).pop();
              },
              child: Text(
                'Clear',
                style: GoogleFonts.lato(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCheckoutBottomSheet(CartProvider cartProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CheckoutBottomSheet(cartProvider: cartProvider),
    );
  }
}

// ==================== CHECKOUT BOTTOM SHEET ====================

class CheckoutBottomSheet extends StatefulWidget {
  final CartProvider cartProvider;

  const CheckoutBottomSheet({Key? key, required this.cartProvider})
    : super(key: key);

  @override
  State<CheckoutBottomSheet> createState() => _CheckoutBottomSheetState();
}

class _CheckoutBottomSheetState extends State<CheckoutBottomSheet> {
  PaymentMethod? selectedPaymentMethod;
  DeliveryAddress? selectedAddress;

  final _formKey = GlobalKey<FormState>();

  // Controllers for card details
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardholderController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedAddress = widget.cartProvider.selectedAddress;
    selectedPaymentMethod = widget.cartProvider.selectedPaymentMethod;

    if (widget.cartProvider.cardDetails != null) {
      final details = widget.cartProvider.cardDetails!;
      _cardNumberController.text = details.cardNumber;
      _expiryController.text = details.expiryDate;
      _cvvController.text = details.cvv;
      _cardholderController.text = details.cardholderName;
    }

    _cardNumberController.addListener(_updateCardDetails);
    _expiryController.addListener(_updateCardDetails);
    _cvvController.addListener(_updateCardDetails);
    _cardholderController.addListener(_updateCardDetails);
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardholderController.dispose();
    super.dispose();
  }

  void _updateCardDetails() {
    if (selectedPaymentMethod?.requiresCardDetails == true) {
      final details = PaymentCardDetails(
        cardNumber: _cardNumberController.text,
        expiryDate: _expiryController.text,
        cvv: _cvvController.text,
        cardholderName: _cardholderController.text,
        paymentMethodId: selectedPaymentMethod!.id,
      );
      widget.cartProvider.setCardDetails(details);
    }
  }

  bool _validateCardDetails() {
    if (selectedPaymentMethod?.requiresCardDetails != true) return true;

    final cardNumber = _cardNumberController.text;
    final expiryDate = _expiryController.text;
    final cvv = _cvvController.text;
    final cardholderName = _cardholderController.text;

    // Check if all fields are filled
    if (cardNumber.isEmpty ||
        expiryDate.isEmpty ||
        cvv.isEmpty ||
        cardholderName.isEmpty) {
      return false;
    }

    // Validate card number length (without spaces)
    final cleanedNumber = cardNumber.replaceAll(' ', '');
    if (cleanedNumber.length < 13 || cleanedNumber.length > 19) {
      return false;
    }

    // Validate CVV length
    if (cvv.length < 3) {
      return false;
    }

    // Validate expiry date format and future date
    final match = RegExp(r'^(\d{2})/(\d{2})$').firstMatch(expiryDate);
    if (match == null) {
      return false;
    }

    final month = int.tryParse(match.group(1)!);
    final year = int.tryParse(match.group(2)!);
    if (month == null || month < 1 || month > 12) {
      return false;
    }

    final now = DateTime.now();
    final fourDigitYear = 2000 + (year ?? 0);
    final expiryDateTime = DateTime(fourDigitYear, month);
    if (expiryDateTime.isBefore(DateTime(now.year, now.month))) {
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Icon(
                  Icons.payment_rounded,
                  color: const Color(0xFFD5860F),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Checkout',
                  style: GoogleFonts.lato(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Delivery Address Section
                    _SectionTitle(title: 'Delivery Address'),
                    _UseCurrentLocationButton(
                      onResolved: (addr) {
                        setState(() {
                          selectedAddress = DeliveryAddress(
                            id: 'gps',
                            title: 'Current Location',
                            address: addr,
                            city: '',
                            phone:
                                widget.cartProvider.selectedAddress?.phone ??
                                '',
                            isDefault: false,
                          );
                        });
                        widget.cartProvider.setDeliveryAddress(
                          selectedAddress!,
                        );
                      },
                    ),
                    _AddressSelector(
                      addresses: widget.cartProvider.addresses,
                      selectedAddress: selectedAddress,
                      onAddressSelected: (address) {
                        setState(() {
                          selectedAddress = address;
                        });
                        widget.cartProvider.setDeliveryAddress(address);
                      },
                    ),

                    const SizedBox(height: 24),

                    // Payment Method Section
                    _SectionTitle(title: 'Payment Method'),
                    _PaymentMethodSelector(
                      paymentMethods: widget.cartProvider.paymentMethods,
                      selectedMethod: selectedPaymentMethod,
                      onMethodSelected: (method) {
                        setState(() {
                          selectedPaymentMethod = method;
                        });
                        widget.cartProvider.setPaymentMethod(method);
                      },
                    ),

                    if (selectedPaymentMethod?.requiresCardDetails == true) ...[
                      const SizedBox(height: 24),
                      _CardDetailsForm(
                        formKey: _formKey,
                        cardNumberController: _cardNumberController,
                        expiryController: _expiryController,
                        cvvController: _cvvController,
                        cardholderController: _cardholderController,
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Order Summary
                    _SectionTitle(title: 'Order Summary'),
                    _OrderSummary(
                      cartProvider: widget.cartProvider,
                      selectedPaymentMethod: selectedPaymentMethod,
                    ),

                    const SizedBox(height: 100), // Space for button
                  ],
                ),
              ),
            ),
          ),

          // Place Order Button
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Consumer<CartProvider>(
              builder: (context, cartProvider, child) {
                final isReady = cartProvider.isPaymentReady;
                final total = _calculateTotal();
                return SushiayaButton(
                  text: !isReady
                      ? 'Complete Payment Details'
                      : 'Place Order - ${total.toStringAsFixed(2)} L.E',
                  width: double.infinity,
                  onPressed: !isReady ? null : _processOrder,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  double _calculateTotal() {
    double total = widget.cartProvider.totalAmount + 5; // Base + service fee
    if (selectedPaymentMethod?.type == 'cash') {
      total += 2; // Cash handling fee
    }
    return total;
  }

  Future<void> _processOrder() async {
    if (selectedPaymentMethod?.requiresCardDetails == true) {
      if (!_formKey.currentState!.validate()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please complete all card details',
              style: GoogleFonts.lato(),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Additional validation using our custom validator
      if (!_validateCardDetails()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please check your card details and try again',
              style: GoogleFonts.lato(),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      _updateCardDetails();
    }

    if (selectedPaymentMethod == null || selectedAddress == null) return;

    if (!widget.cartProvider.isPaymentReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please complete payment details',
            style: GoogleFonts.lato(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Color(0xFFD5860F)),
            const SizedBox(height: 16),
            Text(
              'Processing your order...',
              style: GoogleFonts.lato(fontSize: 16),
            ),
          ],
        ),
      ),
    );

    try {
      final order = await widget.cartProvider.processOrder();

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        Navigator.of(context).pop(); // Close bottom sheet
        Navigator.of(context).pop(); // Close cart screen

        _showOrderSuccessDialog(order!);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to process order. Please try again.',
              style: GoogleFonts.lato(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showOrderSuccessDialog(Order order) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: Colors.green.shade600,
                size: 50,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Order Placed Successfully!',
              style: GoogleFonts.lato(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Order ID: ${order.id}',
              style: GoogleFonts.lato(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFD5860F).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _InfoRow(
                    label: 'Payment Method:',
                    value: order.cardDetails != null
                        ? '${order.paymentMethod.name} (...${order.cardDetails!.cardNumber.replaceAll(' ', '').substring(order.cardDetails!.cardNumber.replaceAll(' ', '').length - 4)})'
                        : order.paymentMethod.name,
                  ),
                  const SizedBox(height: 4),
                  _InfoRow(
                    label: 'Delivery Address:',
                    value: order.address.title,
                    valueAlignEnd: true,
                  ),
                  const SizedBox(height: 4),
                  _InfoRow(
                    label: 'Estimated Delivery:',
                    value: '30-45 mins',
                    valueColor: const Color(0xFFD5860F),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SushiayaButton(
              text: 'Track Order',
              width: double.infinity,
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => OrderStatusScreen(order: order),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => HomeTabScreen()),
                      (Route<dynamic> route) => false,
                    )
                    .then((_) {
                      Future.delayed(const Duration(milliseconds: 100), () {
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        if (scaffoldMessenger.mounted) {
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                'Welcome back! Happy shopping!',
                                style: GoogleFonts.lato(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              backgroundColor: Colors.green.shade600,
                              duration: const Duration(seconds: 3),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: const EdgeInsets.all(16),
                            ),
                          );
                        }
                      });
                    });
              },
              child: Text(
                'Continue Shopping',
                style: GoogleFonts.lato(color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderTrackingDialog(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.local_shipping_rounded, color: const Color(0xFFD5860F)),
            const SizedBox(width: 8),
            Text(
              'Order Tracking',
              style: GoogleFonts.lato(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTrackingStep('Order Placed', '2:30 PM', true, true),
            _buildTrackingStep('Preparing', '2:45 PM', true, false),
            _buildTrackingStep('Out for Delivery', '3:15 PM', false, false),
            _buildTrackingStep('Delivered', '3:30 PM', false, false),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: GoogleFonts.lato(
                color: const Color(0xFFD5860F),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingStep(
    String title,
    String time,
    bool isCompleted,
    bool isActive,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isCompleted
                  ? const Color(0xFFD5860F)
                  : isActive
                  ? const Color(0xFFD5860F).withOpacity(0.3)
                  : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : isActive
                ? Container(
                    margin: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFD5860F),
                      shape: BoxShape.circle,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: isCompleted || isActive
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: isCompleted || isActive
                    ? Colors.grey.shade800
                    : Colors.grey.shade500,
              ),
            ),
          ),
          Text(
            isCompleted ? time : '',
            style: GoogleFonts.lato(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

// ==================== SMALLER WIDGETS FOR CHECKOUT ====================

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: GoogleFonts.lato(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }
}

class _UseCurrentLocationButton extends StatefulWidget {
  final ValueChanged<String> onResolved;
  const _UseCurrentLocationButton({Key? key, required this.onResolved})
    : super(key: key);

  @override
  State<_UseCurrentLocationButton> createState() =>
      _UseCurrentLocationButtonState();
}

class _UseCurrentLocationButtonState extends State<_UseCurrentLocationButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ElevatedButton.icon(
          onPressed: _loading ? null : _resolve,
          icon: const Icon(Icons.my_location_rounded, color: Colors.white),
          label: Text(
            'Use current location',
            style: GoogleFonts.lato(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD5860F),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _resolve() async {
    setState(() => _loading = true);
    try {
      final service = await LocationService.getCurrent();
      final address =
          service.address ??
          '${service.latitude.toStringAsFixed(5)}, ${service.longitude.toStringAsFixed(5)}';
      widget.onResolved(address);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location set', style: GoogleFonts.lato()),
            backgroundColor: const Color(0xFFD5860F),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location error: $e', style: GoogleFonts.lato()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

class _AddressSelector extends StatelessWidget {
  final List<DeliveryAddress> addresses;
  final DeliveryAddress? selectedAddress;
  final ValueChanged<DeliveryAddress> onAddressSelected;

  const _AddressSelector({
    Key? key,
    required this.addresses,
    required this.selectedAddress,
    required this.onAddressSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: addresses.map((address) {
        final isSelected = selectedAddress?.id == address.id;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => onAddressSelected(address),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFD5860F)
                      : Colors.grey.shade300,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
                color: isSelected
                    ? const Color(0xFFD5860F).withOpacity(0.05)
                    : Colors.grey.shade50,
              ),
              child: Row(
                children: [
                  Icon(
                    address.title == 'Home' ? Icons.home : Icons.work,
                    color: isSelected
                        ? const Color(0xFFD5860F)
                        : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              address.title,
                              style: GoogleFonts.lato(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? const Color(0xFFD5860F)
                                    : Colors.grey.shade800,
                              ),
                            ),
                            if (address.isDefault)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFD5860F,
                                  ).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Default',
                                  style: GoogleFonts.lato(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFD5860F),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          address.address,
                          style: GoogleFonts.lato(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          '${address.city} • ${address.phone}',
                          style: GoogleFonts.lato(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFD5860F),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PaymentMethodSelector extends StatelessWidget {
  final List<PaymentMethod> paymentMethods;
  final PaymentMethod? selectedMethod;
  final ValueChanged<PaymentMethod> onMethodSelected;

  const _PaymentMethodSelector({
    Key? key,
    required this.paymentMethods,
    required this.selectedMethod,
    required this.onMethodSelected,
  }) : super(key: key);

  String _getPaymentMethodDescription(PaymentMethod method) {
    switch (method.type) {
      case 'card':
        return method.name.contains('Visa')
            ? 'Pay securely with your Visa card'
            : 'Pay securely with your Mastercard';
      case 'cash':
        return 'Pay with cash when your order arrives';
      case 'digital':
        return 'Pay with your mobile wallet';
      default:
        return 'Secure payment method';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: paymentMethods.map((method) {
        final isSelected = selectedMethod?.id == method.id;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => onMethodSelected(method),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFD5860F)
                      : Colors.grey.shade300,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
                color: isSelected
                    ? const Color(0xFFD5860F).withOpacity(0.05)
                    : Colors.grey.shade50,
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFD5860F).withOpacity(0.2)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        method.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          method.name,
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? const Color(0xFFD5860F)
                                : Colors.grey.shade800,
                          ),
                        ),
                        Text(
                          _getPaymentMethodDescription(method),
                          style: GoogleFonts.lato(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFD5860F),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CardDetailsForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController cardNumberController;
  final TextEditingController expiryController;
  final TextEditingController cvvController;
  final TextEditingController cardholderController;

  const _CardDetailsForm({
    Key? key,
    required this.formKey,
    required this.cardNumberController,
    required this.expiryController,
    required this.cvvController,
    required this.cardholderController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.credit_card_rounded,
                color: const Color(0xFFD5860F),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Card Details',
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Card Number
          TextFormField(
            controller: cardNumberController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CardNumberInputFormatter(),
            ],
            decoration: InputDecoration(
              labelText: 'Card Number',
              hintText: '1234 5678 9012 3456',
              prefixIcon: Icon(
                Icons.credit_card,
                color: const Color(0xFFD5860F),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFD5860F),
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter card number';
              }
              final cleaned = value.replaceAll(' ', '');
              if (cleaned.length < 13 || cleaned.length > 19) {
                return 'Please enter a valid card number';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              // Expiry Date
              Expanded(
                child: TextFormField(
                  controller: expiryController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    ExpiryDateInputFormatter(),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Expiry Date',
                    hintText: 'MM/YY',
                    prefixIcon: Icon(
                      Icons.date_range,
                      color: const Color(0xFFD5860F),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFD5860F),
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    final match = RegExp(
                      r'^(\d{2})/(\d{2})$',
                    ).firstMatch(value);
                    if (match == null) {
                      return 'Invalid format';
                    }
                    final month = int.tryParse(match.group(1)!);
                    final year = int.tryParse(match.group(2)!);
                    if (month == null || month < 1 || month > 12) {
                      return 'Invalid month';
                    }
                    final now = DateTime.now();
                    final fourDigitYear = 2000 + (year ?? 0);
                    final expiryDate = DateTime(fourDigitYear, month);
                    if (expiryDate.isBefore(DateTime(now.year, now.month))) {
                      return 'Card expired';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(width: 16),

              // CVV
              Expanded(
                child: TextFormField(
                  controller: cvvController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'CVV',
                    hintText: '123',
                    prefixIcon: Icon(
                      Icons.security,
                      color: const Color(0xFFD5860F),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFD5860F),
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    if (value.length < 3) {
                      return 'Invalid CVV';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Cardholder Name
          TextFormField(
            controller: cardholderController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Cardholder Name',
              hintText: 'John Smith',
              prefixIcon: Icon(Icons.person, color: const Color(0xFFD5860F)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFD5860F),
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter cardholder name';
              }
              if (value.length < 2) {
                return 'Please enter a valid name';
              }
              return null;
            },
          ),

          const SizedBox(height: 12),

          // Security Info
          Row(
            children: [
              Icon(Icons.security, size: 16, color: Colors.green.shade600),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your card information is encrypted and secure',
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: Colors.green.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  final CartProvider cartProvider;
  final PaymentMethod? selectedPaymentMethod;

  const _OrderSummary({
    Key? key,
    required this.cartProvider,
    required this.selectedPaymentMethod,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double total = cartProvider.totalAmount + 5;
    if (selectedPaymentMethod?.type == 'cash') {
      total += 2;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _SummaryRow(
            label: 'Items (${cartProvider.itemCount})',
            value: '${cartProvider.totalAmount.toStringAsFixed(2)} L.E',
          ),
          _SummaryRow(label: 'Delivery Fee', value: 'Free'),
          _SummaryRow(label: 'Service Fee', value: '5.00 L.E'),
          if (selectedPaymentMethod?.type == 'cash')
            _SummaryRow(label: 'Cash Handling Fee', value: '2.00 L.E'),

          Divider(height: 24, thickness: 1, color: Colors.grey.shade300),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              Text(
                '${total.toStringAsFixed(2)} L.E',
                style: GoogleFonts.lato(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFD5860F),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({Key? key, required this.label, required this.value})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.lato(fontSize: 14, color: Colors.grey.shade600),
          ),
          Text(
            value,
            style: GoogleFonts.lato(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool valueAlignEnd;
  final Color? valueColor;

  const _InfoRow({
    Key? key,
    required this.label,
    required this.value,
    this.valueAlignEnd = false,
    this.valueColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: valueAlignEnd
          ? MainAxisAlignment.spaceBetween
          : MainAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.lato(fontSize: 12)),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.lato(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.black,
            ),
            textAlign: valueAlignEnd ? TextAlign.end : TextAlign.start,
          ),
        ),
      ],
    );
  }
}
