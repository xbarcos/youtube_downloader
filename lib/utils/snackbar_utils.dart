import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum SnackbarType {
  primary,
  secondary,
  danger,
  warning,
  success
}

class TypeProps{
  Color textColor;
  Color backgroundColor;
  Color iconColor;

  TypeProps({
    required this.textColor,
    required this.backgroundColor,
    required this.iconColor
  });
}

class SnackbarUtils {

  static TypeProps _getTypeProps(SnackbarType type) {
    switch (type) {
      case SnackbarType.primary:
        return TypeProps(
          textColor: Colors.white,
          backgroundColor: Colors.pink,
          iconColor: Colors.white);
      case SnackbarType.secondary:
        return TypeProps(
          textColor: Colors.white,
          backgroundColor: Colors.blue,
          iconColor: Colors.white
        );        
      case SnackbarType.danger:
        return TypeProps(
          textColor: Colors.white,
          backgroundColor: Colors.redAccent,
          iconColor: Colors.white);
      case SnackbarType.warning:
        return TypeProps(
          textColor: Colors.black,
          backgroundColor: Colors.yellowAccent,
          iconColor: Colors.black);
      case SnackbarType.success:
        return TypeProps(
          textColor: Colors.black,
          backgroundColor: Colors.green,
          iconColor: Colors.black);
    }
  }

  static SnackbarController showSnackbar(
    String title, String msg, IconData icon, SnackbarType type ) {
      TypeProps props = _getTypeProps(type);
      return Get.snackbar(
        title,
        msg,
        icon: Icon(icon, color: props.iconColor),
        backgroundColor: props.backgroundColor,
        duration: const Duration(seconds: 5),
        colorText: props.textColor,
        snackPosition: SnackPosition.TOP
      );
  }
}