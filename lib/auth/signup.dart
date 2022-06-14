import './auth.dart';
import './signin.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  late String givenName, familyName, email, pwd;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign up'),
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
                    'Sign Up',
                    style: TextStyle(fontSize: 22.0),
                  ),
                ],
              ),
              const SizedBox(
                height: 5.0,
              ),
              Row(
                children: const [
                  Flexible(child: Text("Let's create your account")),
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
                          prefixIcon: Icon(Icons.person, color: Colors.blue),
                          labelText: 'Given Name',
                          hintText: '',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                              borderSide: BorderSide(color: Colors.blue)),
                        ),
                        keyboardType: TextInputType.text,
                        //obscureText: true,
                        validator: (val) =>
                            val!.isEmpty ? 'given name is required' : null,
                        onChanged: (val) {
                          setState(() => givenName = val);
                        }),
                    const SizedBox(height: 20),
                    TextFormField(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.person, color: Colors.blue),
                          labelText: 'Family Name',
                          hintText: '',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                              borderSide: BorderSide(color: Colors.blue)),
                        ),
                        keyboardType: TextInputType.text,
                        //obscureText: true,
                        validator: (val) =>
                            val!.isEmpty ? 'family name is required' : null,
                        onChanged: (val) {
                          setState(() => familyName = val);
                        }),
                    const SizedBox(height: 20),
                    TextFormField(
                        decoration: const InputDecoration(
                          prefixIcon:
                              Icon(Icons.alternate_email, color: Colors.blue),
                          labelText: 'Email ID',
                          hintText: '',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
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
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                              borderSide: BorderSide(color: Colors.blue)),
                        ),
                        keyboardType: TextInputType.text,
                        obscureText: true,
                        validator: (val) =>
                            val!.isEmpty ? 'password is required' : null,
                        onChanged: (val) {
                          setState(() => pwd = val);
                        }),
                    const SizedBox(height: 20),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      child: const Text('REGISTER'),
                      onPressed: () async {
                        await AuthServices().userSignUp(
                            givenName, familyName, pwd, email, context);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                child: const Text(
                  'Have an account?',
                  style: TextStyle(color: Colors.blue),
                ),
                onPressed: () async {
                  await Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const SignIn()));
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
