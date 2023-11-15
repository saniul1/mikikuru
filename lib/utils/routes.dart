import 'package:flutter/widgets.dart';
import 'package:mikikuru/views/details_view.dart';

PageRouteBuilder<dynamic> getDetailViewRoute(String id, ImageProvider image) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => BookDetailsView(
      image: image,
      coverId: id,
    ),
    transitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}
