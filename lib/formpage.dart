import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mailer/mailer.dart';
import 'package:open_file/open_file.dart';
import 'package:mailer/smtp_server.dart';

import 'package:video_player/video_player.dart';

class Formpage extends StatefulWidget {
  const Formpage({super.key});

  @override
  State<Formpage> createState() => _FormpageState();
}

List<String> list = <String>['Santo Domingo / Zona Este', 'Santiago / Zona Norte', 'Zona Sur'];

class _FormpageState extends State<Formpage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  String residencia = list.first;
  String fileUrl = 'http://www.gratex.net/adecintl/pdf/brochureadec.pdf';
  String fileName = 'BrochureADEC2023.pdf';
  Duration cooldownDuration2 = const Duration(seconds: 5);

  Future<void> downloadAndOpenFile(String url, String fileName) async {
    Dio dio = Dio();
    try {
      Directory? appDirectory = await getExternalStorageDirectory();
      String filePath = '${appDirectory!.path}/Download/$fileName';
      File file = File(filePath);

      bool fileExists = await file.exists();
      if (fileExists) {
        print('File exists!');

        // Perform operations on the file.
        await OpenFile.open(filePath);
      } else {
        print('File does not exist.');
        // Handle the case when the file does not exist.

        await dio.download(url, filePath);
        print('File downloaded and saved to: $filePath');

        await OpenFile.open(filePath);
      }
    } catch (e) {
      print('Error occurred during file download: $e');
    }
  }

  void descargaform() async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 15,
                  ),
                  Text('Descargando...')
                ],
              ),
            ),
          );
        });

    // Disable the button
    setState(() {
      isButtonDisabled2 = true;
    });

    downloadAndOpenFile(fileUrl, fileName).then((value) => {Navigator.of(context).pop()});
    // Start the cooldown timer
    Timer(cooldownDuration, () {
      setState(() {
        isButtonDisabled2 = false; // Enable the button after cooldown
      });
    });
  }

  bool isButtonDisabled = false;
  bool isButtonDisabled2 = false;
  Duration cooldownDuration = const Duration(seconds: 20);

  final _specialCharRegExp = RegExp(r'[-=_+\[\]\\;/\!@#$%^&*(),.?":{}|<>1234567890]');

  var listSorted = list.map<DropdownMenuItem<String>>((String value) {
    return DropdownMenuItem<String>(
      value: value,
      child: Text(
        value,
        style: const TextStyle(color: Colors.black),
      ),
    );
  }).toList();

  void handleButtonClick() {
    if (_formKey.currentState?.validate() ?? false) {
      // Perform form validation here

      // Disable the button
      setState(() {
        isButtonDisabled = true;
      });

      // Perform the email sending logic
      sendEmail();
      // Start the cooldown timer
      Timer(cooldownDuration, () {
        setState(() {
          isButtonDisabled = false;
        });
      });
    }
  }

  Future<void> sendEmail() async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 15,
                  ),
                  Text('Enviando informacion...')
                ],
              ),
            ),
          );
        });
    final smtpServer = gmail('omareogm09@gmail.com', 'yzjospvqpkjigzgb');

    final message = Message()
      ..from = const Address('omareogm09@gmail.com', 'Adec')
      ..recipients.add('adecinternacional.intercambios@gmail.com')
      ..recipients.add('summer.work.adec@gmail.com')
      ..recipients.add('omareogm09@gmail.com')
      ..recipients.add('edwin@gratex.net')
      ..subject = 'Informacion de contacto'
      ..text = '''
      Nombre: ${_nameController.text + _lastnameController.text}
      Email: ${_emailController.text}
      Telefono: ${_phoneNumberController.text}
      ''';
    final recipentsMessage = Message()
      ..from = const Address('omareogm09@gmail.com', 'edwin')
      ..recipients.add(_emailController.text)
      ..recipients.add('omareogm09@gmail.com')
      ..subject = 'Form Submission'
      ..text = '''
  Tu informacion ha sido enviada correctamente
      ''';
    //resetInputs();
    try {
      await send(message, smtpServer);

      await send(recipentsMessage, smtpServer).then((value) => {
            Navigator.of(context).pop(),
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Success'),
                content: const Text('Tu contacto se ha enviado correctamente'),
                actions: [
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            )
          });

      // ignore: use_build_context_synchronously
    } catch (e) {
      print('Error: $e');
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Ha ocurrido un problema de conexion'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    }
  }

  void resetInputs() {
    _nameController.clear();
    _emailController.clear();
    _lastnameController.clear();
    _phoneNumberController.clear();
  }

  late VideoPlayerController _controller;
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset('assets/testimonio.mp4');

    _controller.addListener(() {
      setState(() {});
    });
    _controller.setLooping(false);
    _controller.initialize().then((_) => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String dropdownValue = list.first;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
            image: AssetImage('assets/bg2.jpg'),
            fit: BoxFit.fill,
          )),
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  style: const TextStyle(color: Colors.white),
                  controller: _nameController,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(50),
                    FilteringTextInputFormatter.deny(_specialCharRegExp)
                  ],
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 1.0),
                    ),
                    labelText: 'Nombres',
                    hintText: 'Nombres',
                    labelStyle: TextStyle(color: Colors.white),
                    hintStyle: TextStyle(color: Colors.white),
                    fillColor: Colors.white,
                    prefixIcon: Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Campo Vacío';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  style: const TextStyle(color: Colors.white),
                  controller: _lastnameController,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(50),
                    FilteringTextInputFormatter.deny(_specialCharRegExp)
                  ],
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 1.0),
                    ),
                    labelText: 'Apellidos',
                    hintText: 'Apellidos',
                    labelStyle: TextStyle(color: Colors.white),
                    hintStyle: TextStyle(color: Colors.white),
                    fillColor: Colors.white,
                    prefixIcon: Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Campo Vacío';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  style: const TextStyle(color: Colors.white),
                  controller: _emailController,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(50),
                  ],
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 1.0),
                    ),
                    labelText: 'Correo',
                    hintText: 'Correo',
                    labelStyle: TextStyle(color: Colors.white),
                    hintStyle: TextStyle(color: Colors.white),
                    prefixIcon: Icon(
                      Icons.mail,
                      color: Colors.white,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Campo vacío';
                    }
                    bool emailValid =
                        RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value);
                    if (!emailValid) {
                      return 'Correo Invalido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  style: const TextStyle(color: Colors.white),
                  controller: _phoneNumberController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // Allow only digits
                    LengthLimitingTextInputFormatter(12),
                  ],
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 1.0),
                    ),
                    labelText: 'Celular',
                    hintText: 'Celular',
                    labelStyle: TextStyle(color: Colors.white),
                    hintStyle: TextStyle(color: Colors.white),
                    prefixIcon: Icon(Icons.phone, color: Colors.white),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Campo vacío';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField(
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 1.0),
                    ),
                    labelText: 'Lugar de residencia',
                    hintText: 'Lugar de residencia',
                    labelStyle: TextStyle(color: Colors.white),
                    prefixIcon: Icon(Icons.location_pin, color: Colors.white),
                    border: OutlineInputBorder(),
                  ),
                  value: dropdownValue,
                  selectedItemBuilder: (BuildContext ctxt) {
                    return list.map<Widget>((item) {
                      return DropdownMenuItem(
                          value: item, child: Text(item, style: const TextStyle(color: Colors.white)));
                    }).toList();
                  },
                  items: listSorted,
                  onChanged: (value) {
                    residencia = value.toString();
                  },
                ),
                const SizedBox(height: 16.0),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        onPressed: isButtonDisabled ? null : handleButtonClick,
                        child: const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            'Enviar',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        onPressed: isButtonDisabled2 ? null : descargaform,
                        child: const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            'Descargar Brochure',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        onPressed: () {
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (_) => AlertDialog(
                              content: AspectRatio(
                                aspectRatio: _controller.value.aspectRatio,
                                child: Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: <Widget>[
                                    VideoPlayer(_controller),
                                    _ControlsOverlay(controller: _controller),
                                    VideoProgressIndicator(_controller, allowScrubbing: true),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  child: const Icon(Icons.close),
                                  onPressed: () {
                                    _controller.pause();
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            'Testimonio',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ControlsOverlay extends StatefulWidget {
  const _ControlsOverlay({required this.controller});

  final VideoPlayerController controller;

  @override
  State<_ControlsOverlay> createState() => _ControlsOverlayState();
}

class _ControlsOverlayState extends State<_ControlsOverlay> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: widget.controller.value.isPlaying
              ? const SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                      semanticLabel: 'Play',
                    ),
                  ),
                ),
        ),
        InkWell(
          onTap: () {
            setState(() {
              widget.controller.value.isPlaying ? widget.controller.pause() : widget.controller.play();
            });
          },
        ),
      ],
    );
  }
}
