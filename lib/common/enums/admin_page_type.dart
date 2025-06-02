import 'package:flutter/material.dart';

enum AdminPageType {

  userManagement(Icons.people_alt_outlined, "Users"),
  taskManagement(Icons.task_alt_outlined, "Tasks"),
  locationTracker(Icons.map_outlined, "Tracker"),
  quotation(Icons.menu_book_outlined, "Quotation"),
  attendanceScreen(Icons.login, "Attendance"),
  activeUsers(Icons.supervised_user_circle_outlined, "Active Users"),
  profileScreen(Icons.account_circle_outlined, "Profile");

  final IconData icon;
  final String title;

  const AdminPageType(this.icon, this.title);
}