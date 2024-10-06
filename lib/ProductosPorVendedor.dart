import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pumitas_emprendedores/DetallesCortosProducto.dart';
import 'package:pumitas_emprendedores/wigets/background_painter.dart';
import 'package:pumitas_emprendedores/wigets/product_card.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductosVendedorPage extends StatelessWidget {
  final String sellerId;

  const ProductosVendedorPage({required this.sellerId, Key? key})
      : super(key: key);

  Future<DocumentSnapshot> _getSellerInfo() async {
    return await FirebaseFirestore.instance
        .collection('sellers')
        .doc(sellerId)
        .get();
  }

  Future<QuerySnapshot> _getSellerProducts() async {
    return await FirebaseFirestore.instance
        .collection('products')
        .doc('vs products')
        .collection('vs')
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('fecha', descending: true)
        .get();
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    launchUrl(uri, mode: LaunchMode.externalApplication);
  }

// show dialog para seleccionar razon de reporte, todavia no se hace nada con la razon es solo estetiica actualmente
  void _showReportDialog(BuildContext context, String sellerId) {
    String? selectedReason;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              titlePadding: EdgeInsets.all(0),
              title: Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(15.0)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.report, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      'Reportar vendedor',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: Text('Contenido inapropiado'),
                    value: 'Contenido inapropiado',
                    groupValue: selectedReason,
                    onChanged: (String? value) {
                      setState(() {
                        selectedReason = value;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text('Fraude'),
                    value: 'Fraude',
                    groupValue: selectedReason,
                    onChanged: (String? value) {
                      setState(() {
                        selectedReason = value;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text('Incitación al odio'),
                    value: 'Incitación al odio',
                    groupValue: selectedReason,
                    onChanged: (String? value) {
                      setState(() {
                        selectedReason = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.grey[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text('Enviar reporte'),
                  onPressed: () {
                    if (selectedReason != null) {
                      FirebaseFirestore.instance
                          .collection('sellers')
                          .doc(sellerId)
                          .update({'reporte': FieldValue.increment(1)});

                      Navigator.of(context).pop();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Reporte enviado correctamente'),
                          backgroundColor: Colors.blue,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Por favor selecciona un motivo'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _submitReport(
      BuildContext context, String sellerId, String reason) async {
    try {
      DocumentReference sellerDoc =
          FirebaseFirestore.instance.collection('sellers').doc(sellerId);

      await sellerDoc.update({
        'reporte': FieldValue.increment(1),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reporte enviado correctamente'),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al enviar el reporte'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Productos del vendedor"),
          backgroundColor: const Color.fromARGB(255, 33, 46, 127),
          foregroundColor: const Color.fromARGB(255, 255, 211, 0),
        ),
        body: Stack(children: [
          Positioned.fill(
            child: CustomPaint(
              painter: BackgroundPainter(),
            ),
          ),
          Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 40.0,
            ),
            child: FutureBuilder<DocumentSnapshot>(
              future: _getSellerInfo(),
              builder: (context, sellerSnapshot) {
                if (sellerSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (sellerSnapshot.hasData && sellerSnapshot.data != null) {
                  var sellerData = sellerSnapshot.data!;

                  return SingleChildScrollView(
                    // Hace todo el contenido scroleable
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              CircleAvatar(
                                backgroundImage:
                                    NetworkImage(sellerData['logo']),
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
                                      icon: const FaIcon(
                                          FontAwesomeIcons.whatsapp,
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
                                      icon: const FaIcon(
                                          FontAwesomeIcons.instagram,
                                          color: Colors.purple),
                                      onPressed: () {
                                        final instagramUrl =
                                            'https://www.instagram.com/${sellerData['instagram']}/';
                                        _launchUrl(instagramUrl);
                                      },
                                    ),
                                  const SizedBox(width: 20),
                                  IconButton(
                                    icon: const Icon(Icons.flag,
                                        color: Colors.red),
                                    onPressed: () {
                                      _showReportDialog(context, sellerId);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
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
                        const Divider(),
                        FutureBuilder<QuerySnapshot>(
                          future: _getSellerProducts(),
                          builder: (context, productsSnapshot) {
                            if (productsSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (productsSnapshot.hasData &&
                                productsSnapshot.data != null) {
                              var products = productsSnapshot.data!.docs;

                              if (products.isEmpty) {
                                return const Center(
                                    child: Text(
                                        'Este vendedor no tiene productos.'));
                              }

                              return GridView.builder(
                                shrinkWrap:
                                    true, // Esto permite que el GridView se ajuste al contenido
                                physics:
                                    const NeverScrollableScrollPhysics(), // El GridView no maneja su propio scroll
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2, // Número de columnas
                                  crossAxisSpacing:
                                      8, // Espacio horizontal entre tarjetas
                                  mainAxisSpacing:
                                      8, // Espacio vertical entre tarjetas
                                  childAspectRatio: 2 /
                                      3, // Relación de aspecto de las tarjetas
                                ),
                                itemCount: products.length,
                                itemBuilder: (context, index) {
                                  var product = products[index];

                                  return FadeInUp(
                                    duration: Duration(
                                        milliseconds: 250 + index * 200),
                                    child: ProductCard(
                                      name: product['name'],
                                      description: product['description'],
                                      image: product['image'],
                                      price: product['price'],
                                      sellerId: product['sellerId'],
                                      sellerName: sellerData['name'],
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ProductDetailPage(
                                              productId: product
                                                  .id, // Pasamos el ID del producto
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              );
                            }

                            return const Center(
                                child: Text('No hay productos disponibles.'));
                          },
                        ),
                      ],
                    ),
                  );
                }

                return const Center(
                    child: Text('Error al cargar datos del vendedor.'));
              },
            ),
          ),
        ]));
  }
}
