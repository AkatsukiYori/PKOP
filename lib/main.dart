import 'package:flutter/material.dart';
import 'package:project_rpl/screen/auth/login.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginWidget(),
      theme: ThemeData(textTheme: GoogleFonts.poppinsTextTheme()),
    ),
  );
}
