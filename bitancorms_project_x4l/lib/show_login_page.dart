import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'show_social_media.dart';

class ShowLoginPage extends StatefulWidget {
  const ShowLoginPage({Key? key}) : super(key: key);

  @override
  State<ShowLoginPage> createState() => _ShowLoginPage();
}

class _ShowLoginPage extends State<ShowLoginPage> {
  final TextEditingController _username =
      TextEditingController(); //controller for getting username
  final TextEditingController _password =
      TextEditingController(); //controller for getting password
  final _formKey = GlobalKey<FormState>();

  DBHelper db = DBHelper();
  final bool _validate = false;

  // For hiding password
  bool _isObscure1 = true;

  // For getting request message from http
  List<String> success = [];
  List<String> credentials = [];

  String token = '';
  String username = '';
  String password = '';
  String firstName = '';
  String lastName = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(
          color: Colors.amber,
        ),
        backgroundColor: const Color.fromARGB(255, 66, 5, 22),
        title: const Text(
          'LOGIN TO FADEBOOK',
          style: TextStyle(color: Colors.amber),
        ),
      ),
      body: Form(
          key: _formKey,
          child: Container(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(
                    height: 4,
                  ),
                  buildTextField('Username', _username),
                  const SizedBox(
                    height: 4,
                  ),
                  buildPasswordField('Password', _password),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      buildLoginButton(),
                    ],
                  )
                ],
              ))),
      backgroundColor: const Color.fromARGB(170, 125, 25, 53),
    );
  }

  /*
    Description: buildTextField widget that creates a textfield

    Parameters: label with String type (function parameter) and _controller
    as a TextEditingController

    Returns a TextFormField that lets you input a String on a form field
  */
  Widget buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.amber),
      decoration: InputDecoration(
          labelStyle: const TextStyle(color: Colors.amber),
          errorStyle: const TextStyle(color: Colors.amber),
          filled: true,
          fillColor: const Color.fromARGB(255, 66, 5, 22),
          contentPadding: const EdgeInsets.all(10),
          border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(20)),
          focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(20)),
          labelText: label,
          errorText: _validate ? 'Value can\'t be empty' : null),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label is required!';
        }

        return null;
      },
    );
  }

  /*
    Description: buildTextField widget that creates a textfield for password

    Parameters: label with String type (function parameter) and _controller
    as a TextEditingController

    Returns a TextFormField that lets you input a String on a form field
  */
  Widget buildPasswordField(String label, TextEditingController controller) {
    return TextFormField(
      obscureText: _isObscure1, // For hiding text
      style: const TextStyle(color: Colors.amber),
      controller: controller,
      decoration: InputDecoration(
          labelStyle: const TextStyle(color: Colors.amber),
          errorStyle: const TextStyle(color: Colors.amber),
          filled: true,
          fillColor: const Color.fromARGB(255, 66, 5, 22),
          contentPadding: const EdgeInsets.all(10),
          border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(20)),
          focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(20)),
          labelText: label,
          errorText: _validate ? 'Value can\'t be empty' : null,
          suffixIcon: IconButton(
              icon: Icon(_isObscure1 ? Icons.visibility : Icons.visibility_off),
              color: Colors.amber,
              onPressed: () {
                setState(() {
                  _isObscure1 =
                      !_isObscure1; // Icon changes when pressed and hides/unhides input
                });
              })),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label is required!';
        }

        return null;
      },
    );
  }

  /*
    Description: a Login button that lets the user login to the social media site

    Parameters: none
    Returns an ElevatedButton that lets the User enter its credentials and login 
    to the web
  */

  Widget buildLoginButton() {
    return ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User Login is being processed...')),
          );

          // Call the loginUser function to do post request and get token if successful
          // Get the success message to get its code and token from the request
          success = await db.loginUser(_username.text, _password.text);

          // Get username and password to be used for getting the credentials
          final String tempUsername = _username.text;
          password = _password.text;

          // Clear controllers
          _username.clear();
          _password.clear();

          // Login is successful
          if (success[0] == "200") {
            await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                      title: const Text("Login Success!"),
                      titleTextStyle: const TextStyle(color: Colors.amber),
                      backgroundColor: const Color.fromARGB(255, 66, 5, 22),
                      actions: <Widget>[
                        TextButton(
                          child: const Text(
                            'OK',
                            style: TextStyle(color: Colors.amber),
                          ),
                          onPressed: () async {
                            // Pass token to the variable to be used by another page
                            final token = success[1];
                            credentials = await db.getUser(tempUsername, token);

                            if (credentials[0] == '200') {
                              username = credentials[1];
                              firstName = credentials[2];
                              lastName = credentials[3];
                              // Go to next page
                              // Await first before going back to homepage
                              Future.delayed(Duration.zero).then((_) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ShowSocialMedia(
                                            token,
                                            username,
                                            firstName,
                                            lastName,
                                            password)));
                              });
                            }
                          },
                        ),
                      ]);
                });

            // Login unsuccessful
          } else {
            await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                      title: Text("Error ${success[0]}"),
                      titleTextStyle: const TextStyle(color: Colors.amber),
                      content: Text(
                        success[1],
                        style: const TextStyle(color: Colors.amber),
                      ),
                      backgroundColor: const Color.fromARGB(255, 66, 5, 22),
                      actions: <Widget>[
                        TextButton(
                          child: const Text(
                            'OK',
                            style: TextStyle(color: Colors.amber),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ]);
                });
          }
        }
      },
      style: ElevatedButton.styleFrom(
        primary: const Color.fromARGB(255, 66, 5, 22),
        side: const BorderSide(color: Colors.red),
      ),
      child: const Text(
        'Login',
        style: TextStyle(color: Colors.amber),
      ),
    );
  }
}
