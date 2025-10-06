// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:sushiaya/screens/button.dart';
// import 'package:sushiaya/services/firebase_service.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:sushiaya/screens/home_screen.dart';
// import 'package:provider/provider.dart';
// import 'cartPro.dart';

// class SignUpScreen extends StatefulWidget {
//   const SignUpScreen({Key? key}) : super(key: key);

//   @override
//   State<SignUpScreen> createState() => _SignUpScreenState();
// }

// class _SignUpScreenState extends State<SignUpScreen> {
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//   bool _isPasswordVisible = false;
//   bool _isConfirmPasswordVisible = false;
//   bool _isLoading = false;
//   bool _acceptTerms = false;

//   void _handleSignUp() async {
//     if (_formKey.currentState!.validate()) {
//       if (!_acceptTerms) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("يجب الموافقة على الشروط"),
//             backgroundColor: Colors.red,
//           ),
//         );
//         return;
//       }

//       // 📌 هنا نعرض Dialog علشان يختار User or Admin
//       showDialog(
//         context: context,
//         builder: (ctx) => AlertDialog(
//           title: const Text("اختر نوع الحساب"),
//           content: const Text("هل أنت مستخدم عادي أم صاحب المحل (أدمن) ؟"),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(ctx);
//                 _register("user");
//               },
//               child: const Text("User"),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(ctx);
//                 _register("admin");
//               },
//               child: const Text("Admin"),
//             ),
//           ],
//         ),
//       );
//     }
//   }

//   Future<void> _register(String role) async {
//     setState(() => _isLoading = true);

//     try {
//       // انشاء الحساب عبر Firebase Auth
//       final credential = await FirebaseService.createUserWithEmailAndPassword(
//         _emailController.text.trim(),
//         _passwordController.text,
//       );

//       if (credential != null && credential.user != null) {
//         final user = credential.user!;
//         await user.updateDisplayName(_nameController.text.trim());

//         // تخزين بياناته مع الدور المختار
//         await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
//           "uid": user.uid,
//           "name": _nameController.text.trim(),
//           "email": _emailController.text.trim(),
//           "phone": _phoneController.text.trim(),
//           "role": role,
//           "createdAt": FieldValue.serverTimestamp(),
//         });

//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text("تم إنشاء الحساب كـ $role"),
//               backgroundColor: Colors.green,
//             ),
//           );

//           // توجيه حسب الـ role
//           Navigator.pushAndRemoveUntil(
//             context,
//             MaterialPageRoute(
//               builder: (_) => ChangeNotifierProvider(
//                 create: (_) => CartProvider(),
//                 child: HomeTabScreen(showAdminBanner: role == "admin"),
//               ),
//             ),
//             (_) => false,
//           );
//         }
//       }
//     } catch (e) {
//       setState(() => _isLoading = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("خطأ أثناء التسجيل: $e"), backgroundColor: Colors.red),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 213, 134, 15),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(25),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 IconButton(
//                   onPressed: () => Navigator.pop(context),
//                   icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
//                 ),
//                 const SizedBox(height: 30),
//                 Text("إنشاء حساب جديد",
//                     style: GoogleFonts.lato(
//                         color: Colors.white,
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 20),

//                 // الحقول
//                 _buildField(_nameController, "الاسم", Icons.person),
//                 _buildField(_emailController, "الإيميل", Icons.email),
//                 _buildField(_phoneController, "الموبايل", Icons.phone),
//                 _buildField(_passwordController, "كلمة السر", Icons.lock,
//                     isPassword: true),
//                 _buildField(_confirmPasswordController, "تأكيد كلمة السر",
//                     Icons.lock, isPassword: true),

//                 Row(
//                   children: [
//                     Checkbox(
//                         value: _acceptTerms,
//                         onChanged: (v) => setState(() => _acceptTerms = v!)),
//                     const Text("الموافقة على الشروط"),
//                   ],
//                 ),
//                 const SizedBox(height: 20),

//                 SushiayaButton(
//                   text: "Sign Up",
//                   width: double.infinity,
//                   height: 60,
//                   isLoading: _isLoading,
//                   onPressed: _isLoading ? null : _handleSignUp,
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildField(TextEditingController c, String label, IconData icon,
//       {bool isPassword = false}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: TextFormField(
//         controller: c,
//         obscureText: isPassword,
//         validator: (v) => (v == null || v.isEmpty) ? "مطلوب" : null,
//         decoration: InputDecoration(
//           filled: true,
//           fillColor: Colors.white.withOpacity(0.2),
//           prefixIcon: Icon(icon, color: Colors.white),
//           labelText: label,
//           labelStyle: const TextStyle(color: Colors.white),
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//         ),
//       ),
//     );
//   }
// }