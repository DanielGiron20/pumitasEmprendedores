import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String name;
  final String description;
  final String image;
  final double price;
  final String sellerId;
  final String sellerName;
  final VoidCallback onTap;

  const ProductCard({
    required this.name,
    required this.description,
    required this.image,
    required this.price,
    required this.sellerId,
    required this.sellerName,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Tamaño de la pantalla disponible
    final size = MediaQuery.of(context).size;

    // Calculamos la altura como el 50% de la altura total de la pantalla (puedes ajustar)
    final cardHeight = size.height * 0.5;

    // El ancho será igual al largo + 36 píxeles (el espacio vertical adicional)
    final cardWidth = cardHeight + 36;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 10,
        child: SizedBox(
          width: cardWidth,
          height: cardHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio:
                    1, // Relación de aspecto 1:1 para la imagen cuadrada
                child: Container(
                  decoration: BoxDecoration(
                    /*boxShadow: [
                      // Sombra azul en la mitad superior
                      BoxShadow(
                        color: const Color.fromARGB(255, 33, 46, 127)
                            .withOpacity(
                                0.4), // Menor opacidad para reducir brillo
                        spreadRadius: 5,
                        blurRadius:
                            5, // Menor blur para un resplandor más suave
                        offset: const Offset(0, -5 / 3), // Sombra hacia arriba
                      ),
                      // Sombra amarilla en la mitad inferior
                      BoxShadow(
                        color: const Color.fromARGB(255, 255, 211, 0)
                            .withOpacity(
                                0.4), // Menor opacidad para reducir brillo
                        spreadRadius: 5,
                        blurRadius:
                            5, // Menor blur para un resplandor más suave
                        offset: const Offset(0, 5 / 3), // Sombra hacia abajo
                      ),
                    ],*/
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    child: Image.network(
                      image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    Text(
                      '\$$price',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
