import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sushiaya/database/database.dart';
import 'package:sushiaya/models/sushi_item.dart';
// Removed unused home_screen imports

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({Key? key}) : super(key: key);

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  List<SushiItem> products = [];
  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    final loadedProducts = await DatabaseHelper.instance.getAllProducts();
    final loadedCategories = await DatabaseHelper.instance.getCategories();

    setState(() {
      products = loadedProducts;
      categories = loadedCategories;
      isLoading = false;
    });
  }

  Future<void> _deleteProduct(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حذف المنتج', style: GoogleFonts.cairo()),
        content: Text(
          'هل أنت متأكد من حذف هذا المنتج؟',
          style: GoogleFonts.cairo(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء', style: GoogleFonts.cairo()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('حذف', style: GoogleFonts.cairo(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deleteProduct(id);
      _loadData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حذف المنتج بنجاح', style: GoogleFonts.cairo()),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  List<SushiItem> get filteredProducts {
    if (selectedFilter == 'All') return products;
    return products.where((p) => p.category == selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFD5860F), Color(0xFFD5860F)],
            ),
          ),
        ),
        title: Text(
          'إدارة المنتجات',
          style: GoogleFonts.cairo(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFD5860F)),
            )
          : Column(
              children: [
                // Filter Chips
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = selectedFilter == category['name'];

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(
                            category['name'],
                            style: GoogleFonts.cairo(
                              color: isSelected
                                  ? Colors.white
                                  : Color(0xFFD5860F),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              selectedFilter = category['name'];
                            });
                          },
                          backgroundColor: Colors.white,
                          selectedColor: Color(0xFFD5860F),
                          checkmarkColor: Colors.white,
                          elevation: 2,
                          shadowColor: Colors.black.withOpacity(0.1),
                        ),
                      );
                    },
                  ),
                ),

                // Products Count
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'عدد المنتجات: ${filteredProducts.length}',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        selectedFilter,
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFD5860F),
                        ),
                      ),
                    ],
                  ),
                ),

                // Products List
                Expanded(
                  child: filteredProducts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'لا توجد منتجات',
                                style: GoogleFonts.cairo(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            return _buildProductCard(product);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddEditProductScreen(categories: categories),
            ),
          );
          if (result == true) _loadData();
        },
        icon: const Icon(Icons.add),
        label: Text('إضافة منتج', style: GoogleFonts.cairo()),
        backgroundColor: Color(0xFFD5860F),
      ),
    );
  }

  Widget _buildProductCard(SushiItem product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditProductScreen(
                product: product,
                categories: categories,
              ),
            ),
          );
          if (result == true) _loadData();
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: product.image.isEmpty
                      ? const Icon(Icons.image_not_supported, size: 40)
                      : (product.image.startsWith('http')
                            ? Image.network(
                                product.image,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.image_not_supported,
                                      size: 40,
                                    ),
                              )
                            : Image.asset(
                                product.image,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.image_not_supported,
                                      size: 40,
                                    ),
                              )),
                ),
              ),
              const SizedBox(width: 16),

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFFD5860F).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            product.category,
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: Color(0xFFD5860F),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.star, size: 16, color: Colors.amber[700]),
                        const SizedBox(width: 4),
                        Text(
                          product.rating.toString(),
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD5860F),
                      ),
                    ),
                  ],
                ),
              ),

              // Actions
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddEditProductScreen(
                            product: product,
                            categories: categories,
                          ),
                        ),
                      );
                      if (result == true) _loadData();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteProduct(product.id),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// شاشة إضافة/تعديل المنتج
class AddEditProductScreen extends StatefulWidget {
  final SushiItem? product;
  final List<Map<String, dynamic>> categories;

  const AddEditProductScreen({Key? key, this.product, required this.categories})
    : super(key: key);

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _ingredientsController;
  late TextEditingController _ratingController;
  late TextEditingController _imageController;

  String? selectedCategory;
  bool isLoading = false;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController = TextEditingController(
      text: widget.product?.price.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.product?.description ?? '',
    );
    _ingredientsController = TextEditingController(
      text: widget.product?.ingredients.join(',') ?? '',
    );
    _ratingController = TextEditingController(
      text: widget.product?.rating.toString() ?? '4.5',
    );
    _imageController = TextEditingController(text: widget.product?.image ?? '');

    selectedCategory =
        widget.product?.category ??
        (widget.categories.isNotEmpty ? widget.categories[1]['name'] : null);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _ingredientsController.dispose();
    _ratingController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return;

      setState(() => _isUploadingImage = true);

      // Ensure we are authenticated (rules often require auth)
      if (FirebaseAuth.instance.currentUser == null) {
        try {
          await FirebaseAuth.instance.signInAnonymously();
        } catch (_) {}
      }

      final String fileName =
          'products/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = FirebaseStorage.instance.ref(fileName);

      // Perform the upload and await completion (captures failures correctly)
      TaskSnapshot snapshot;
      try {
        snapshot = await ref.putFile(
          File(picked.path),
          SettableMetadata(contentType: 'image/jpeg'),
        );
      } catch (_) {
        // Some devices may fail putFile due to path access; fallback to bytes
        final bytes = await picked.readAsBytes();
        snapshot = await ref.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      }

      if (snapshot.state != TaskState.success) {
        throw Exception('فشل رفع الملف');
      }
      final String url = await snapshot.ref.getDownloadURL();

