import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => Store(),
      child: Consumer<Store>(builder: (context, store, child) {
        return MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: store.isDark
                ? const ColorScheme.dark(
                    primary: Colors.black38,
                    secondary: Color.fromARGB(255, 243, 73, 206),
                    onPrimary: Colors.white)
                : const ColorScheme.light(
                    primary: Colors.blue,
                    secondary: Colors.blueAccent,
                    onPrimary: Colors.black),
            useMaterial3: true,
          ),
          home: const MyHomePage(title: 'Flutter Dynamic design'),
        );
      }),
    );
  }
}

class Store extends ChangeNotifier {
  // STATES
  bool _isDark = false;
  bool get isDark => _isDark;

  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  GlobalKey<FormState> get formKey => _globalKey;

  String? _pass;
  String? _user;
  String? get pass => _pass;
  String? get user => _user;

  //toogle between dark true or false to switch theme
  void changeTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }

  //Logic to create state that allow reset form:
  void resetForm() {
    formKey.currentState?.reset();
    _user = null;
    _pass = null;
    notifyListeners();
  }

  void setUser(String? username, String? password) {
    _user = username;
    _pass = password;
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    Store appState = context.watch<Store>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {
              appState.changeTheme();
            },
            icon: const Icon(Icons.brightness_4),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Draggable(
                    data: "Your Data",
                    feedback: Material(
                      child: Column(
                        children: [
                          const Text(
                              'You have pushed the button this many times:'),
                          Text('$_counter',
                              style:
                                  Theme.of(context).textTheme.headlineMedium),
                          appState.user != null
                              ? Text(appState.user!)
                              : Container(),
                          appState.pass != null
                              ? Text(appState.pass!)
                              : Container(),
                        ],
                      ),
                    ),
                    childWhenDragging: Container(),
                    child: Column(
                      children: [
                        const Text(
                            'You have pushed the button this many times:'),
                        Text('$_counter',
                            style: Theme.of(context).textTheme.headlineMedium),
                        appState.user != null
                            ? Text(appState.user!)
                            : Container(),
                        appState.pass != null
                            ? Text(appState.pass!)
                            : Container(),
                      ],
                    ), // What to display when the draggable is picked up
                  )
                ],
              ),
            ),
            Theme(
              data: ThemeData(
                  colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple,
                brightness:
                    appState.isDark ? Brightness.dark : Brightness.light,
              )),
              child: Builder(builder: (innerContainer) {
                return Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: appState.isDark
                          ? Theme.of(innerContainer).colorScheme.surface
                          : Theme.of(innerContainer)
                              .colorScheme
                              .primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _counter = 0;
                                });
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Theme.of(innerContainer)
                                            .colorScheme
                                            .tertiary),
                              ),
                              child: const Text('Reset count'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                appState.resetForm();
                              },
                              child: const Text('Reset form'),
                            ),
                          ],
                        ),
                        const Expanded(flex: 2, child: FormExample()),
                      ],
                    ),
                  ),
                );
              }),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: appState.isDark ? 0 : 4,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class FormExample extends StatefulWidget {
  const FormExample({super.key});

  @override
  State<FormExample> createState() => _FormExampleState();
}

class _FormExampleState extends State<FormExample> {
  String? _username;
  String? _password;

  @override
  Widget build(BuildContext context) {
    Store appState = context.watch<Store>();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: appState.formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Enter your username',
              ),
              validator: (value) => value!.isEmpty ? 'Enter username' : null,
              onSaved: (value) => _username = value,
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Enter your password',
              ),
              validator: (value) => value!.isEmpty ? 'Enter password' : null,
              onSaved: (value) {
                _password = value;
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  if (appState.formKey.currentState!.validate()) {
                    appState.formKey.currentState!.save();
                    appState.setUser(_username, _password);
                    // Ahora las variables _username y _password contienen los valores ingresados
                    // Now the logic to do the post request:
                  }
                  setState(() {});
                },
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
