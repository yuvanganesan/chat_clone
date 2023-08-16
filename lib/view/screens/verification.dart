import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pinput/pinput.dart';
import './profile_info.dart';

class Verificatoin extends StatefulWidget {
  final String? phone;

  const Verificatoin({Key? key, this.phone}) : super(key: key);

  @override
  _VerificatoinState createState() => _VerificatoinState();
}

class _VerificatoinState extends State<Verificatoin> {
  bool _isResendAgain = false;

  bool _isLoading = false;
  String _verificationId = '';
  String _code = '';
  int? _resendToken;
  final _otp = TextEditingController();

  late Timer _resendTimer = Timer(const Duration(milliseconds: 1), () {});
  int _start = 60;
  int _currentIndex = 0;
  late Timer animationTimer;

  void getOTP() async {
    final auth = FirebaseAuth.instance;
    try {
      await auth.verifyPhoneNumber(
          phoneNumber: widget.phone,
          timeout: const Duration(seconds: 60),
          verificationCompleted: (PhoneAuthCredential credential) {
            //only execute when auto verification done
          },
          verificationFailed: (FirebaseAuthException e) {
            Navigator.of(context).pop();
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return WillPopScope(
                  onWillPop: _onWillPop,
                  child: AlertDialog(
                    title: const Text(
                      'Error occurred',
                    ),
                    content: Text(e.code,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    actions: [
                      ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: const Color(0xfff2c40f)),
                          child: const Text("Okay"))
                    ],
                  ),
                );
              },
            );
          },
          codeSent: (String verificationId, int? resendToken) {
            _verificationId = verificationId;
            _resendToken = resendToken;
            Navigator.of(context).pop();

            resend();
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            //execute if auto verification failed
          },
          forceResendingToken: _resendToken);

      //when this screen push, initstate will calls first, then in initstate getOtp() will call
      //and when reach verifyPhoneNumber() in getOTP() which return future, so the control back to
      //code after calling line of getOTP() in initState, after initState completed control will come
      //back to getOTP() to extecute code after verifyPhoneNumber() which is the below showDialog()
      //and at last this dialog will pop when otp generated and send to user, that is codeSend argument in
      //verifyPhoneNumber() executed

      // ignore: use_build_context_synchronously
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return WillPopScope(
                onWillPop: _onWillPop,
                child: const AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.zero)),
                  content: Row(
                    children: [
                      CircularProgressIndicator(
                        color: Color(0xfff2c40f),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Text('Requesting an SMS...')
                    ],
                  ),
                ));
          });
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  void resend() {
    setState(() {
      _isResendAgain = true;
    });

    const oneSec = Duration(seconds: 1);
    _resendTimer.cancel();
    _resendTimer = Timer.periodic(oneSec, (timer) {
      setState(() {
        if (_start == 0) {
          _start = 60;
          _isResendAgain = false;
          timer.cancel();
        } else {
          _start--;
        }
      });
    });
  }

  void verify() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
    });
    FirebaseAuth auth = FirebaseAuth.instance;

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: _verificationId, smsCode: _code);

      // Sign the user in (or link) with the credential

      await auth.signInWithCredential(credential);
      await auth.currentUser!.updateDisplayName('');

      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) {
          return ProfileInfo(
            phoneNo: widget.phone,
            isThisFirstScreen: false,
          );
        },
      ));
    } catch (error) {
      //print(error.toString());
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("OTP was wrong..!")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _onWillPop() async {
    return false; //<-- SEE HERE
  }

  @override
  void initState() {
    getOTP();

    animationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        _currentIndex++;

        if (_currentIndex == 3) _currentIndex = 0;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    animationTimer.cancel();
    //_timer.cancel();
    _resendTimer.cancel();
    _otp.dispose();
    _resendToken = null;

    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
          // resizeToAvoidBottomInset: false,
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                height: MediaQuery.of(context).size.height,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 250,
                      child: Stack(children: [
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: AnimatedOpacity(
                            opacity: _currentIndex == 0 ? 1 : 0,
                            duration: const Duration(
                              seconds: 1,
                            ),
                            curve: Curves.linear,
                            child: Image.asset('assets/images/img1.png'),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: AnimatedOpacity(
                            opacity: _currentIndex == 1 ? 1 : 0,
                            duration: const Duration(seconds: 1),
                            curve: Curves.linear,
                            child: Image.asset('assets/images/img2.png'),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: AnimatedOpacity(
                            opacity: _currentIndex == 2 ? 1 : 0,
                            duration: const Duration(seconds: 1),
                            curve: Curves.linear,
                            child: Image.asset('assets/images/img3.png'),
                          ),
                        )
                      ]),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    FadeInDown(
                        duration: const Duration(milliseconds: 500),
                        child: const Text(
                          "Verification",
                          style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff263b43)),
                        )),
                    const SizedBox(
                      height: 30,
                    ),
                    FadeInDown(
                      delay: const Duration(milliseconds: 500),
                      duration: const Duration(milliseconds: 500),
                      child: Column(
                        children: [
                          Text(
                            "Please enter the 6 digit code sent to",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade500,
                              // height: 1.5
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${widget.phone}",
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.black),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              InkWell(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    "Wrong number?",
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.blueAccent),
                                  ))
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    // Verification Code Input
                    FadeInDown(
                        delay: const Duration(milliseconds: 600),
                        duration: const Duration(milliseconds: 500),
                        child: Pinput(
                          length: 6,
                          controller: _otp,
                          onChanged: (value) {
                            _code = _otp.text;
                          },
                          keyboardType: TextInputType.number,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          defaultPinTheme: const PinTheme(
                              textStyle: TextStyle(
                                  fontSize: 30, color: Color(0xff263b43)),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Color(0xff263b43))))),
                        )),

                    const SizedBox(
                      height: 20,
                    ),
                    FadeInDown(
                      delay: const Duration(milliseconds: 700),
                      duration: const Duration(milliseconds: 500),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't resive the OTP?",
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey.shade500),
                          ),
                          TextButton(
                              onPressed: () {
                                if (_isResendAgain) return;
                                //resend();
                                getOTP();
                              },
                              child: Text(
                                _isResendAgain
                                    ? "Try again in $_start"
                                    : "Resend",
                                style:
                                    const TextStyle(color: Colors.blueAccent),
                              ))
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    FadeInDown(
                      delay: const Duration(milliseconds: 800),
                      duration: const Duration(milliseconds: 500),
                      child: MaterialButton(
                        elevation: 0,
                        onPressed: _code.length < 6
                            ? () => {}
                            : () {
                                verify();
                              },
                        color: const Color(0xfff2c40f),
                        minWidth: MediaQuery.of(context).size.width * 0.8,
                        height: 50,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  backgroundColor: Colors.white,
                                  strokeWidth: 3,
                                  color: Colors.black,
                                ),
                              )
                            : const Text(
                                "Verify",
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    )
                  ],
                )),
          )),
    );
  }
}
