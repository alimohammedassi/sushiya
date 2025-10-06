# SUSHIAYA – Flutter Food Ordering App

SUSHIAYA is a modern Flutter app for browsing sushi items, adding to cart, and placing orders with a smooth checkout experience and simple order tracking.

## Features

- Home catalog with categories, search, and responsive grid
- Product detail page with quantity picker and Add-to-Cart
- Global Cart with quantity increase/decrease, summary, and animated UI
- Checkout bottom sheet with payment method selection and optional card details
- Delivery address selection and “Use current location” (no Google Maps)
- Order placement flow and an Order Status screen showing step-by-step progress
- Admin product management screen (add/edit/delete), including image upload to Firebase Storage and local asset paths

## Key Screens/Files

- `lib/screens/home_screen.dart`: Home grid, categories, search, brand header
- `lib/screens/sushi_item_detail.dart`: Product details and add-to-cart
- `lib/screens/cartPro.dart`: Cart, checkout, payment, address, clear cart
- `lib/screens/order_status_screen.dart`: Live order status and order summary
- `lib/screens/admin/product_management_screen.dart`: Admin products CRUD + image preview/upload

## State Management

- `Provider` with a shared `CartProvider` (in `lib/providers/cart_provider.dart`)
  - Items persist in-memory during app session
  - Methods: `addItem`, `removeItem`, `increaseQuantity`, `decreaseQuantity`, `clearCart`, `processOrder`

## Data Model

- `lib/models/sushi_item.dart`: `SushiItem` (id, name, price, rating, image, description, category, ingredients)
- Cart items are derived from `SushiItem` and keep image, price, quantity, etc.

## Local Database

- `sqflite` via `lib/database/database.dart`
  - Tables: `categories`, `products`
  - Pre-seeded categories (filters) and CRUD helpers

## Location (No Google Maps Required)

- `geolocator` + `geocoding` in `lib/services/location_service.dart`
  - Gets GPS coordinates and reverse-geocodes to a readable address
  - Exposed in checkout via “Use current location” button

## Image Handling

- Products support both:
  - Asset paths under `images/` (declared in `pubspec.yaml`)
  - Remote URLs (e.g., from Firebase Storage)
- Admin screen allows:
  - Manual entry of asset path or URL
  - Upload from device gallery to Firebase Storage (fills the field with the download URL)

## Order Tracking

- After order placement, an Order Status screen shows steps:
  - Order placed → In kitchen → On the way → Delivered
- Includes a full order summary (items with images, qty, totals)
- Back arrow returns you to the Home page

## Tech Stack

- Flutter (Material 3 compatible)
- Provider (state management)
- SQLite via sqflite
- Firebase: Core, Auth (basic), Messaging (installed), Storage (images)
- Geolocator + Geocoding (location without Google Maps)
- UI helpers: google_fonts, cached_network_image, shimmer

## Dependencies (pubspec)

- `provider`, `google_fonts`, `easy_localization`
- `sqflite`, `path`, `path_provider`
- `firebase_core`, `firebase_auth`, `firebase_storage`, `firebase_messaging`, `cloud_firestore` (installed)
- `image_picker`
- `geolocator`, `geocoding`
- `cached_network_image`, `shimmer`, `haptic_feedback`

## Assets

- Declared in `pubspec.yaml` under `assets:`
- Place images in `images/`. Example: `images/Dragon-Roll-0286-I-500x375.jpg`

## Running the App

1. Flutter 3.8+ environment
2. `flutter pub get`
3. Ensure Firebase is initialized (Android: google-services.json, iOS: GoogleService-Info.plist) if using upload/auth
4. `flutter run`

## Notes

- Location requires runtime permission on Android/iOS
- If using Firebase Storage upload, ensure rules allow authenticated writes; anonymous sign-in is attempted for uploads
- Categories skip duplicate "All" rows from the DB, and a single “All” filter is added in UI

## Admin Tips

- To add a product with a local image: set `image` to an asset path like `images/sushi.png`
- To add with a remote image: press “رفع صورة” and select from gallery, or paste a URL

