import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pumitas_emprendedores/Editar_producto.dart';
import 'package:pumitas_emprendedores/mis_productos.dart';

class MiProductoPage extends StatefulWidget {
  final String name;
  final String description;
  final String image;
  final double price;
  final String category;
  final String sellerId;

  const MiProductoPage({
    required this.name,
    required this.description,
    required this.image,
    required this.price,
    required this.category,
    required this.sellerId,
    Key? key,
  }) : super(key: key);
  
  get productId => null;

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
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => EditarProductosPage(
          name: widget.name,
          description: widget.description,
          price: widget.price,
          category: widget.category,
          image: widget.image,
          sellerId: widget.sellerId,
        ),
      ),
    );
  }

  Future<void> _deleteProduct() async {
    
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Producto'),
          content: const Text('¿Estás seguro que deseas eliminar este producto?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), 
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), 
              child: const Text('Sí'),
            ),
          ],
        );
      },
    );

    
    if (confirmDelete) {
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

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Producto borrado con éxito')),
          );

Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MisProductos(
                    ),
                  ),
                );
         
         
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Producto no encontrado')),
          );
        }
      } catch (e) {
       
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar el producto: $e')),
        );
      }
    }
  }
}
