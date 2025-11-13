import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle appStyle(double size, Color color, FontWeight fw) =>
    GoogleFonts.poppins(
      fontSize: size,
      color: color,
      fontWeight: fw,
    ).copyWith(letterSpacing: -0.05);
