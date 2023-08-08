import 'package:animate_do/animate_do.dart';
import './verification.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterWithPhoneNumber extends StatefulWidget {
  const RegisterWithPhoneNumber({Key? key}) : super(key: key);

  @override
  _RegisterWithPhoneNumberState createState() =>
      _RegisterWithPhoneNumberState();
}

class _RegisterWithPhoneNumberState extends State<RegisterWithPhoneNumber> {
  bool _isLoading = false;

  final formKey = GlobalKey<FormState>();
  String? userPhone = "";

  Future<void> _isSubmit() async {
    // final isValid = formKey.currentState!.validate();
    // FocusScope.of(context).unfocus();

    // if (!isValid) {
    //   return;
    // }

    // formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Verificatoin(
                      phone: userPhone,
                    )));
      });
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? "Authentication failed")));
    } finally {
      // setState(() {
      //   _isLoading = false;
      //   print('isLoading false');
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(30),
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Image.network(
                //   'https://ouch-cdn2.icons8.com/n9XQxiCMz0_zpnfg9oldMbtSsG7X6NwZi_kLccbLOKw/rs:fit:392:392/czM6Ly9pY29uczgu/b3VjaC1wcm9kLmFz/c2V0cy9zdmcvNDMv/MGE2N2YwYzMtMjQw/NC00MTFjLWE2MTct/ZDk5MTNiY2IzNGY0/LnN2Zw.png',
                //   fit: BoxFit.cover,
                //   width: 280,
                // ),
                // SizedBox(
                //   height: 50,
                // ),
                FadeInDown(
                  child: const Text(
                    'WELCOME',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Color(0xff263b43)),
                  ),
                ),
                FadeInDown(
                  delay: const Duration(milliseconds: 200),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 20),
                    child: Text(
                      'Enter your phone number to continue, we will send you OTP to verifiy.',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 14, color: Colors.grey.shade700),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                FadeInDown(
                  delay: const Duration(milliseconds: 400),
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: Colors.black.withOpacity(0.13)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xffeeeeee),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Form(
                        key: formKey,
                        child: Stack(
                          children: [
                            InternationalPhoneNumberInput(
                              key: const ValueKey("phone"),
                              onInputChanged: null,
                              selectorConfig: const SelectorConfig(
                                showFlags: true,
                                trailingSpace: true,
                                selectorType:
                                    PhoneInputSelectorType.BOTTOM_SHEET,
                              ),
                              ignoreBlank: false,
                              autoValidateMode: AutovalidateMode.disabled,
                              selectorTextStyle:
                                  const TextStyle(color: Colors.black),
                              formatInput: false,
                              maxLength: 10,
                              keyboardType: TextInputType.number,
                              cursorColor: Colors.black,
                              inputDecoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.only(bottom: 15, left: 0),
                                border: InputBorder.none,
                                hintText: 'Phone Number',
                                hintStyle: TextStyle(
                                    color: Colors.grey.shade500, fontSize: 16),
                              ),
                              validator: (value) {
                                String patttern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
                                RegExp regExp = RegExp(patttern);
                                if (value == null ||
                                    value.isEmpty ||
                                    value.length < 10 ||
                                    !regExp.hasMatch(value)) {
                                  return "Please enter valid mobile number.";
                                }
                                return null;
                              },
                              onSaved: (PhoneNumber number) {
                                userPhone = number.phoneNumber!.trim();
                              },
                            ),
                            Positioned(
                              left: 90,
                              top: 8,
                              bottom: 8,
                              child: Container(
                                height: 40,
                                width: 1,
                                color: Colors.black.withOpacity(0.13),
                              ),
                            )
                          ],
                        ),
                      )),
                ),
                const SizedBox(
                  height: 100,
                ),
                FadeInDown(
                  delay: const Duration(milliseconds: 600),
                  child: MaterialButton(
                    minWidth: double.infinity,
                    onPressed: () {
                      final isValid = formKey.currentState!.validate();
                      FocusScope.of(context).unfocus();

                      if (!isValid) {
                        return;
                      }

                      formKey.currentState!.save();
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor: Colors.white,
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xfff2c40f)),
                                  child: const Text("Edit")),
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _isSubmit();
                                  },
                                  style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xfff2c40f)),
                                  child: const Text("Okay"))
                            ],
                            actionsAlignment: MainAxisAlignment.spaceBetween,
                            content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'You entered the phone number:',
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    "$userPhone",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  const Text(
                                      'Is this OK, or would you like to edit the number?')
                                ]),
                          );
                        },
                      );
                    },
                    color: const Color(0xfff2c40f), //Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 30),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              backgroundColor: Colors.white,
                              color: Color(0xff263b43),
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Request OTP",
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
