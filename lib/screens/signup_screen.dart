import 'package:flutter/material.dart';
import 'package:teste_cronos/resources/auth_methods.dart';
import 'package:teste_cronos/screens/login_screen.dart';
import 'package:teste_cronos/utils/utils.dart';
import 'package:teste_cronos/widgets/text_input.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
  }

  //signup user function
  void signUpUser() async {
    setState(() {
      _isLoading = true;
    });

    String res = await AuthMethods().signUpUser(
      email: _emailController.text,
      username: _usernameController.text,
      password: _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    print(res);

    if (res != 'User registered successfully') {
      showSnackBar(context, res);
    }

    if (res == 'User registered successfully') {
      changeScreen(context, const LoginScreen());
      showSnackBar(context, 'Usuário cadastrado, faça o login.');
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
              width: double.infinity,
              height: double.infinity - 32,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 64),
                    //png logo from assets
                    Image.network(
                      logo,
                      width: 200,
                      height: 200,
                    ),

                    const SizedBox(height: 64),
                    //text field for username
                    TextFieldInput(
                      textEditingController: _usernameController,
                      hintText: 'Insira nome de usuário',
                      textInputType: TextInputType.text,
                    ),

                    const SizedBox(height: 16),

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

                    //register button
                    InkWell(
                        onTap: signUpUser,
                        child: Container(
                          child: _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                      color: Color.fromARGB(255, 26, 26, 26)))
                              : const Text('Cadastre-se',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: const Color.fromARGB(
                                          255, 26, 26, 26))),
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
                          'Já possui uma conta?',
                          style: TextStyle(),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            changeScreen(context, const LoginScreen());
                          },
                          child: const Text(
                            'Entre',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colorGreen,
                            ),
                          ),
                        ),
                        const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8)),
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
