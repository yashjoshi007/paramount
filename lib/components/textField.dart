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
          contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 15),
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

class DelayedEditableTextField extends StatefulWidget {
  final String value;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;

  const DelayedEditableTextField({
    Key? key,
    required this.value,
    this.onChanged,
    this.onEditingComplete,
  }) : super(key: key);

  @override
  _DelayedEditableTextFieldState createState() => _DelayedEditableTextFieldState();
}

class _DelayedEditableTextFieldState extends State<DelayedEditableTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant DelayedEditableTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      onEditingComplete: widget.onEditingComplete,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Quantity',
        labelStyle: GoogleFonts.poppins(fontSize: 6,fontWeight: FontWeight.normal),
        border: OutlineInputBorder(),
      ),
    );
  }
}
