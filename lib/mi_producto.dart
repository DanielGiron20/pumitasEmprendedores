import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MiProductoPage extends StatefulWidget {
  final String name;
  final String description;
  final String image;
  final double price;
  final String category;

  const MiProductoPage({
    required this.name,
    required this.description,
    required this.image,
    required this.price,
    required this.category,
    Key? key,
  }) : super(key: key);

  @override
  _MiProductoPageState createState() => _MiProductoPageState();
}

class _MiProductoPageState extends State<MiProductoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editProduct,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteProduct,
          ),
        ],
      ),
      body: Column(
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
          const SizedBox(height: 20),
          Divider(
            thickness: 1,
            color: Colors.grey[300],
          ),
        ],
      ),
    );
  }

  Future<void> _editProduct() async {
    // Aquí puedes agregar la lógica para editar el producto
    print('Editar producto: ${widget.name}');
    // Redirige a la pantalla de edición si tienes una.
  }

  Future<void> _deleteProduct() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      QuerySnapshot productQuery = await firestore
          .collection('products')
          .where('name', isEqualTo: widget.name)
          .where('description', isEqualTo: widget.description)
          .get();

      if (productQuery.docs.isNotEmpty) {
        String productDocId = productQuery.docs.first.id;

        await firestore.collection('products').doc(productDocId).delete();
        print('Producto eliminado: ${widget.name}');
        Navigator.of(context).pop();
      } else {
        print('Producto no encontrado: ${widget.name}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto no encontrado')),
        );
      }
    } catch (e) {
      print('Error al eliminar el producto: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al eliminar el producto')),
      );
    }
  }
}
