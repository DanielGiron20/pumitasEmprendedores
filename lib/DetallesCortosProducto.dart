import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pumitas_emprendedores/wigets/background_painter.dart';

class ProductDetailPage extends StatelessWidget {
  final String productId;

  const ProductDetailPage({required this.productId, Key? key})
      : super(key: key);
  Future<DocumentSnapshot> _getProductDetails() async {
    try {
      return await FirebaseFirestore.instance
          .collection('products')
          .doc('vs products')
          .collection('vs')
          .doc(productId)
          .get();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Detalles del Producto'),
          backgroundColor: const Color.fromARGB(255, 33, 46, 127),
          foregroundColor: const Color.fromARGB(255, 255, 211, 0),
        ),
        body: Stack(children: [
          Positioned.fill(
              child: CustomPaint(
            painter: BackgroundPainter(),
          )),
          FutureBuilder<DocumentSnapshot>(
            future: _getProductDetails(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasData && snapshot.data != null) {
                var productData = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        productData['image'],
                        height: 400,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        productData['name'],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${productData['price'].toString()}',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        productData['description'] ??
                            'No hay descripción disponible.',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return const Center(
                  child: Text('Error al cargar detalles del producto.'));
            },
          ),
        ]));
  }
}
