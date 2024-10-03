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
  final ScrollController _scrollController = ScrollController();

  String? _selectedCategory;
  List _filteredProducts = [];
  int _selectedCategoryIndex = 0;
  final List<String> _categories = [
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

  int _pageSize = 8; //Cantidad de productos por petición
  DocumentSnapshot? _lastDocument; //Ultimo documento cargado

  bool _hasMoreProducts =
      true; //variable bandera para indicar si hay más productos que cargar

  @override
  void initState() {
    super.initState();
    _checkUser();
    _scrollController.addListener(
        _scrollListener); // al cargar la app se carga el scrollListener
    _loadProducts(isInitialLoad: true); //y se arga la primera petición
  }


  Future<void> _checkUser() async {
    // funcion para comprobar si hay un usuario logueado
    List<Usuario> usuarios = await DBHelper.queryUsuarios();
    if (usuarios.isNotEmpty) {
      setState(() {
        _currentUser = usuarios.first;
      });
    }
  }

  Future<void> _loadProducts({bool isInitialLoad = false}) async {
    //funcion para cargar los productos
    if (!_hasMoreProducts && !isInitialLoad)
      return; // Si ya no hay más productos, no cargara más

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference productsCollection =
        firestore.collection('products').doc('vs products').collection('vs');
    // Referencia a la colección de productos

    Query query =
        productsCollection.orderBy('fecha', descending: true).limit(_pageSize); // Limitar a _pageSize productos

    if (_lastDocument != null && !isInitialLoad) {
      query = query.startAfterDocument(
          _lastDocument!); // Empezar después del último documento cargado
    }

    QuerySnapshot snapshot = await query.get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        _products.addAll(snapshot.docs.map((doc) {
          // Agregar los nuevos productos a la lista existente
          return {
            'name': doc['name'],
            'description': doc['description'],
            'image': doc['image'],
            'price': doc['price'],
            'category': doc['category'],
            'sellerId': doc['sellerId'],
            'sellerName': doc['sellerName'],
            'fecha': doc['fecha'],
            'keywords': doc['keywords'],
          };
        }).toList());

        _allProducts =
            List.from(_products); // Actualizar la lista de todos los productos
        _lastDocument =
            snapshot.docs.last; // Actualizar el último documento cargado

        if (snapshot.docs.length < _pageSize) {
          //validar si hay mas productos que cargar
          _hasMoreProducts = false;
        }
      });
    } else {
      setState(() {
        _hasMoreProducts = false;
      });
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (_selectedCategory == null || _selectedCategory == 'Todos') {
        _loadProducts();
      } else {
        _loadProductsByCategory(_selectedCategory!);
      }
    }
  }

  // Esta funciones se modificara a fin de que sean paginadas
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

