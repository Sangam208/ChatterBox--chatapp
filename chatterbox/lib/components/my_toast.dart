import 'package:fluttertoast/fluttertoast.dart';

Future<bool?> myToast() async {
  return Fluttertoast.showToast(
    msg: 'Coming Soon',
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
  );
}
