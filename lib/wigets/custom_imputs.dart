import 'package:flutter/material.dart';

class CustomInputs extends StatelessWidget {
  const CustomInputs(
      {super.key,
      required this.controller,
      required this.validator,
      required this.teclado,
      required this.hint,
      required this.nombrelabel,
      required this.icono,
      required this.show});

  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType teclado;
  final String? hint;
  final String nombrelabel;
  final IconData? icono;
  final bool show;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: show,
      controller: controller,
      validator: null,
      keyboardType: teclado,
      maxLines: 1,
      decoration: InputDecoration(
        label: Text(
          nombrelabel,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 2, 0, 97),
          ),
        ),
        hintText: hint,
        border: const UnderlineInputBorder(),
        suffixIcon: Icon(icono),
      ),
    );
  }
}

class PasswordInput extends StatefulWidget {
  const PasswordInput({
    super.key,
    required this.nombrelabel,
    required this.hint,
    required this.controller,
    required this.validator,
  });

  final String nombrelabel;
  final String hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  bool contra = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      obscureText: contra,
      keyboardType: TextInputType.text,
      maxLines: 1,
      decoration: InputDecoration(
        hintText: widget.hint,
        label: Text(
          widget.nombrelabel,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 2, 0, 97),
          ),
        ),
        border: const UnderlineInputBorder(),
        suffixIcon: IconButton(
            icon: Icon(contra ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() {
                contra = !contra;
              });
            }),
      ),
    );
  }
}
