import 'package:chatdb/Account/signin.dart';
import 'package:chatdb/Chat/controller.dart';
import 'package:chatdb/Elements/checkinternet.dart';
import 'package:chatdb/Elements/firebaseservice.dart';
import 'package:chatdb/Home/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../Account/register.dart';

// ignore: must_be_immutable
class FullScreenAvatarPage extends StatefulWidget {
  const FullScreenAvatarPage({super.key});

  @override
  FullScreenAvatarPageState createState() => FullScreenAvatarPageState();
}

class FullScreenAvatarPageState extends State<FullScreenAvatarPage> {
  bool isLoading = false;
  User? user = FirebaseAuth.instance.currentUser;

  final Controller c = Get.put(Controller());

  final CheckInternet p = Get.put(CheckInternet());

  @override
  Widget build(BuildContext context) {
    // Responsive data
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    // ignore: unused_local_variable
    double availableWidth = mediaQueryData.size.width;
    // ignore: unused_local_variable
    double availableHeight = mediaQueryData.size.height;

    p.checkUserConnection();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff405C5A),
        foregroundColor: Colors.white,
      ),
      body: !isLoading
          ? Container(
              alignment: Alignment.center,
              color: const Color(0xff405C5A),
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: (!c.signedIn.value && user?.email == null)
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                          const Spacer(
                            flex: 1,
                          ),
                          Expanded(
                            flex: 6,
                            child: Hero(
                              tag: 'avatarTag',
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withOpacity(0.1), // Shadow color
                                      spreadRadius:
                                          5, // How far the shadow extends from the object
                                      blurRadius:
                                          4, // The radius of the shadow blur
                                      offset: const Offset(0,
                                          4), // The offset of the shadow from the object
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  backgroundColor: const Color(0xffD9D9D9),
                                  radius: 80,
                                  child: user?.photoURL == null
                                      ? const Icon(
                                          Icons.person,
                                          color: Color(0xff405C5A),
                                          size: 60,
                                        )
                                      : CircleAvatar(
                                          backgroundImage:
                                              NetworkImage(user!.photoURL!),
                                          radius: 80,
                                        ),
                                ),
                              ),
                            ),
                          ),
                          const Spacer(
                            flex: 1,
                          ),
                          Expanded(
                            flex: 2,

                            // ignore: sized_box_for_whitespace
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withOpacity(0.08), // Shadow color
                                    spreadRadius:
                                        5, // How far the shadow extends from the object
                                    blurRadius:
                                        4, // The radius of the shadow blur
                                    offset: const Offset(0,
                                        4), // The offset of the shadow from the object
                                  ),
                                ],
                              ),
                              width: availableWidth,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 64.0),
                                  backgroundColor: const Color(0xffD9D9D9),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                ),
                                onPressed: () {
                                  Get.to(() => SignInPage());
                                },
                                child: const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: 'Ubuntu',
                                    color: Color(0xff034B40),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Spacer(
                            flex: 1,
                          ),
                          Expanded(
                              flex: 2,
                              // ignore: sized_box_for_whitespace
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withOpacity(0.08), // Shadow color
                                      spreadRadius:
                                          5, // How far the shadow extends from the object
                                      blurRadius:
                                          4, // The radius of the shadow blur
                                      offset: const Offset(0,
                                          4), // The offset of the shadow from the object
                                    ),
                                  ],
                                ),
                                width: availableWidth,
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 64.0),
                                        backgroundColor: const Color.fromARGB(
                                            255, 226, 226, 226),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16.0))),
                                    onPressed: () {
                                      Get.to(() => RegisterPage());
                                    },
                                    child: const Text(
                                      'Register',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontFamily: 'Ubuntu',
                                        color: Color(0xff034B40),
                                      ),
                                    )),
                              )),
                          const Spacer(
                            flex: 1,
                          ),
                          Expanded(
                            flex: 2,
                            // ignore: sized_box_for_whitespace
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withOpacity(0.08), // Shadow color
                                    spreadRadius:
                                        5, // How far the shadow extends from the object
                                    blurRadius:
                                        4, // The radius of the shadow blur
                                    offset: const Offset(0,
                                        4), // The offset of the shadow from the object
                                  ),
                                ],
                              ),
                              width: availableWidth,
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                          255, 226, 226, 226),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16.0))),
                                  onPressed: () async {
                                    void showMessage(String message) {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text("Error"),
                                              content: Text(message),
                                              actions: [
                                                TextButton(
                                                  child: const Text("Ok"),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                )
                                              ],
                                            );
                                          });
                                    }

                                    setState(() {
                                      isLoading = true;
                                    });

                                    final FirebaseService service =
                                        FirebaseService();
                                    try {
                                      final user =
                                          await service.signInWithGoogle();

                                      if (user != null) {
                                        // Successfully signed in
                                        c.signedIn.value = true;
                                        Get.offAll(() => const HomePage());
                                      } else {
                                        // User cancelled sign-in
                                        setState(() {
                                          isLoading = false;
                                        });
                                      }
                                    } on GoogleSignInException catch (e) {
                                      // Handle Google Sign-In specific errors
                                      if (e.code !=
                                          GoogleSignInExceptionCode.canceled) {
                                        showMessage(
                                            e.description ?? 'Sign-in failed');
                                      }
                                      setState(() {
                                        isLoading = false;
                                      });
                                    } on FirebaseAuthException catch (e) {
                                      showMessage(
                                          e.message ?? 'Authentication failed');
                                      setState(() {
                                        isLoading = false;
                                      });
                                    } catch (e) {
                                      showMessage(
                                          'An unexpected error occurred');
                                      setState(() {
                                        isLoading = false;
                                      });
                                    }
                                  },
                                  child: const SizedBox(
                                    width: 180,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Icon(
                                            FontAwesomeIcons.google,
                                            color: Color(0xff034B40),
                                            size: 20,
                                          ),
                                        ),
                                        Spacer(
                                          flex: 7,
                                        ),
                                        Expanded(
                                          flex: 50,
                                          child: Text(
                                            'Sign In With Google',
                                            maxLines: 1,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontFamily: 'Ubuntu',
                                              color: Color(0xff034B40),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                            ),
                          ),
                          const Spacer(
                            flex: 2,
                          ),
                        ])
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Spacer(
                          flex: 1,
                        ),
                        Expanded(
                          flex: 6,
                          child: Hero(
                            tag: 'avatarTag',
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withOpacity(0.1), // Shadow color
                                    spreadRadius:
                                        5, // How far the shadow extends from the object
                                    blurRadius:
                                        4, // The radius of the shadow blur
                                    offset: const Offset(0,
                                        4), // The offset of the shadow from the object
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                backgroundColor: const Color(0xffD9D9D9),
                                radius: 80,
                                child: user?.photoURL == null
                                    ? const Icon(
                                        Icons.person,
                                        color: Color(0xff405C5A),
                                        size: 60,
                                      )
                                    : CircleAvatar(
                                        backgroundImage:
                                            NetworkImage(user!.photoURL!),
                                        radius: 80,
                                      ),
                              ),
                            ),
                          ),
                        ),
                        const Spacer(
                          flex: 1,
                        ),
                        Expanded(
                          flex: 1,
                          child: user?.email != null
                              ? Text(
                                  'Logged in as ${user!.email}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontFamily: 'Ubuntu',
                                      color: Color(0xffFFCFA3)),
                                )
                              : const Text('Logged in as Guest'),
                        ),
                        const Spacer(
                          flex: 1,
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(0.08), // Shadow color
                                  spreadRadius:
                                      5, // How far the shadow extends from the object
                                  blurRadius:
                                      4, // The radius of the shadow blur
                                  offset: const Offset(0,
                                      4), // The offset of the shadow from the object
                                ),
                              ],
                            ),
                            width: availableWidth,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 64.0),
                                backgroundColor: const Color(0xffD9D9D9),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                              ),
                              onPressed: () async {
                                setState(() {
                                  isLoading = true;
                                });
                                FirebaseService service = FirebaseService();
                                try {
                                  await service.signOutFromGoogle();
                                  c.displayName.value = "";
                                  Get.offAll(() => const HomePage());
                                } catch (e) {
                                  if (e is FirebaseAuthException) {}
                                }
                                setState(() {
                                  c.signedIn.value = false;
                                  isLoading = false;
                                });
                              },
                              child: const Text(
                                'Sign Out',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Ubuntu',
                                  color: Color(0xff034B40),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Spacer(
                          flex: 1,
                        )
                      ],
                    ),
            )
          : Container(
              alignment: Alignment.center,
              color: const Color(0xff405C5A),
              child: const CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
    );
  }
}
