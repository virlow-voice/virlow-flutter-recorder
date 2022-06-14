import './auth.dart';
import 'package:flutter/material.dart';

class OTPConf extends StatefulWidget {
  const OTPConf({Key? key, required this.email}) : super(key: key);

  final String email;

  @override
  _OTPConfState createState() => _OTPConfState();
}

class _OTPConfState extends State<OTPConf> {
  final _formKey = GlobalKey<FormState>();
  late String verCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Confirm Account')
      // ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40.0),
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Text(
                    'Verification',
                    style: TextStyle(fontSize: 22.0),
                  ),
                ],
              ),
              SizedBox(
                height: 5.0,
              ),
              Row(
                children: [
                  Flexible(
                      child:
                          Text("Enter verification code sent to your email")),
                ],
              ),
              SizedBox(
                height: 25.0,
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.vpn_key, color: Colors.blue),
                          labelText: 'verification code',
                          hintText: '',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                              borderSide: BorderSide(color: Colors.grey)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                              borderSide: BorderSide(color: Colors.blue)),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        obscureText: true,
                        validator: (val) =>
                            val!.isEmpty ? 'code cannot be empty' : null,
                        onChanged: (val) {
                          setState(() => verCode = val);
                        }),
                    SizedBox(height: 40),
                    ElevatedButton(
                      child: Text('LOGIN'),
                      onPressed: () async {
                        await AuthServices()
                            .confUser(widget.email, verCode, context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
