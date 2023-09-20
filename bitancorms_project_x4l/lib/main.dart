import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'show_login_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'Social Media App';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: _title,
      home: MyStatefulWidget(title: 'WELCOME TO FADEBOOK'),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  final TextEditingController _username =
      TextEditingController(); //controller for getting username
  final TextEditingController _password =
      TextEditingController(); //controller for getting password
  final TextEditingController _confirmPassword =
      TextEditingController(); //controller for getting last name
  final TextEditingController _firstName =
      TextEditingController(); //controller for getting first name
  final TextEditingController _lastName =
      TextEditingController(); //controller for getting last name
  final _formKey = GlobalKey<FormState>();

  DBHelper db = DBHelper();

  // For validating form entries
  final bool _validate = false;

  // For hiding password
  bool _isObscure1 = true;
  bool _isObscure2 = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 66, 5, 22),
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.amber),
        ),
      ),

      // Form for user registration
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
                  buildTextField('Username', _username), // Username field
                  const SizedBox(
                    height: 4,
                  ),
                  buildTextField('First Name', _firstName), // First Name field
                  const SizedBox(
                    height: 4,
                  ),
                  buildTextField('Last Name', _lastName), // Last Name field
                  const SizedBox(
                    height: 4,
                  ),
                  buildPasswordField('Password', _password), // Password field
                  const SizedBox(
                    height: 4,
                  ),
                  buildConfirmPasswordField('Confirm Password',
                      _confirmPassword), // Confirm password field
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      buildSaveButton(), // Register button
                      buildLoginButton(), // Login button
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
    Description: buildTextField widget that creates a textfield for confirm password

    Parameters: label with String type (function parameter) and _controller
    as a TextEditingController

    Returns a TextFormField that lets you input a String on a form field
  */
  Widget buildConfirmPasswordField(
      String label, TextEditingController controller) {
    return TextFormField(
      obscureText: _isObscure2, // For hiding text
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
              icon: Icon(_isObscure2 ? Icons.visibility : Icons.visibility_off),
              color: Colors.amber,
              onPressed: () {
                setState(() {
                  _isObscure2 =
                      !_isObscure2; // Icon changes when pressed and hides/unhides input
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
    Description: a Register button that lets the user register to the web

    Parameters: none
    Returns an ElevatedButton that lets the User enter its credentials to register
    to the web
  */
  Widget buildSaveButton() {
    return ElevatedButton(
      onPressed: () async {
        // User inputs all required fields and password and confirm password match
        if (_formKey.currentState!.validate() &&
            (_confirmPassword.text == _password.text)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('User Registration is being processed...')),
          );

          // Call registerUser function to do post request
          // Get the success message to get its code from the request
          final String success = await db.registerUser(
              _username.text, _password.text, _firstName.text, _lastName.text);

          // Clear controllers
          _username.clear();
          _password.clear();
          _firstName.clear();
          _lastName.clear();
          _confirmPassword.clear();

          // Register successful
          if (success == "200") {
            await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                      title: const Text("Registration Success!"),
                      titleTextStyle: const TextStyle(color: Colors.amber),
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

          // Confirm password and password do not match
        } else if (_confirmPassword.text != _password.text) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Confirm password does not match the password!')),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        primary: const Color.fromARGB(255, 66, 5, 22),
        side: const BorderSide(color: Colors.red),
      ),
      child: const Text(
        'Register',
        style: TextStyle(color: Colors.amber),
      ),
    );
  }

  /*
    Description: a Login button that lets the user go to the login page

    Parameters: none
    Returns an ElevatedButton that lets the User go to the login page
  */

  Widget buildLoginButton() {
    return ElevatedButton(
      onPressed: () async {
        // Clear controllers
        _username.clear();
        _password.clear();
        _firstName.clear();
        _lastName.clear();
        _confirmPassword.clear();

        Navigator.push(
            context,

            // Go to next page to login
            MaterialPageRoute(builder: (context) => const ShowLoginPage()));
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
