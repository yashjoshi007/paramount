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
        elevation: 10, // Increased elevation
        shadowColor: Colors.black.withOpacity(0.7), // Increased shadow opacity
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(color: btnText),
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
        elevation: 10,
        shadowColor: Colors.black.withOpacity(0.7),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            iconAssetPath,
            height: 24, // Set the height as per your requirement
            width: 24, // Set the width as per your requirement
            color: btnText, // Apply color to the image
          ),
          SizedBox(width: 10), // Add some space between the icon and text
          Text(
            text,
            style: GoogleFonts.poppins(color: btnText),
          ),
        ],
      ),
    );
  }
}


