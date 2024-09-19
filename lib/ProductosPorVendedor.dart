import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pumitas_emprendedores/DetallesCortosProducto.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductosVendedorPage extends StatelessWidget {
  final String sellerId;

  const ProductosVendedorPage({required this.sellerId, Key? key}) : super(key: key);

  Future<DocumentSnapshot> _getSellerInfo() async {
    return await FirebaseFirestore.instance.collection('sellers').doc(sellerId).get();
  }

  Future<QuerySnapshot> _getSellerProducts() async {
    return await FirebaseFirestore.instance
        .collection('products')
        .where('sellerId', isEqualTo: sellerId)
        .get();
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Productos del vendedor"),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _getSellerInfo(),
        builder: (context, sellerSnapshot) {
          if (sellerSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (sellerSnapshot.hasData && sellerSnapshot.data != null) {
            var sellerData = sellerSnapshot.data!;
            
            return Column(
              children: [
                
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(sellerData['logo']),
                        radius: 40,
                        
                      ),
                      const SizedBox(height: 10),
                      Text(
                        sellerData['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        sellerData['description'] ?? 'Sin descripción',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          
                          if (sellerData['whatsapp'] != null)
                            IconButton(
                              icon: const FaIcon(FontAwesomeIcons.whatsapp,
                                  color: Colors.green),
                              onPressed: () {
                                final whatsappUrl =
                                    'https://wa.me/${sellerData['whatsapp']}?text=Hola!';
                                _launchUrl(whatsappUrl);
                              },
                            ),
                          const SizedBox(width: 20),
                          
                          if (sellerData['instagram'] != null)
                            IconButton(
                              icon: const FaIcon(FontAwesomeIcons.instagram,
                                  color: Colors.purple),
                              onPressed: () {
                                final instagramUrl =
                                    'https://www.instagram.com/${sellerData['instagram']}/';
                                _launchUrl(instagramUrl);
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(),
                
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Productos del vendedor',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                Expanded(
                  child: FutureBuilder<QuerySnapshot>(
                    future: _getSellerProducts(),
                    builder: (context, productsSnapshot) {
                      if (productsSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (productsSnapshot.hasData && productsSnapshot.data != null) {
                        var products = productsSnapshot.data!.docs;

                        if (products.isEmpty) {
                          return const Center(child: Text('Este vendedor no tiene productos.'));
                        }

                        return GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.0,
                          ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            var product = products[index];

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailPage(
                                      productId: product.id, 
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                child: Column(
                                  children: [
                                    Image.network(
                                      product['image'],
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        product['name'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Text('\$${product['price'].toString()}'),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }

                      return const Center(child: Text('No hay productos disponibles.'));
                    },
                  ),
                ),
              ],
            );
          }

          return const Center(child: Text('Error al cargar datos del vendedor.'));
        },
      ),
    );
  }
}

