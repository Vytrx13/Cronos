import 'package:flutter/material.dart';
import 'package:teste_cronos/screens/home_screen.dart';
import 'package:teste_cronos/screens/signup_screen.dart';
import 'package:teste_cronos/widgets/text_input.dart';
import 'package:teste_cronos/resources/auth_methods.dart';
import 'package:teste_cronos/utils/utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  //login user function
  void loginUser() async {
    setState(() {
      _isLoading = true;
    });

    String res = await AuthMethods().logginUser(
      email: _emailController.text,
      password: _passwordController.text,
    );
    print(res);

    if (res != 'User logged in successfully') {
      showSnackBar(context, res);
    }

    setState(() {
      _isLoading = false;
    });

    if (res == 'User logged in successfully') {
      changeScreen(context, HomeScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    const String logo =
        'https://cdn.discordapp.com/attachments/1096589854999068743/1123776355927072768/Cronos_Logo_Invertido_500x500_1.png';
    return Scaffold(
      backgroundColor: colorDark,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: double.infinity,
              width: double.infinity,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 64),
                    //image - logo
                    Image.network(
                      logo,
                      height: 200,
                      width: 200,
                    ),
                    const SizedBox(height: 64),
                    //Text Field for email
                    TextFieldInput(
                      textEditingController: _emailController,
                      hintText: 'Insira seu Email',
                      textInputType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    //text field for password
                    TextFieldInput(
                        textEditingController: _passwordController,
                        hintText: 'Insira sua senha',
                        textInputType: TextInputType.text),
                    const SizedBox(height: 16),
                    //login button
                    InkWell(
                        onTap: loginUser,
                        child: Container(
                          child: _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                      color: Color.fromARGB(255, 26, 26, 26)),
                                )
                              : const Text('Login',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Color.fromARGB(255, 26, 26, 26))),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: colorGreen,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        )),
                    const SizedBox(height: 16),
                    //transitioning to signup
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Não tem uma conta?',
                          style: TextStyle(),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            changeScreen(context, const SignupScreen());
                          },
                          child: const Text(
                            'Cadastre-se',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colorGreen,
                            ),
                          ),
                        ),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 8)),
                      ],
                    ),
                    Flexible(child: Container(), flex: 1),
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