      _imageController.text = url;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم رفع الصورة بنجاح', style: GoogleFonts.cairo()),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذر رفع الصورة: $e', style: GoogleFonts.cairo()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final String normalizedImagePath = _imageController.text
          .trim()
          .replaceAll('\\', '/');
      final newProduct = SushiItem(
        id:
            widget.product?.id ??
            -1, // Use -1 for new products, will be auto-generated
        name: _nameController.text,
        price: double.parse(_priceController.text),
        rating: double.parse(_ratingController.text),
        image: normalizedImagePath,
        description: _descriptionController.text,
        category: selectedCategory!,
        ingredients: _ingredientsController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
      );

      if (widget.product == null) {
        await DatabaseHelper.instance.insertProduct(newProduct);
      } else {
        await DatabaseHelper.instance.updateProduct(newProduct);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.product == null
                  ? 'تم إضافة المنتج بنجاح'
                  : 'تم تحديث المنتج بنجاح',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: $e', style: GoogleFonts.cairo()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFD5860F), Color(0xFFD5860F)],
            ),
          ),
        ),
        title: Text(
          widget.product == null ? 'إضافة منتج جديد' : 'تعديل المنتج',
          style: GoogleFonts.cairo(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFD5860F)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Product Name
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'معلومات المنتج',
                              style: GoogleFonts.cairo(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD5860F),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'اسم المنتج',
                                labelStyle: GoogleFonts.cairo(),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                prefixIcon: const Icon(Icons.restaurant_menu),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'من فضلك أدخل اسم المنتج';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Category Dropdown
                            DropdownButtonFormField<String>(
                              value: selectedCategory,
                              decoration: InputDecoration(
                                labelText: 'الفئة',
                                labelStyle: GoogleFonts.cairo(),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                prefixIcon: const Icon(Icons.category),
                              ),
                              items: widget.categories
                                  .where((cat) => cat['name'] != 'All')
                                  .map(
                                    (category) => DropdownMenuItem<String>(
                                      value: category['name'] as String,
                                      child: Text(
                                        category['name'] as String,
                                        style: GoogleFonts.cairo(),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedCategory = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'من فضلك اختر الفئة';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Price and Rating Row
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _priceController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'السعر',
                                      labelStyle: GoogleFonts.cairo(),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.attach_money,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'أدخل السعر';
                                      }
                                      if (double.tryParse(value) == null) {
                                        return 'أدخل رقم صحيح';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _ratingController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'التقييم',
                                      labelStyle: GoogleFonts.cairo(),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      prefixIcon: const Icon(Icons.star),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'أدخل التقييم';
                                      }
                                      final rating = double.tryParse(value);
                                      if (rating == null ||
                                          rating < 0 ||
                                          rating > 5) {
                                        return 'التقييم من 0 إلى 5';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الوصف والمكونات',
                              style: GoogleFonts.cairo(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD5860F),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _descriptionController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                labelText: 'الوصف',
                                labelStyle: GoogleFonts.cairo(),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                prefixIcon: const Icon(Icons.description),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'من فضلك أدخل وصف المنتج';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _ingredientsController,
                              maxLines: 2,
                              decoration: InputDecoration(
                                labelText: 'المكونات (مفصولة بفاصلة)',
                                labelStyle: GoogleFonts.cairo(),
                                hintText: 'سلمون، أرز، نوري، خيار',
                                hintStyle: GoogleFonts.cairo(
                                  color: Colors.grey,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                prefixIcon: const Icon(Icons.list),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'من فضلك أدخل المكونات';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Image Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الصورة',
                              style: GoogleFonts.cairo(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD5860F),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _imageController,
                              decoration: InputDecoration(
                                labelText: 'مسار الصورة',
                                labelStyle: GoogleFonts.cairo(),
                                hintText: 'images/product.jpg',
                                hintStyle: GoogleFonts.cairo(
                                  color: Colors.grey,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                prefixIcon: const Icon(Icons.image),
                              ),
                              onChanged: (v) {
                                setState(() {});
                              },
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _isUploadingImage
                                      ? null
                                      : _pickAndUploadImage,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD5860F),
                                  ),
                                  icon: const Icon(
                                    Icons.cloud_upload_rounded,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    'رفع صورة',
                                    style: GoogleFonts.cairo(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                if (_isUploadingImage)
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFFD5860F),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (_imageController.text.isNotEmpty)
                              Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    height: 150,
                                    width: 150,
                                    color: Colors.grey[200],
                                    child: Builder(
                                      builder: (context) {
                                        final String raw = _imageController.text
                                            .trim();
                                        final String normalized = raw
                                            .replaceAll('\\\\', '/')
                                            .replaceAll('\\', '/');
                                        if (normalized.isEmpty) {
                                          return const Icon(
                                            Icons.image_not_supported,
                                            size: 50,
                                          );
                                        }
                                        if (normalized.startsWith('http')) {
                                          return Image.network(
                                            normalized,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Icon(
                                                      Icons.image_not_supported,
                                                      size: 50,
                                                    ),
                                          );
                                        }
                                        return Image.asset(
                                          normalized,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(
                                                    Icons.image_not_supported,
                                                    size: 50,
                                                  ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    ElevatedButton(
                      onPressed: _saveProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFD5860F),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      child: Text(
                        widget.product == null
                            ? 'إضافة المنتج'
                            : 'حفظ التعديلات',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
