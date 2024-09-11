import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductoPage extends StatefulWidget {
  final String name;
  final String description;
  final String image;
  final double price;
  final String category;
  final String sellerName;

  const ProductoPage({
    required this.name,
    required this.description,
    required this.image,
    required this.price,
    required this.category,
    required this.sellerName,
    Key? key,
  }) : super(key: key);

  @override
  _ProductoPageState createState() => _ProductoPageState();
}

class _ProductoPageState extends State<ProductoPage> {
  Map<String, dynamic>? _sellerData;

  @override
  void initState() {
    super.initState();
    _fetchSellerData();
  }

  Future<void> _fetchSellerData() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      QuerySnapshot sellerQuery = await firestore
          .collection('sellers')
          .where('name', isEqualTo: widget.sellerName)
          .get();

      if (sellerQuery.docs.isNotEmpty) {
        Map<String, dynamic> sellerData =
            sellerQuery.docs.first.data() as Map<String, dynamic>;
        setState(() {
          _sellerData = sellerData;
        });
      } else {
        print(
            'No se encontraron vendedores con el nombre ${widget.sellerName}');
      }
    } catch (e) {
      print('Error al cargar los datos del vendedor: $e');
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    launchUrl(uri, mode: LaunchMode.externalApplication);
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
                const Spacer(),
                // Información del vendedor con botones de redes sociales
                if (_sellerData != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          _sellerData!['name'],
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const FaIcon(FontAwesomeIcons.whatsapp,
                                  color: Colors.green),
                              onPressed: () {
                                final whatsappUrl =
                                    'https://wa.me/${_sellerData!['whatsapp']}';
                                _launchUrl(whatsappUrl);
                              },
                            ),
                            const SizedBox(width: 20),
                            IconButton(
                              icon: const FaIcon(FontAwesomeIcons.instagram,
                                  color: Colors.purple),
                              onPressed: () {
                                final instagramUrl =
                                    'https://www.instagram.com/${_sellerData!['instagram']}';
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
