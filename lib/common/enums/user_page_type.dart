import 'package:flutter/material.dart';

enum UserPageType {

  home(Icons.home_outlined, "Home"),
  taskManagement(Icons.task_alt_outlined, "Tasks"),
  quotationScreen(Icons.menu_book_outlined, "Quotation"),
  attendanceScreen(Icons.login, "Attendance"),
  profileScreen(Icons.account_circle_outlined, "Profile");

  final IconData icon;
  final String title;

  const UserPageType(this.icon, this.title);
}