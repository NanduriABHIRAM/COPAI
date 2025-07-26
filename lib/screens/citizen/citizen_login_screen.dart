import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../utils/app_snackbar.dart';
import '../../utils/app_alert_dialog.dart';
import 'citizen_dashboard_screen.dart';

class CitizenLoginScreen extends StatefulWidget {
  const CitizenLoginScreen({super.key});

  @override
  State<CitizenLoginScreen> createState() => _CitizenLoginScreenState();
}

class _CitizenLoginScreenState extends State<CitizenLoginScreen> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isOtpSent = false;
  bool _isVerifying = false;

  void _sendOtp() async {
    if (_mobileController.text.length != 10) {
      showAppSnackBar(context, 'Enter a valid 10-digit mobile number!',
          backgroundColor: Colors.red);
      return;
    }

    // TODO: BACKEND: Send OTP to <YOUR_BACKEND_URL>/citizen/send_otp
    /*
    final response = await http.post(
      Uri.parse('<YOUR_BACKEND_URL>/citizen/send_otp'),
      body: { "mobile": _mobileController.text },
    );
    if(response.statusCode == 200) { setState(() => _isOtpSent = true); }
    */

    setState(() => _isOtpSent = true);
    showAppSnackBar(context, 'OTP Sent Successfully!',
        backgroundColor: Colors.green);
  }

  void _verifyOtp() async {
    if (_otpController.text.length != 6) {
      showAppSnackBar(context, 'Enter a valid 6-digit OTP!',
          backgroundColor: Colors.red);
      return;
    }

    setState(() => _isVerifying = true);

    // TODO: BACKEND: Verify OTP at <YOUR_BACKEND_URL>/citizen/verify_otp
    /*
    final response = await http.post(
      Uri.parse('<YOUR_BACKEND_URL>/citizen/verify_otp'),
      body: { "mobile": _mobileController.text, "otp": _otpController.text },
    );
    if(response.statusCode == 200) { // Navigate to Dashboard }
    */

    await Future<void>.delayed(const Duration(seconds: 2));
    setState(() => _isVerifying = false);

    if (_otpController.text == "123456") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const CitizenDashboardScreen(),
        ),
      );
    } else {
      showAppAlertDialog(
        context,
        'Verification Failed',
        'Incorrect OTP. Please try again.',
        titleColor: Colors.red.shade700,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.navyBlue, AppColors.darkBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person, size: 80, color: AppColors.lightBlue),
                    const SizedBox(height: 20),
                    const Text(
                      'Citizen Login',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navyBlue,
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: _mobileController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Mobile Number',
                        prefixIcon:
                            Icon(Icons.phone, color: Colors.grey.shade600),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_isOtpSent)
                      TextField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Enter OTP',
                          prefixIcon:
                              Icon(Icons.lock, color: Colors.grey.shade600),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    const SizedBox(height: 30),
                    _isOtpSent
                        ? ElevatedButton(
                            onPressed: _isVerifying ? null : _verifyOtp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.navyBlue,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: _isVerifying
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text(
                                    'Verify OTP',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                          )
                        : ElevatedButton(
                            onPressed: _sendOtp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.mediumBlue,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'Send OTP',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 18),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
