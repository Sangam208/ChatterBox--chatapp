import 'package:chatterbox/colors.dart';
import 'package:chatterbox/repository/auth_repository.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:routemaster/routemaster.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  void signInWithGoogle(BuildContext context, WidgetRef ref) async {
    final errorModel =
        await ref.read(authRepositoryProvider).signInWithGoogle();
    String toastmsg =
        errorModel.error != null ? errorModel.error! : 'Logged in';
    if (errorModel.data != null) {
      ref.read(userProvider.notifier).update((state) => errorModel.data);
      if (context.mounted) {
        Routemaster.of(context).replace('/');
      }
      Fluttertoast.showToast(
        msg: toastmsg,
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: kBlackColor,
      );
    } else {
      Fluttertoast.showToast(
        msg: toastmsg,
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: kBlackColor,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: scaffoldColor,
      body: Center(
        child: Stack(
          children: [
            Positioned(
              top: screenWidth > 500 ? 0 : 65,
              left: 0,
              right: 0,
              child: Lottie.asset('assets/lottie/wave.json', height: 470),
            ),
            Positioned(
              top: screenWidth > 500 ? 0 : 65,
              left: 0,
              right: 0,
              child: Lottie.asset('assets/lottie/waves.json', height: 470),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 50),
                  height: 60,
                  width:
                      screenWidth > 600 ? screenWidth * 0.3 : screenWidth * 0.7,
                  decoration: BoxDecoration(
                    border: Border.all(color: kGreenColor, width: 1),
                    color: kTransparentColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => signInWithGoogle(context, ref),
                    splashColor: kGreenColor,
                    hoverColor: kGreenColor,
                    child: Row(
                      spacing: 8,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/google_logo.png',
                          height: 30,
                        ),
                        const Text(
                          'Sign in with Google',
                          style: TextStyle(
                            color: kWhiteColorLight,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
