import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  List<Map<String, dynamic>> anunciosList = [];
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
  bool _loadPerfil = false;

  @override
  void initState() {
    super.initState();
    _checkUser();
    _scrollController.addListener(
        _scrollListener); // al cargar la app se carga el scrollListener
    _loadProducts(isInitialLoad: true); //y se arga la primera petición
    _loadAdds();
  }

  Future<void> _checkUser() async {
    try {
      List<Usuario> usuarios = await DBHelper.queryUsuarios();
      if (usuarios.isNotEmpty) {
        // Buscamos al usuario en Firestore
        final QuerySnapshot userQuery = await FirebaseFirestore.instance
            .collection('sellers')
            .where('email', isEqualTo: usuarios.first.email)
            .limit(1)
            .get();
        final userData = userQuery.docs.first.data() as Map<String, dynamic>;
        if (userData['eneable'] == 1) {
          _currentUser = null;
          try {
            List<Usuario> usuarios = await DBHelper.queryUsuarios();
            if (usuarios.isNotEmpty) {
              Usuario userToDelete = usuarios.first;
              await DBHelper.deleteUsuario(userToDelete);
              Navigator.pushNamedAndRemoveUntil(
                context,
                MyRoutes.PantallaPrincipal.name,
                (Route<dynamic> route) => false,
              );
            } else {
              print("No hay usuarios disponibles para eliminar.");
            }
            _loadPerfil = true;
          } catch (e) {
            print("Error al eliminar el usuario: $e");
            _loadPerfil = true;
          }
          Get.snackbar(
            'Error',
            'Cuenta deshabilitada',
            backgroundColor: Colors.red, // Cambia el color de fondo
            colorText: Colors.white, // Cambia el color del texto
          );

          return;
        } else {
          setState(() {
            _currentUser = usuarios.first;
            _loadPerfil = true;
          });
        }
      } else {
        setState(() {
          _currentUser = null;
          _loadPerfil = true;
        });
      }
    } catch (e) {
      print(e);
    }
    _loadPerfil = true;
  }

  Future<void> _loadAdds() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference addsCollection = firestore.collection('anuncios');

      QuerySnapshot snapshot = await addsCollection.get();

      // Limpiar la lista antes de cargar nuevos anuncios
      anunciosList.clear();

      // Recopilar los datos en una lista
      List<Map<String, dynamic>> tempList = [];

      // Recorrer los documentos obtenidos y agregarlos a la lista
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;

        // Verificar que los campos existan en el documento
        String descripcion = data['descripcion'] ?? '';
        String image = data['image'] ?? '';
        String titulo = data['titulo'] ?? '';

        // Agregar a la lista temporal
        tempList.add({
          'descripcion': descripcion,
          'image': image,
          'titulo': titulo,
        });
      }

      // Actualizar la lista y notificar a los widgets que se reconstruyan
      setState(() {
        anunciosList.addAll(tempList);
      });
    } catch (e) {
      if (e is FirebaseException) {
        // Manejo de errores de Firestore
        Get.snackbar(
          'Error de Firestore',
          e.message ?? 'Error desconocido',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } else {
        // Manejo de errores genéricos
        Get.snackbar(
          'Error',
          e.toString(),
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  Future<void> _loadProducts({bool isInitialLoad = false}) async {
    //funcion para cargar los productos
    try {
      if (!_hasMoreProducts && !isInitialLoad)
        return; // Si ya no hay más productos, no cargara más

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference productsCollection =
          firestore.collection('products').doc('vs').collection('vs');
      // Referencia a la colección de productos

      Query query = productsCollection
          .orderBy('fecha', descending: true)
          .limit(_pageSize); // Limitar a _pageSize productos

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

          _allProducts = List.from(
              _products); // Actualizar la lista de todos los productos
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
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al cargar los productos',
        backgroundColor: Colors.red, // Cambia el color de fondo
        colorText: Colors.white, // Cambia el color del texto
      );
      print("Error al cargar los productos: $e");
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
  void _searchProducts(String query) async {
    try {
      if (query.isEmpty) {
        Get.snackbar('Error', 'Por favor, introduce una consulta',
            backgroundColor: Colors.red, colorText: Colors.white);
      } else {
        final searchLower = query.toLowerCase().split(' ');
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        CollectionReference productsCollection =
            firestore.collection('products').doc('vs').collection('vs');

        Query querySnapshot = productsCollection
            .where('keywords', arrayContainsAny: searchLower)
            .orderBy('name');

        QuerySnapshot snapshot = await querySnapshot.get();
        setState(() {
          _products = [];
        });
        if (snapshot.docs.isNotEmpty) {
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
                'fecha': doc['fecha'],
                'keywords': doc['keywords'],
              };
            }).toList();
          });
        } else {
          setState(() {
            _products = [];
          });
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red, // Cambia el color de fondo
        colorText: Colors.white, // Cambia el color del texto
      );
      print(e);
    }
  }

  void _filterByCategory(String? category) async {
    setState(() {
      _selectedCategory = category;
      _filteredProducts = [];
      _hasMoreProducts = true; // Reiniciar la variable de más productos
      _lastDocument = null; // Reiniciar el último documento cargado
    });

    if (category == 'Todos' || category == null) {
      _products = []; // Limpiar la lista de productos|
      _loadProducts(isInitialLoad: true);
    } else {
      await _loadProductsByCategory(category);
    }
  }

  Future<void> _loadProductsByCategory(String category) async {
    if (!_hasMoreProducts && _filteredProducts.isNotEmpty) return;

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference productsCollection =
        firestore.collection('products').doc('vs').collection('vs');

    Query query = productsCollection
        .where('category', isEqualTo: category)
        .orderBy('fecha', descending: true)
        .limit(_pageSize);

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
          _loadPerfil == true
              ? _currentUser != null
                  ? Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                                    context, MyRoutes.PerfilPersonal.name)
                                .then((_) {
                              _checkUser();
                              _filterByCategory(_selectedCategory);
                            });
                          },
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundImage:
                                    NetworkImage(_currentUser!.logo),
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
                        color:
                            Color.fromARGB(255, 255, 211, 0), // Ícono amarillo
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, MyRoutes.Login.name);
                      },
                    )
              : Container(
                  width: 50, // adjust the size as needed
                  height: 50, // adjust the size as needed
                  child: CircularProgressIndicator(
                    strokeWidth: 5, // adjust the thickness of the circle
                    valueColor: AlwaysStoppedAnimation(
                        Colors.white), // adjust the color
                  ),
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
          CustomScrollView(
            controller:
                _scrollController, // Controlador del scroll, NO ESTOY SEGURO DE PORQUE DEBE IR AQUI Y NO EN EL GRIDVIEW BUILDER PERO VA ACA (NO TOCAR)
            slivers: [
              SliverAppBar(
                backgroundColor: const Color.fromARGB(0, 33, 46, 127),
                elevation: 0.0,
                expandedHeight: 145.0, // Tamaño total del "SliverAppBar"
                pinned: false, // Mantener el AppBar fijo
                floating: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40.0),
                      bottomRight: Radius.circular(40.0),
                    ),
                    child: Container(
                      color: const Color.fromARGB(
                          255, 33, 46, 127), // Color del "AppBar"
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
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
                              onSubmitted: (value) {
                                _searchProducts(value);
                              },
                            ),
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
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
                                bool isSelected =
                                    _selectedCategoryIndex == index;

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
                                          duration:
                                              const Duration(milliseconds: 300),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? const Color.fromARGB(
                                                    255, 255, 211, 0)
                                                : Colors
                                                    .transparent, // Fondo amarillo para categoría seleccionada
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            icon,
                                            color: isSelected
                                                ? const Color.fromARGB(
                                                    255, 33, 46, 127)
                                                : const Color.fromARGB(
                                                    255, 255, 211, 0),
                                          ),
                                          padding: const EdgeInsets.all(8),
                                        ),
                                        AnimatedDefaultTextStyle(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          style: TextStyle(
                                            color: const Color.fromARGB(
                                                255, 255, 211, 0),
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
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    buildAdds(),
                    _buildEmptyState(),
                    _buildProductGrid(),
                  ],
                ),
              ),
            ],
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

  Widget buildAdds() {
    // Si la lista de anuncios está vacía, devolver un Container vacío
    if (anunciosList.isEmpty) {
      return Container(); // O puedes devolver un Widget que indique que no hay anuncios
    }

    return GridView.builder(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(), // Evita el scroll dentro del GridView
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Número de columnas
        crossAxisSpacing: 10, // Espacio entre las columnas
        mainAxisSpacing: 10, // Espacio entre las filas
        childAspectRatio: 2 / 3, // Ajusta la relación de aspecto (más alto)
      ),
      itemCount: anunciosList.length,
      itemBuilder: (context, index) {
        var anuncio = anunciosList[index];
        return Card(
          margin: EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mostrar la imagen del anuncio expandida al máximo
              if (anuncio['image'] != null && anuncio['image'].isNotEmpty)
                Container(
                  height:
                      150, // Ajusta esta altura para hacer la imagen más larga
                  width: double.infinity, // Expandir a todo el ancho disponible
                  child: Image.network(
                    anuncio['image'],
                    fit: BoxFit.cover,
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título del anuncio
                    Text(
                      anuncio['titulo'] ?? 'Sin título',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 5),

                    // Descripción del anuncio, mostrando "..." si es muy larga
                    Text(
                      anuncio['descripcion']?.isNotEmpty == true
                          ? anuncio['descripcion']!
                          : '...',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
