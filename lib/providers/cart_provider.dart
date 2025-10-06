import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sushiaya/screens/home_screen.dart'; // For SushiItem
import '../screens/button.dart'; // Assuming this exists for SushiayaButton

// ==================== MODELS ====================

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

  double get totalPrice => price * quantity;

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

// Payment Method Model
class PaymentMethod {
  final String id;
  final String name;
  final String icon;
  final String type; // 'card', 'cash', 'digital'
  final bool requiresCardDetails;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
    this.requiresCardDetails = true,
  });
}

// Payment Card Details Model
class PaymentCardDetails {
  final String cardNumber;
  final String expiryDate;
  final String cvv;
  final String cardholderName;
  final String paymentMethodId;

  PaymentCardDetails({
    required this.cardNumber,
    required this.expiryDate,
    required this.cvv,
    required this.cardholderName,
    required this.paymentMethodId,
  });

  bool get isValid {
    final cleanedNumber = cardNumber.replaceAll(' ', '');
    return cardNumber.isNotEmpty &&
        expiryDate.isNotEmpty &&
        cvv.isNotEmpty &&
        cardholderName.isNotEmpty &&
        cleanedNumber.length >= 13 &&
        cleanedNumber.length <= 19 &&
        cvv.length >= 3;
  }

  String get maskedCardNumber {
    final cleaned = cardNumber.replaceAll(' ', '');
    if (cleaned.length < 4) return cleaned;
    return '**** **** **** ${cleaned.substring(cleaned.length - 4)}';
  }
}

// Delivery Address Model
class DeliveryAddress {
  final String id;
  final String title;
  final String address;
  final String city;
  final String phone;
  final bool isDefault;

  DeliveryAddress({
    required this.id,
    required this.title,
    required this.address,
    required this.city,
    required this.phone,
    this.isDefault = false,
  });
}

// Order Model
class Order {
  final String id;
  final List<CartItem> items;
  final double total;
  final PaymentMethod paymentMethod;
  final PaymentCardDetails? cardDetails;
  final DeliveryAddress address;
  final DateTime orderDate;
  final String status;

  Order({
    required this.id,
    required this.items,
    required this.total,
    required this.paymentMethod,
    this.cardDetails,
    required this.address,
    required this.orderDate,
    this.status = 'pending',
  });
}

// ==================== PROVIDER ====================

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  bool _isLoading = false;
  PaymentMethod? _selectedPaymentMethod;
  PaymentCardDetails? _cardDetails;
  DeliveryAddress? _selectedAddress;

  final List<PaymentMethod> _paymentMethods = [
    PaymentMethod(
      id: 'visa',
      name: 'Visa Card',
      icon: '💳',
      type: 'card',
      requiresCardDetails: true,
    ),
    PaymentMethod(
      id: 'mastercard',
      name: 'Mastercard',
      icon: '💳',
      type: 'card',
      requiresCardDetails: true,
    ),
    PaymentMethod(
      id: 'cash',
      name: 'Cash on Delivery',
      icon: '💵',
      type: 'cash',
      requiresCardDetails: false,
    ),
    PaymentMethod(
      id: 'wallet',
      name: 'Digital Wallet',
      icon: '📱',
      type: 'digital',
      requiresCardDetails: false,
    ),
  ];

  final List<DeliveryAddress> _addresses = [
    DeliveryAddress(
      id: '1',
      title: 'Home',
      address: '123 Main Street, Apt 4B',
      city: 'Alexandria',
      phone: '+20 123 456 789',
      isDefault: true,
    ),
    DeliveryAddress(
      id: '2',
      title: 'Work',
      address: '456 Business District',
      city: 'Alexandria',
      phone: '+20 987 654 321',
    ),
  ];

  // Getters
  List<CartItem> get items => List.unmodifiable(_items);
  List<PaymentMethod> get paymentMethods => _paymentMethods;
  List<DeliveryAddress> get addresses => _addresses;
  PaymentMethod? get selectedPaymentMethod => _selectedPaymentMethod;
  PaymentCardDetails? get cardDetails => _cardDetails;
  DeliveryAddress? get selectedAddress =>
      _selectedAddress ??
      _addresses.firstWhere(
        (addr) => addr.isDefault,
        orElse: () => _addresses.first,
      );
  bool get isLoading => _isLoading;
  int get itemCount => _items.fold(0, (total, item) => total + item.quantity);
  double get totalAmount =>
      _items.fold(0.0, (total, item) => total + item.totalPrice);
  bool get isEmpty => _items.isEmpty;
  int get uniqueItemCount => _items.length;

  // Setters
  void setPaymentMethod(PaymentMethod method) {
    _selectedPaymentMethod = method;
    if (!method.requiresCardDetails) {
      _cardDetails = null;
    }
    notifyListeners();
  }

  void setCardDetails(PaymentCardDetails details) {
    _cardDetails = details;
    notifyListeners();
  }

  void setDeliveryAddress(DeliveryAddress address) {
    _selectedAddress = address;
    notifyListeners();
  }

  bool get isPaymentReady {
    if (_selectedPaymentMethod == null) return false;
    if (_selectedPaymentMethod!.requiresCardDetails) {
      return _cardDetails != null && _cardDetails!.isValid;
    }
    return true;
  }

  Future<void> addItem(dynamic sushiItem, {int quantity = 1}) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    final existingIndex = _items.indexWhere((item) => item.id == sushiItem.id);

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(CartItem.fromSushiItem(sushiItem, quantity: quantity));
    }

    _isLoading = false;
    notifyListeners();
  }

  void removeItem(int itemId) {
    _items.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

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

  void increaseQuantity(int itemId) {
    final existingIndex = _items.indexWhere((item) => item.id == itemId);

    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));
    _items.clear();

    _isLoading = false;
    notifyListeners();
  }

  Future<Order?> processOrder() async {
    if (_items.isEmpty || !isPaymentReady) return null;

    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    final order = Order(
      id: 'ORD${DateTime.now().millisecondsSinceEpoch}',
      items: List.from(_items),
      total: totalAmount + 5, // Including service fee
      paymentMethod: _selectedPaymentMethod!,
      cardDetails: _cardDetails,
      address: selectedAddress!,
      orderDate: DateTime.now(),
    );

    _items.clear();
    _selectedPaymentMethod = null;
    _cardDetails = null;

    _isLoading = false;
    notifyListeners();

    return order;
  }

  bool isInCart(int itemId) {
    return _items.any((item) => item.id == itemId);
  }

  int getItemQuantity(int itemId) {
    try {
      return _items.firstWhere((item) => item.id == itemId).quantity;
    } catch (e) {
      return 0;
    }
  }

  CartItem? getCartItem(int itemId) {
    try {
      return _items.firstWhere((item) => item.id == itemId);
    } catch (e) {
      return null;
    }
  }
}

// ==================== INPUT FORMATTERS ====================

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text.replaceAll(' ', '');

    if (newText.length > 19) {
      return oldValue;
    }

    final buffer = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      buffer.write(newText[i]);
      if ((i + 1) % 4 == 0 && i + 1 != newText.length) {
        buffer.write(' ');
      }
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text.replaceAll('/', '');

    if (newText.length > 4) {
      return oldValue;
    }

    String formatted = newText;
    if (newText.length > 2) {
      formatted = '${newText.substring(0, 2)}/${newText.substring(2)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
