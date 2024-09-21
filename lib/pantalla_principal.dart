import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pumitas_emprendedores/BaseDeDatos/db_helper.dart';
import 'package:pumitas_emprendedores/BaseDeDatos/usuario.dart';
import 'package:pumitas_emprendedores/producto.dart';
import 'package:pumitas_emprendedores/rutas.dart';
import 'package:pumitas_emprendedores/wigets/background_painter.dart';
import 'package:pumitas_emprendedores/wigets/product_card.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  _PantallaPrincipalState createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  Usuario? _currentUser;
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _allProducts = [];
  final TextEditingController controller = TextEditingController();
  String? _selectedCategory;
  List<String> _categories = [
    'Todos',
    'Ropa',
    'Accesorios',
    'Alimentos',
    'Salud y belleza',
    'Arreglos y regalos',
    'Deportes',
    'Tecnologia',
    'Mascotas',
    'Juegos',
    'Libros',
    'Arte',
    'Otros'
  ];

  @override
  void initState() {
    super.initState();
    _checkUser();
    _loadProducts();
  }

  Future<void> _checkUser() async {
    List<Usuario> usuarios = await DBHelper.queryUsuarios();
    if (usuarios.isNotEmpty) {
      setState(() {
        _currentUser = usuarios.first;
      });
    }
  }

  Future<void> _loadProducts() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference productsCollection = firestore.collection('products');

    QuerySnapshot snapshot = await productsCollection.get();
    setState(() {
      _products = snapshot.docs.map((doc) {
        return {
          'name': doc['name'],
          'description': doc['description'],
          'image': doc['image'],
          'price': doc['price'],
          'category': doc['category'],
          'sellerId': doc['sellerId'],
          'sellerName': doc['sellerName'],
        };
      }).toList();
      _allProducts = List.from(_products);
      _products.shuffle();
      _allProducts.shuffle();
    });
  }

  @override
  void _searchProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        _products = List.from(_allProducts);
      } else {
        final searchLower = query.toLowerCase();
        _products = _allProducts.where((product) {
          final nameLower = product['name'].toLowerCase();
          final categoryLower = product['category'].toLowerCase();
          final descriptionLower = product['description'].toLowerCase();

          return nameLower.contains(searchLower) ||
              categoryLower.contains(searchLower) ||
              descriptionLower.contains(searchLower);
        }).toList();
      }
    });
  }

  void _filterByCategory(String? category) {
    setState(() {
      if (category == 'Todos' || category == null) {
        _products = List.from(_allProducts);
      } else {
        _products = _allProducts
            .where((product) => product['category'] == category)
            .toList();
      }
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(200.0),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft:
                  Radius.circular(40.0), // Borde inferior izquierdo redondeado
              bottomRight:
                  Radius.circular(40.0), // Borde inferior derecho redondeado
            ),
            child: AppBar(
              backgroundColor: Color.fromARGB(255, 33, 46, 127),
              title: const Text(
                'Pumitas Emprendedores',
                style: TextStyle(
                    color: Color.fromARGB(255, 255, 211, 0)), // Letra amarilla
              ),
              flexibleSpace: Padding(
                padding:
                    const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Barra de búsqueda
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(0, 22, 11, 11),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Color.fromARGB(
                              255, 255, 211, 0), // Detalle en amarillo
                          width: 2.0,
                        ),
                      ),
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          hintText: 'Buscar producto...',
                          hintStyle: TextStyle(
                            color: Color.fromARGB(
                                255, 255, 211, 0), // Letra amarilla
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color.fromARGB(255, 255, 211, 0),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none, // Sin borde visible
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 20),
                        ),
                        onChanged: (value) {
                          _searchProducts(
                              value); // Método para buscar productos
                        },
                      ),
                    ),
                    const SizedBox(height: 5),
                    //  categorias
                    Container(
                      height:
                          80, // Ajusta la altura del contenedor si lo necesitas
                      child: ListView.builder(
                        scrollDirection:
                            Axis.horizontal, // Para hacer que sea horizontal
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          String category = _categories[index];
                          IconData icon;

                          // Asignar íconos dependiendo de la categoría
                          switch (category) {
                            case 'Ropa':
                              icon = Icons.shopping_bag;
                              break;
                            case 'Accesorios':
                              icon = Icons.watch;
                              break;
                            case 'Alimentos':
                              icon = Icons.fastfood;
                              break;
                            case 'Salud y belleza':
                              icon = Icons.favorite;
                              break;
                            case 'Arreglos y regalos':
                              icon = Icons.cake;
                              break;
                            case 'Deportes':
                              icon = Icons.sports_soccer;
                              break;
                            case 'Tecnologia':
                              icon = Icons.devices;
                              break;
                            case 'Mascotas':
                              icon = Icons.pets;
                              break;
                            case 'Juegos':
                              icon = Icons.videogame_asset;
                              break;
                            case 'Libros':
                              icon = Icons.book;
                              break;
                            case 'Arte':
                              icon = Icons.palette;
                              break;
                            case 'Otros':
                              icon = Icons.category;
                              break;
                            default:
                              icon = Icons.all_inclusive;
                              break;
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              children: [
                                IconButton(
                                  icon: Icon(icon,
                                      color: Color.fromARGB(
                                          255, 255, 211, 0)), // Color amarillo
                                  onPressed: () {
                                    setState(() {
                                      _selectedCategory = category;
                                    });
                                    _filterByCategory(
                                        category); // Filtrar productos
                                  },
                                ),
                                Text(
                                  category,
                                  style: TextStyle(
                                    color: Color.fromARGB(
                                        255, 255, 211, 0), // Letra amarilla
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
              actions: [
                _currentUser != null
                    ? Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                  context, MyRoutes.PerfilPersonal.name);
                            },
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(_currentUser!.logo),
                                  radius: 20,
                                  backgroundColor: Color.fromARGB(
                                      255, 255, 211, 0), // Borde amarillo
                                ),
                                const SizedBox(width: 10),
                              ],
                            ),
                          ),
                        ],
                      )
                    : IconButton(
                        icon: const Icon(
                          Icons.login,
                          color: Color.fromARGB(
                              255, 255, 211, 0), // Ícono amarillo
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, MyRoutes.Login.name);
                        },
                      ),
              ],
            ),
          ),
        ),
        body: Stack(children: [
          Positioned.fill(
            child: CustomPaint(
              painter: BackgroundPainter(),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: _buildProductList(),
              ),
            ],
          ),
        ]));
  }

  Widget _buildProductList() {
    if (_products.isEmpty) {
      return const Center(
        child: Text(
          'No se encontraron productos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    // Tamaño de la pantalla disponible
    final size = MediaQuery.of(context).size;

    // Calculamos el aspecto de las tarjetas
    final cardWidth =
        size.width / 2 - 16; // Ancho de la tarjeta (considerando margen)
    final cardHeight =
        cardWidth * 1.5; // Altura basada en la relación de aspecto

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Número de columnas
        crossAxisSpacing: 8, // Espacio horizontal entre tarjetas
        mainAxisSpacing: 8, // Espacio vertical entre tarjetas
        childAspectRatio: cardWidth / cardHeight, // Relación de aspecto
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];

        // Añadimos un efecto de animación usando FadeIn o BounceIn
        return FadeInUp(
          // Puedes usar BounceIn, FadeIn, SlideIn, etc.
          duration: Duration(
              milliseconds:
                  250 + index * 200), // Retraso en la animación por tarjeta
          child: ProductCard(
            name: product['name'],
            description: product['description'],
            image: product['image'],
            price: product['price'],
            sellerId: product['sellerId'],
            sellerName: product['sellerName'],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductoPage(
                    name: product['name'],
                    description: product['description'],
                    image: product['image'],
                    price: product['price'],
                    category: product['category'],
                    sellerName: product['sellerName'],
                    sellerId: product['sellerId'],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
/*
Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(200.0),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft:
                  Radius.circular(40.0), // Borde inferior izquierdo redondeado
              bottomRight:
                  Radius.circular(40.0), // Borde inferior derecho redondeado
            ),
            child: AppBar(
              backgroundColor: Color.fromARGB(255, 33, 46, 127),
              title: const Text(
                'Pumitas Emprendedores',
                style: TextStyle(
                    color: Color.fromARGB(255, 255, 211, 0)), // Letra amarilla
              ),
              flexibleSpace: Padding(
                padding:
                    const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Barra de búsqueda
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(0, 22, 11, 11),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Color.fromARGB(
                              255, 255, 211, 0), // Detalle en amarillo
                          width: 2.0,
                        ),
                      ),
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          hintText: 'Buscar producto...',
                          hintStyle: TextStyle(
                            color: Color.fromARGB(
                                255, 255, 211, 0), // Letra amarilla
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color.fromARGB(255, 255, 211, 0),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none, // Sin borde visible
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 20),
                        ),
                        onChanged: (value) {
                          _searchProducts(
                              value); // Método para buscar productos
                        },
                      ),
                    ),
                    const SizedBox(height: 5),
                    //  categorias
                    Container(
                      height:
                          80, // Ajusta la altura del contenedor si lo necesitas
                      child: ListView.builder(
                        scrollDirection:
                            Axis.horizontal, // Para hacer que sea horizontal
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          String category = _categories[index];
                          IconData icon;

                          // Asignar íconos dependiendo de la categoría
                          switch (category) {
                            case 'Ropa':
                              icon = Icons.shopping_bag;
                              break;
                            case 'Accesorios':
                              icon = Icons.watch;
                              break;
                            case 'Alimentos':
                              icon = Icons.fastfood;
                              break;
                            case 'Salud y belleza':
                              icon = Icons.favorite;
                              break;
                            case 'Arreglos y regalos':
                              icon = Icons.cake;
                              break;
                            case 'Deportes':
                              icon = Icons.sports_soccer;
                              break;
                            case 'Tecnologia':
                              icon = Icons.devices;
                              break;
                            case 'Mascotas':
                              icon = Icons.pets;
                              break;
                            case 'Juegos':
                              icon = Icons.videogame_asset;
                              break;
                            case 'Libros':
                              icon = Icons.book;
                              break;
                            case 'Arte':
                              icon = Icons.palette;
                              break;
                            case 'Otros':
                              icon = Icons.category;
                              break;
                            default:
                              icon = Icons.all_inclusive;
                              break;
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              children: [
                                IconButton(
                                  icon: Icon(icon,
                                      color: Color.fromARGB(
                                          255, 255, 211, 0)), // Color amarillo
                                  onPressed: () {
                                    setState(() {
                                      _selectedCategory = category;
                                    });
                                    _filterByCategory(
                                        category); // Filtrar productos
                                  },
                                ),
                                Text(
                                  category,
                                  style: TextStyle(
                                    color: Color.fromARGB(
                                        255, 255, 211, 0), // Letra amarilla
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
              actions: [
                _currentUser != null
                    ? Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                  context, MyRoutes.PerfilPersonal.name);
                            },
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(_currentUser!.logo),
                                  radius: 20,
                                  backgroundColor: Color.fromARGB(
                                      255, 255, 211, 0), // Borde amarillo
                                ),
                                const SizedBox(width: 10),
                              ],
                            ),
                          ),
                        ],
                      )
                    : IconButton(
                        icon: const Icon(
                          Icons.login,
                          color: Color.fromARGB(
                              255, 255, 211, 0), // Ícono amarillo
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, MyRoutes.Login.name);
                        },
                      ),
              ],
            ),
          ),
        ),
        body: Stack(children: [
          Positioned.fill(
            child: CustomPaint(
              painter: BackgroundPainter(),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: _buildProductList(),
              ),
            ],
          ),
        ]));
 */
