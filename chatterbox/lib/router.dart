import 'package:chatterbox/views/chat_screen.dart';
import 'package:chatterbox/views/home_screen.dart';
import 'package:chatterbox/views/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

final loggedOutRoute = RouteMap(
  routes: {'/': (route) => const MaterialPage(child: LoginScreen())},
);

final loggedInRoute = RouteMap(
  routes: {
    '/': (route) => const MaterialPage(child: HomeScreen()),
    '/c/:senderID/:receiverID': (route) {
      final senderID = route.pathParameters['senderID']!;
      final receiverID = route.pathParameters['receiverID']!;
      return MaterialPage(
        child: ChatScreen(senderID: senderID, receiverID: receiverID),
      );
    },
  },
);
