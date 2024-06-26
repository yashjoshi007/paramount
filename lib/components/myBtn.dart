import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RectangularButton extends StatelessWidget {
  final String text;
  final Color color;
  final Color btnText;
  final VoidCallback onPressed;

  const RectangularButton({
    Key? key,
    required this.text,
    required this.color,
    required this.onPressed,
    required this.btnText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15), // Increased padding
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5), // Increased border radius
        ),
        elevation: 0.0, // Increased elevation
        // shadowColor: Colors.black.withOpacity(0.7), // Increased shadow opacity
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(color: btnText,fontSize: 12),
      ),
    );
  }
}

class MyButton extends StatelessWidget {


  final String text;
  final VoidCallback onPressed;


  const MyButton({super.key,required this.text, required this.onPressed}) ;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Material(
          elevation: 0,
          borderRadius: BorderRadius.circular(26),
          color: Colors.red,
          child: MaterialButton(
            padding: EdgeInsets.fromLTRB(28, 14, 28, 14),
            minWidth: MediaQuery.of(context).size.width,
            onPressed: onPressed ,
            child: Text(text,style:GoogleFonts.poppins()
                .copyWith(fontWeight: FontWeight.w500, color: Colors.white)),
          ),
        )
    );
  }
}

class RectangularICBtn extends StatelessWidget {
  final String text;
  final String iconAssetPath; // Add this line for the icon image
  final Color color;
  final Color btnText;
  final VoidCallback onPressed;

  const RectangularICBtn({
    Key? key,
    required this.text,
    required this.iconAssetPath, // Add this line for the icon image
    required this.color,
    required this.onPressed,
    required this.btnText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        elevation: 0,
        // shadowColor: Colors.black.withOpacity(0.7),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            iconAssetPath,
            height: 24,
            width: 24,
            color: btnText,
          ),
          SizedBox(width: 10),
          Text(
            text,
            style: GoogleFonts.poppins(color: btnText),
          ),
        ],
      ),
    );
  }
}

class RectangularIBtn extends StatelessWidget {
  final String text;
  final String iconAssetPath;
  final Color color;
  final Color btnText;
  final VoidCallback onPressed;
  final BoxConstraints constraints; // Accepting constraints

  const RectangularIBtn({
    Key? key,
    required this.text,
    required this.iconAssetPath,
    required this.color,
    required this.onPressed,
    required this.btnText,
    required this.constraints, // Add this line
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: constraints.maxWidth * 0.05,
          vertical: constraints.maxWidth * 0.03,
        ),
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            iconAssetPath,
            height: constraints.maxWidth * 0.06,
            width: constraints.maxWidth * 0.06,
            color: btnText,
          ),
          SizedBox(width: constraints.maxWidth * 0.03),
          Text(
            text,
            style: GoogleFonts.poppins(color: btnText), // Removed GoogleFonts.poppins
          ),
        ],
      ),
    );
  }
}

