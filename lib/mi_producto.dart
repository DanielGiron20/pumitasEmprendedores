import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

BuildContext? _dialogContext;
Future<void> showLoadingDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      _dialogContext = context;
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          alignment: Alignment.center,
          height: 100,
          width: 100,
          child: const CircularProgressIndicator(),
        ),
      );
    },
  );
}

class _MiProductoPageState extends State<MiProductoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 33, 46, 127),
        foregroundColor: const Color.fromARGB(255, 255, 211, 0),
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
    Navigator.of(context)
        .push(
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
    )
        .then((value) {
      if (value != null) {
        try {
          Navigator.of(context).pop(value);
        } catch (e) {
          print(e);
        }
      }
    });
  }

  Future<void> _deleteProduct() async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Producto'),
          content:
              const Text('¿Estás seguro que deseas eliminar este producto?'),
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
      showLoadingDialog(context);
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      try {
        QuerySnapshot productQuery = await firestore
            .collection('products')
            .doc('vs products')
            .collection('vs')
            .where('name', isEqualTo: widget.name)
            .where('description', isEqualTo: widget.description)
            .where('price', isEqualTo: widget.price)
            .get();

        if (productQuery.docs.isNotEmpty) {
          String productDocId = productQuery.docs.first.id;

          await firestore
              .collection('products')
              .doc('vs products')
              .collection('vs')
              .doc(productDocId)
              .delete();

          FirebaseStorage.instance.refFromURL(widget.image).delete().then((_) {
            print('Imagen eliminada exitosamente de Storage.');
          }).catchError((error) {
            print('Error al eliminar la imagen: $error');
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Producto borrado con éxito')),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MisProductos(),
            ),
          );
          Navigator.of(_dialogContext!).pop();
        } else {
          Navigator.of(_dialogContext!).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Producto no encontrado'),
                backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        Navigator.of(_dialogContext!).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar el producto: $e')),
        );
      }
    }
  }
}
