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
  int _selectedCategoryIndex = 0;
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
          final sellerNameLower = product['sellerName'].toLowerCase();

          return nameLower.contains(searchLower) ||
              categoryLower.contains(searchLower) ||
              sellerNameLower.contains(searchLower) ||
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
                  BackgroundPainter(), // Tu clase personalizada para el fondo
            ),
          ),
          SingleChildScrollView(
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
                            style: const TextStyle(
    color: Color.fromARGB(255, 255, 211, 0), // Texto amarillo
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
                const SizedBox(
                    height: 10), // Espacio para el contenido del GridView
                _products.isEmpty
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
                    : Container(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height - 240.0,
                        ),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics:
                              const ClampingScrollPhysics(), // Permitir scroll dentro del GridView
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // Número de columnas
                            crossAxisSpacing:
                                8, // Espacio horizontal entre tarjetas
                            mainAxisSpacing:
                                8, // Espacio vertical entre tarjetas
                            childAspectRatio:
                                2 / 3, // Relación de aspecto de las tarjetas
                          ),
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            final product = _products[index];

                            return FadeInUp(
                              duration:
                                  Duration(milliseconds: 250 + index * 200),
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
                      ),
              ],
            ),
          ),
        ],
      ),
    );
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
