import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final void Function(String)? onChanged;
  final TextInputType keyboardType;

  const MyTextField({
    Key? key,
    required this.hintText,
    required this.obscureText,
    required this.validator,
    required this.onSaved,
    this.onChanged,
    required this.keyboardType, required TextEditingController controller,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Define maximum and minimum text sizes
    final maxTextSize = screenWidth * 0.04;

    return Container(
      child: TextFormField(
        autofocus: false,
        keyboardType: keyboardType ,
        validator: validator,
        onSaved: onSaved,
        onChanged: onChanged,
        obscureText: obscureText,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
            color: Colors.grey, // Customize hint text color
            fontStyle: FontStyle.normal,
            fontSize: maxTextSize, // Customize hint text size
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