// Esta funciones se modificara a fin de que sean paginadas
  void _filterByCategory(String? category) async {
    setState(() {
      _selectedCategory = category;
      _filteredProducts = [];
      _hasMoreProducts = true; // Reiniciar la variable de más productos
      _lastDocument = null; // Reiniciar el último documento cargado
    });

    if (category == 'Todos' || category == null) {
      _products = []; // Limpiar la lista de productos
      _loadProducts(isInitialLoad: true);
    } else {
      await _loadProductsByCategory(category);
    }
  }

  Future<void> _loadProductsByCategory(String category) async {
    if (!_hasMoreProducts && _filteredProducts.isNotEmpty) return;

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference productsCollection =
        firestore.collection('products').doc('vs products').collection('vs');

    Query query = productsCollection
        .where('category', isEqualTo: category).
        orderBy('fecha', descending: true) .limit(_pageSize);

    if (_lastDocument != null && _filteredProducts.isNotEmpty) {
      query = query.startAfterDocument(_lastDocument!);
    }

    QuerySnapshot snapshot = await query.get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        _filteredProducts.addAll(snapshot.docs.map((doc) {
          return {
            'name': doc['name'],
            'description': doc['description'],
            'image': doc['image'],
            'price': doc['price'],
            'category': doc['category'],
            'sellerId': doc['sellerId'],
            'sellerName': doc['sellerName'],
            'fecha': doc['fecha'],
            'keywords': doc['keywords'],
          };
        }).toList());

        _lastDocument = snapshot.docs.last;

        if (snapshot.docs.length < _pageSize) {
          _hasMoreProducts = false;
        }
      });
    } else {
      setState(() {
        _hasMoreProducts = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 33, 46, 127),
        foregroundColor: const Color.fromARGB(255, 255, 211, 0),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: FittedBox(
            fit: BoxFit.contain,
            child: Stack(
              children: [
                // Texto con borde amarillo (sin color interior)
                Text(
                  '      Pumarket',
                  style: TextStyle(
                    fontFamily: 'Coolvetica',
                    fontWeight: FontWeight.w700,
                    fontSize: 48,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 4
                      ..color = const Color.fromARGB(
                          255, 255, 211, 0), // Borde amarillo
                  ),
                ),
                Text(
                  '      Pumarket',
                  style: const TextStyle(
                    fontFamily: 'Coolvetica',
                    fontWeight: FontWeight.w400,
                    fontSize: 48,
                    color: Color.fromARGB(254, 33, 46, 127),
                    shadows: [
                      Shadow(
                        offset: Offset(2, 2), // Desplazamiento de la sombra
                        blurRadius: 3.0, // Difuminado
                        color: Colors.black54, // Sombra negra con opacidad
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
                            backgroundImage: NetworkImage(_currentUser!.logo),
                            radius: 20,
                            backgroundColor: const Color.fromARGB(
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
                    color: Color.fromARGB(255, 255, 211, 0), // Ícono amarillo
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, MyRoutes.Login.name);
                  },
                ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter:
                  BackgroundPainter(), // La clase personalizada para el fondo
            ),
          ),
          SingleChildScrollView(
            controller:
                _scrollController, // Controlador del scroll, NO ESTOY SEGURO DE PORQUE DEBE IR AQUI Y NO EN EL GRIDVIEW BUILDER PERO VA ACA (NO TOCAR)
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40.0),
                    bottomRight: Radius.circular(40.0),
                  ),
                  child: Container(
                    color: const Color.fromARGB(
                        255, 33, 46, 127), // Color del "AppBar"
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    height: 150.0, // Tamaño total del "AppBar"
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        // Barra de búsqueda
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(0, 22, 11, 11),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: const Color.fromARGB(255, 255, 211, 0),
                              width: 2.0, // Detalle en amarillo
                            ),
                          ),
                          child: TextField(
                            controller: controller,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 255, 211, 0),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Buscar producto...',
                              hintStyle: const TextStyle(
                                color: Color.fromARGB(
                                    255, 255, 211, 0), // Letra amarilla
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Color.fromARGB(255, 255, 211, 0),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 20),
                            ),
                            onChanged: (value) {
                              _searchProducts(value);
                            },
                          ),
                        ),
                        const SizedBox(height: 15),
                        Container(
                          height: 80,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
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

                              // Verificar si la categoría actual está seleccionada
                              bool isSelected = _selectedCategoryIndex == index;

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedCategoryIndex =
                                          index; // Actualiza la categoría seleccionada
                                      _selectedCategory = category;
                                    });
                                    _filterByCategory(
                                        category); // Filtrar productos
                                  },
                                  child: Column(
                                    children: [
                                      AnimatedContainer(
                                        duration: Duration(milliseconds: 300),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Color.fromARGB(255, 255, 211, 0)
                                              : Colors
                                                  .transparent, // Fondo amarillo para categoría seleccionada
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          icon,
                                          color: isSelected
                                              ? Color.fromARGB(255, 33, 46, 127)
                                              : Color.fromARGB(
                                                  255, 255, 211, 0),
                                        ),
                                        padding: EdgeInsets.all(8),
                                      ),
                                      AnimatedDefaultTextStyle(
                                        duration: Duration(milliseconds: 300),
                                        style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 255, 211, 0),
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                        child: Text(category),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _buildEmptyState(),
                _buildProductGrid(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    // Verificar si hay productos
    return _products.isEmpty
        ? Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height - 240.0,
            color: Colors.transparent,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No se encontraron productos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          )
        : Container();
  }

  Widget _buildProductGrid() {
    // Mostrar productos
    return Container(
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height - 240.0,
      ),
      child: GridView.builder(
        // Controlador de scroll
        shrinkWrap: true,
        physics:
            const ClampingScrollPhysics(), // Permitir scroll dentro del GridView
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Número de columnas
          crossAxisSpacing: 8, // Espacio horizontal entre tarjetas
          mainAxisSpacing: 8, // Espacio vertical entre tarjetas
          childAspectRatio: 2 / 3, // Relación de aspecto de las tarjetas
        ),
        itemCount: _selectedCategory == null || _selectedCategory == 'Todos'
            ? _products.length
            : _filteredProducts.length,
        itemBuilder: (context, index) {
          final product =
              _selectedCategory == null || _selectedCategory == 'Todos'
                  ? _products[index]
                  : _filteredProducts[index];

          return FadeInUp(
            duration: Duration(milliseconds: 250 + index * 200),
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
      ),
    );
  }
}
