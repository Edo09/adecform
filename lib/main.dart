import 'package:adecform/formpage.dart';
import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // On Android, the default behavior will be to use the Google Play Store
  // version of the app.
  // On iOS, the default behavior will be to use the App Store version of
  // the app, so update the Bundle Identifier in example/ios/Runner with a
  // valid identifier already in the App Store.
  runApp(const MaterialApp(home: Home()));
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      child: Container(
        padding: const EdgeInsets.only(bottom: 20),
        decoration: const BoxDecoration(
            image: DecorationImage(
          image: AssetImage('assets/bg1.png'),
          fit: BoxFit.cover,
        )),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const Formpage()));
              },
              style: const ButtonStyle(
                  padding: MaterialStatePropertyAll(EdgeInsets.all(12)),
                  backgroundColor: MaterialStatePropertyAll(Color.fromARGB(255, 255, 106, 0))),
              child: const Text(
                'Llenar Formulario',
                style: TextStyle(fontSize: 20),
              ),
            )
          ],
        ),
      ),
    );
  }
}
