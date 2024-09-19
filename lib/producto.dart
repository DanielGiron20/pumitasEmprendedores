import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pumitas_emprendedores/ProductosPorVendedor.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math'; 

class ProductoPage extends StatefulWidget {
  final String name;
  final String description;
  final String image;
  final double price;
  final String category;
  final String sellerName;
  final String sellerId;

  const ProductoPage({
    required this.name,
    required this.description,
    required this.image,
    required this.price,
    required this.category,
    required this.sellerName,
    required this.sellerId,
    Key? key,
  }) : super(key: key);

  @override
  _ProductoPageState createState() => _ProductoPageState();
}

class _ProductoPageState extends State<ProductoPage>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _sellerData;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _fetchSellerData();

    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), 
    )..repeat(); 

    _animation = Tween<double>(begin: 0, end: 2 * pi).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

 Future<void> _fetchSellerData() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
   
    DocumentSnapshot sellerDoc = await firestore.collection('sellers').doc(widget.sellerId).get();

    if (sellerDoc.exists) {
      Map<String, dynamic> sellerData = sellerDoc.data() as Map<String, dynamic>;
      
      sellerData['id'] = sellerDoc.id; 

      setState(() {
        _sellerData = sellerData;
      });
    } else {
      print('No se encontró el vendedor con ID ${widget.sellerId}');
    }
  } catch (e) {
    print('Error al cargar los datos del vendedor: $e');
  }
}

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _navigateToSellerProducts() {
   
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductosVendedorPage(sellerId: _sellerData!['id']),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: _sellerData == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Imagen del producto
                Expanded(
                  child: Image.network(
                    widget.image,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 10),
                // Precio del producto
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    '\$${widget.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                  ),
                ),
                const SizedBox(height: 10),
                // Descripción del producto
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    widget.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.justify,
                  ),
                ),
                const SizedBox(height: 10),
                Divider(
                  thickness: 1,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 10),
                if (_sellerData != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Conocer mas productos de ' + _sellerData!['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                         const SizedBox(height: 10),
                        GestureDetector(
                          onTap: _navigateToSellerProducts,
                          child: AnimatedBuilder(
                            animation: _animation,
                            builder: (context, child) {
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  // El borde giratorio
                                  Transform.rotate(
                                    angle: _animation.value,
                                    child: Container(
                                      width: 90,
                                      height: 90,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: SweepGradient(
                                          colors: [
                                          Color.fromARGB(255, 29, 234, 237),
                                          Color.fromARGB(255, 29, 234, 237),
                                          Color.fromARGB(255, 255, 211, 0),
                                         Color.fromARGB(255, 255, 211, 0),
                                        Color.fromARGB(255, 30, 255, 251),
                                          ],
                                          stops: const [
                                            0.0,
                                            0.25,
                                            0.5,
                                            0.75,
                                            1.0
                                          ],
                                          startAngle: 0.0,
                                          endAngle: 2 * pi,
                                        ),
                                      ),
                                    ),
                                  ),

                                  
                                  // El avatar del vendedor
                                  CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(_sellerData!['logo']),
                                    radius: 40,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Nombre del vendedor
                        Text(
                          'Para contactar con ' + _sellerData!['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Botones de redes sociales
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const FaIcon(FontAwesomeIcons.whatsapp,
                                  color: Colors.green),
                                  iconSize: 40,
                              onPressed: () {
                                final whatsappUrl =
                                    'https://wa.me/${_sellerData!['whatsapp']}?text=${Uri.encodeComponent('Vi tu producto ${widget.name} en Pumitas Emprendedores y me interesó')}';
                                _launchUrl(whatsappUrl);
                              },
                            ),
                            const SizedBox(width: 20),
                            IconButton(
                              icon: const FaIcon(FontAwesomeIcons.instagram,
                                  color: Color.fromARGB(255, 176, 39, 142)),
                                  iconSize: 40,
                              onPressed: () {
                                final instagramUrl =
                                    'https://www.instagram.com/${_sellerData!['instagram']}/';
                                _launchUrl(instagramUrl);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
