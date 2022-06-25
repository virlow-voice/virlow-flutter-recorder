import './auth.dart';
import './signup.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  late String email, pwd;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_ios)),
        title: const Text('Sign In'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(left: 20.0, top: 80.0, right: 20.0),
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: const [
                  Text(
                    'Sign In',
                    style: TextStyle(fontSize: 22.0),
                  ),
                ],
              ),
              const SizedBox(
                height: 5.0,
              ),
              Row(
                children: const [
                  Flexible(child: Text("Enter your credentials to login")),
                ],
              ),
              const SizedBox(
                height: 25.0,
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                        decoration: const InputDecoration(
                          prefixIcon:
                              Icon(Icons.alternate_email, color: Colors.blue),
                          labelText: 'Email ID',
                          hintText: '',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue)),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        //obscureText: true,
                        validator: (val) =>
                            val!.isEmpty ? 'email is required' : null,
                        onChanged: (val) {
                          setState(() => email = val);
                        }),
                    const SizedBox(height: 20),
                    TextFormField(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.vpn_key, color: Colors.blue),
                          labelText: 'Password',
                          hintText: "",
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue)),
                        ),
                        keyboardType: TextInputType.text,
                        obscureText: true,
                        validator: (val) =>
                            val!.isEmpty ? 'password is required' : null,
                        onChanged: (val) {
                          setState(() => pwd = val);
                        }),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      child: Text('LOGIN'),
                      onPressed: () async {
                        await AuthServices().userSignIn(email, pwd, context);
                      },
                    ),
                  ],
                ),
              ),
              TextButton(
                child: const Text(
                  'Don\'t have an account?',
                  style: TextStyle(color: Colors.blue),
                ),
                onPressed: () async {
                  await Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const SignUp()));
                },
              ),
              // TextButton(child: Text('Forgot Password', style: TextStyle(color: Colors.blue),), onPressed: () async {},)
            ],
          ),
        ),
      ),
    );
  }
}
