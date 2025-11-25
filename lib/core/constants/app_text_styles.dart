import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static TextStyle title = GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  static TextStyle subtitle = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  );

  static TextStyle body = GoogleFonts.poppins(
    fontSize: 16,
    color: Colors.black87,
  );

  static TextStyle label = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  );

  static TextStyle hint = GoogleFonts.poppins(color: Colors.grey, fontSize: 16);

  static TextStyle button = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle link = GoogleFonts.poppins(
    fontSize: 14,
    color: const Color(0xFF386BF6),
    fontWeight: FontWeight.w500,
  );

  static TextStyle linkBold = GoogleFonts.poppins(
    fontSize: 14,
    color: const Color(0xFF386BF6),
    fontWeight: FontWeight.w600,
  );

  static TextStyle caption = GoogleFonts.poppins(
    fontSize: 14,
    color: Colors.black54,
  );
}
