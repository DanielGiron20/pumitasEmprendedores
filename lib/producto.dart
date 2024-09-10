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
      // Buscar el documento del vendedor usando el sellerName
      QuerySnapshot sellerQuery = await firestore
          .collection('sellers')
          .where('name', isEqualTo: widget.sellerName)
          .get();

      if (sellerQuery.docs.isNotEmpty) {
        // Asumimos que solo hay un documento para cada sellerName
        Map<String, dynamic> sellerData = sellerQuery.docs.first.data() as Map<String, dynamic>;
        setState(() {
          _sellerData = sellerData;
        });
      } else {
        print('No se encontraron vendedores con el nombre ${widget.sellerName}');
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _sellerData == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información del vendedor
                  if (_sellerData != null) ...[
                    CircleAvatar(
                      backgroundImage: NetworkImage(_sellerData!['logo']),
                      radius: 30,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _sellerData!['name'],
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        IconButton(
                          icon: const FaIcon(FontAwesomeIcons.whatsapp),
                          onPressed: () {
                            final whatsappUrl = 'https://wa.me/${_sellerData!['whatsapp']}';
                            _launchUrl(whatsappUrl);
                          },
                        ),
                        IconButton(
                          icon: const FaIcon(FontAwesomeIcons.instagram),
                          onPressed: () {
                            final instagramUrl = 'https://www.instagram.com/${_sellerData!['instagram']}';
                            _launchUrl(instagramUrl);
                          },
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                  // Información del producto
                  Image.network(widget.image),
                  Text('Precio: \$${widget.price.toStringAsFixed(2)}'),
                  const SizedBox(height: 10),
                  Text('Categoría: ${widget.category}'),
                  const SizedBox(height: 10),
                  Text('Descripción: ${widget.description}'),
                ],
              ),
      ),
    );
  }
}
