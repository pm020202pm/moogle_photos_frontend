import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OTPField extends StatelessWidget {
  const OTPField({super.key, required this.onOTPChange});
  final Function(String) onOTPChange;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: 190,
            child: PinCodeTextField(
              appContext: context,
              length: 4,
              keyboardType: TextInputType.number,
              animationType: AnimationType.fade,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderWidth: 1,
                selectedBorderWidth:2,
                inactiveBorderWidth: 1,
                borderRadius: BorderRadius.circular(10),
                fieldHeight: 50,
                fieldWidth: 40,
                activeFillColor: Colors.green.shade100,
                selectedFillColor: Colors.green.shade50,
                inactiveFillColor: Colors.green.shade100,
              ),
              enableActiveFill: true,
              onChanged: (value) {
                onOTPChange(value);
              },
            ),
          ),
        ),
      ],
    );
  }
}
