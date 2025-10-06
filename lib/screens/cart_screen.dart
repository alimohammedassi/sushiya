// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import '../providers/cart_provider.dart';
// import 'button.dart'; // For SushiayaButton

// // ==================== MAIN CART SCREEN ====================

// class CartScreen extends StatefulWidget {
//   const CartScreen({Key? key}) : super(key: key);

//   @override
//   State<CartScreen> createState() => _CartScreenState();
// }

// class _CartScreenState extends State<CartScreen> with TickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );
//     _animationController.forward();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [Color(0xFFD5860F), Color(0xFFB46E0A), Color(0xFF8B5A08)],
//           ),
//         ),
//         child: SafeArea(
//           child: Consumer<CartProvider>(
//             builder: (context, cartProvider, child) {
//               if (cartProvider.isEmpty) {
//                 return _buildEmptyCart();
//               }

//               return FadeTransition(
//                 opacity: _fadeAnimation,
//                 child: Column(
//                   children: [
//                     _buildHeader(cartProvider),
//                     _buildCartItemsList(cartProvider),
//                     _buildCartSummary(cartProvider),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyCart() {
//     return Center(
//       child: FadeTransition(
//         opacity: _fadeAnimation,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(30),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.shopping_cart_outlined,
//                 size: 80,
//                 color: Colors.white.withOpacity(0.8),
//               ),
//             ),
//             const SizedBox(height: 24),
//             Text(
//               'Your cart is empty',
//               style: GoogleFonts.lato(
//                 color: Colors.white,
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 40),
//               child: Text(
//                 'Discover our delicious sushi collection and add your favorites to get started!',
//                 textAlign: TextAlign.center,
//                 style: GoogleFonts.lato(
//                   color: Colors.white.withOpacity(0.8),
//                   fontSize: 16,
//                   height: 1.4,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 32),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader(CartProvider cartProvider) {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'My Cart',
//                 style: GoogleFonts.lato(
//                   color: Colors.white,
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               Text(
//                 '${cartProvider.itemCount} items in cart',
//                 style: GoogleFonts.lato(
//                   color: Colors.white.withOpacity(0.8),
//                   fontSize: 14,
//                 ),
//               ),
//             ],
//           ),
//           Row(
//             children: [
//               if (cartProvider.uniqueItemCount > 0)
//                 Container(
//                   margin: const EdgeInsets.only(right: 10),
//                   child: IconButton(
//                     onPressed: () => _showClearCartDialog(cartProvider),
//                     icon: Icon(
//                       Icons.delete_outline_rounded,
//                       color: Colors.white.withOpacity(0.8),
//                       size: 24,
//                     ),
//                     style: IconButton.styleFrom(
//                       backgroundColor: Colors.white.withOpacity(0.2),
//                       padding: const EdgeInsets.all(12),
//                     ),
//                   ),
//                 ),
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 8,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(25),
//                   boxShadow: [
