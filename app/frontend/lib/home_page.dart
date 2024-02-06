import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:WebTriggers/bourse_page.dart';
import 'package:WebTriggers/chuck_norris_page.dart';
import 'dart:convert';
import 'sign_in.dart';
import 'weather_page.dart';
import 'crypto_page.dart';
import 'storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'nasa_widget.dart';
import 'config.dart';
import 'github_singinpage.dart';

class HomePage extends StatefulWidget {
  final String? userEmail;
  final String? userPhotoUrl;
  final String? userDisplayName;

  const HomePage({
    super.key,
    this.userEmail,
    this.userPhotoUrl,
    this.userDisplayName,
  });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic> userArea = {};
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserArea();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserArea() async {
    final prefs = await SharedPreferences.getInstance();
    String userAreaString = prefs.getString('userArea') ?? '';
    if (userAreaString.isNotEmpty) {
      try {
        final decodedUserArea = json.decode(userAreaString);
        if (decodedUserArea is Map<String, dynamic>) {
          setState(() {
            userArea = decodedUserArea;
          });
        }
      } catch (e) {
        debugPrint('Error decoding user area: $e');
      }
    }
  }

  void _removeArea(String areaKey) async {
    final url = '${Config.apiBaseUrl}/area/remove';
    final token = await Storage.getToken();
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'area': areaKey,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        userArea[areaKey] = false;
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userArea', json.encode(userArea));
    } else {
      debugPrint('Erreur lors de la suppression de l\'area');
    }
  }

  void refreshArea() async {
    await _loadUserArea();
    setState(() {});
  }

  Future<void> _activateArea(String areaKey) async {
    final url = '${Config.apiBaseUrl}/area/getareas';
    final token = await Storage.getToken();
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'area': areaKey,
      }),
    );

    if (response.statusCode == 200) {
      await _updateSharedPreferences(areaKey, true);
      debugPrint('Area $areaKey activated');
    } else {
      debugPrint('Error activating area: ${response.body}');
    }
  }

  Future<void> _updateSharedPreferences(String areaKey, bool isActive) async {
    final prefs = await SharedPreferences.getInstance();
    userArea[areaKey] = isActive;
    await prefs.setString('userArea', json.encode(userArea));
    setState(() {});
  }

  Future<void> _addArea(String areaKey) async {
    await _activateArea(areaKey); // Activate the area on the backend
    _tabController.animateTo(0); // Navigate back to the Home tab
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Nombre d'onglets
      child: Scaffold(
        appBar: AppBar(
          title: Center(
            child: Image.asset(
              'assets/images/webTriggersHeaderLogo.png',
              height: 20.0,
            ),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Home'),
              Tab(text: 'Store'),
            ],
            labelStyle: TextStyle(
              fontSize: 15,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            indicatorColor: Color.fromARGB(255, 67, 65, 65),
            indicatorSize: TabBarIndicatorSize.tab,
          ),
          actions: const [
            SizedBox(width: 60),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(
                  widget.userDisplayName ?? 'Guest',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                accountEmail: Text(
                  widget.userEmail ?? '',
                  style: const TextStyle(
                    fontSize: 14.0,
                  ),
                ),
                currentAccountPicture: CircleAvatar(
                  radius: 35.0,
                  backgroundColor: Colors.white,
                  backgroundImage: widget.userPhotoUrl != null
                      ? NetworkImage(widget.userPhotoUrl!)
                      : null,
                  child: widget.userPhotoUrl == null
                      ? Text(
                          widget.userDisplayName != null &&
                                  widget.userDisplayName!.isNotEmpty
                              ? widget.userDisplayName![0].toUpperCase()
                              : '',
                          style: const TextStyle(
                              fontSize: 24.0, color: Colors.blue),
                        )
                      : null,
                ),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 61, 61, 61),
                ),
              ),
              ListTile(
                title: const Text('Sign Out'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildActiveWidgets(
                context), // Contenu pour l'onglet "Active Widget"
            _buildHomePageContent(context), // Contenu pour l'onglet "Home Page"
          ],
        ),
      ),
    );
  }

  Widget _buildActiveWidgets(BuildContext context) {
    List<Widget> activeWidgets = [];
    if (userArea['crypto'] == true) {
      activeWidgets.add(_bitcoinWidgetHome(context));
    }
    if (userArea['meteo'] == true) {
      activeWidgets.add(_weatherWidgetHome(context));
    }
    if (userArea['nasa'] == true) {
      activeWidgets.add(_nasaWidgetHome(context));
    }
    if (userArea['norris'] == true) {
      activeWidgets.add(_chuckNorrisWidgetHome(context));
    }
    if (userArea['bourse'] == true) {
      activeWidgets.add(_bourseWidgetHome(context));
    }
    if (userArea['github'] == true) {
      activeWidgets.add(_githubWidgetHome(context));
    }

    return activeWidgets.isNotEmpty
        ? ListView(children: activeWidgets)
        : const Center(
            child: Text("You don't have any active widgets yet"),
          );
  }

  Widget _buildHomePageContent(BuildContext context) {
    List<Widget> storeWidgets = [];
    if (userArea['crypto'] != true) {
      storeWidgets.add(_bitcoinWidgetStore(context));
    }
    if (userArea['meteo'] != true) {
      storeWidgets.add(_weatherWidgetStore(context));
    }
    if (userArea['nasa'] != true) {
      storeWidgets.add(_nasaWidgetStore(context));
    }
    if (userArea['norris'] != true) {
      storeWidgets.add(_chuckNorrisWidgetStore(context));
    }
    if (userArea['bourse'] != true) {
      storeWidgets.add(_bourseWidgetStore(context));
    }
    if (userArea['github'] != true) {
      storeWidgets.add(_githubWidgetStore(context));
    }

    return storeWidgets.isNotEmpty
        ? ListView(children: storeWidgets)
        : const Center(
            child: Text("You have already added all the widgets"),
          );
  }

  Widget _bitcoinWidgetHome(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Container(
            margin: kIsWeb
                ? const EdgeInsets.only(left: 25.0, right: 25.0, top: 50.0)
                : const EdgeInsets.only(
                    left: 25.0, right: 25.0, top: 20.0, bottom: 8.0),
            height: 100.0,
            width: kIsWeb
                ? MediaQuery.of(context).size.width * 0.5
                : double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange[200]!, Colors.orange[400]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 6,
                  offset: const Offset(3, 3),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.only(right: 30.0, left: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Bitcoin Price Alert',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/bitcoinBag.png',
                          width: 40.0, height: 40.0),
                      const SizedBox(
                          width:
                              40.0), // Adjust the width as needed for spacing
                      Image.asset('assets/images/bitcoinStack.png',
                          width: 50.0, height: 50.0),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: kIsWeb ? (MediaQuery.of(context).size.width * 0.25) + 20 : 35,
          top: kIsWeb ? 60 : 30,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _removeArea('crypto'),
              borderRadius: BorderRadius.circular(20.0),
              child: Container(
                padding: const EdgeInsets.all(6.0),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromARGB(47, 255, 255, 255),
                ),
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _weatherWidgetHome(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Container(
            margin: kIsWeb
                ? const EdgeInsets.only(left: 25.0, right: 25.0, top: 50.0)
                : const EdgeInsets.only(
                    left: 25.0, right: 25.0, top: 20.0, bottom: 8.0),
            height: 100.0,
            width: kIsWeb
                ? MediaQuery.of(context).size.width * 0.5
                : double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[200]!, Colors.blue[400]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 6,
                  offset: const Offset(3, 3),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.only(right: 30.0, left: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Weather Information',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/weatherIcons.png',
                          height: 40.0),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: kIsWeb ? (MediaQuery.of(context).size.width * 0.25) + 20 : 35,
          top: kIsWeb ? 60 : 30,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _removeArea('meteo'),
              borderRadius: BorderRadius.circular(20.0),
              child: Container(
                padding: const EdgeInsets.all(6.0),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromARGB(47, 255, 255, 255),
                ),
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _nasaWidgetHome(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Container(
            margin: kIsWeb
                ? const EdgeInsets.only(left: 25.0, right: 25.0, top: 50.0)
                : const EdgeInsets.only(
                    left: 25.0, right: 25.0, top: 20.0, bottom: 8.0),
            height: 100.0,
            width: kIsWeb
                ? MediaQuery.of(context).size.width * 0.5
                : double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple[200]!, Colors.purple[400]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 6,
                  offset: const Offset(3, 3),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.only(right: 30.0, left: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'NASA Space News',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/nasaSpaceIcons.png',
                          height: 40.0), // Adjust the image path
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: kIsWeb ? (MediaQuery.of(context).size.width * 0.25) + 20 : 35,
          top: kIsWeb ? 60 : 30,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _removeArea('nasa'),
              borderRadius: BorderRadius.circular(20.0),
              child: Container(
                padding: const EdgeInsets.all(6.0),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromARGB(47, 255, 255, 255),
                ),
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _chuckNorrisWidgetHome(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Container(
            margin: kIsWeb
                ? const EdgeInsets.only(left: 25.0, right: 25.0, top: 50.0)
                : const EdgeInsets.only(
                    left: 25.0, right: 25.0, top: 20.0, bottom: 8.0),
            height: 100.0,
            width: kIsWeb
                ? MediaQuery.of(context).size.width * 0.5
                : double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[200]!, Colors.green[400]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 6,
                  offset: const Offset(3, 3),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.only(right: 30.0, left: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Chuck Norris Joke',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/chuckNorrisIcons.png',
                          height: 50.0), // Adjust the image path
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: kIsWeb ? (MediaQuery.of(context).size.width * 0.25) + 20 : 35,
          top: kIsWeb ? 60 : 30,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _removeArea('norris'),
              borderRadius: BorderRadius.circular(20.0),
              child: Container(
                padding: const EdgeInsets.all(6.0),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromARGB(47, 255, 255, 255),
                ),
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _bourseWidgetHome(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Container(
            margin: kIsWeb
                ? const EdgeInsets.only(left: 25.0, right: 25.0, top: 50.0)
                : const EdgeInsets.only(
                    left: 25.0, right: 25.0, top: 20.0, bottom: 8.0),
            height: 100.0,
            width: kIsWeb
                ? MediaQuery.of(context).size.width * 0.5
                : double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red[200]!, Colors.red[400]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 6,
                  offset: const Offset(3, 3),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.only(right: 30.0, left: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Stock Market Information',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/tradingIcons.png',
                          height: 40.0), // Adjust the image path
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: kIsWeb ? (MediaQuery.of(context).size.width * 0.25) + 20 : 35,
          top: kIsWeb ? 60 : 30,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _removeArea('bourse'),
              borderRadius: BorderRadius.circular(20.0),
              child: Container(
                padding: const EdgeInsets.all(6.0),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromARGB(47, 255, 255, 255),
                ),
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _githubWidgetHome(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Container(
            margin: kIsWeb
                ? const EdgeInsets.only(left: 25.0, right: 25.0, top: 50.0)
                : const EdgeInsets.only(
                    left: 25.0, right: 25.0, top: 20.0, bottom: 8.0),
            height: 100.0,
            width: kIsWeb
                ? MediaQuery.of(context).size.width * 0.5
                : double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey[200]!, Colors.grey[400]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 6,
                  offset: const Offset(3, 3),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.only(right: 30.0, left: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Github Information',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/gitHubAreaIcons.png',
                          height: 40.0), // Adjust the image path
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: kIsWeb ? (MediaQuery.of(context).size.width * 0.25) + 20 : 35,
          top: kIsWeb ? 60 : 30,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _removeArea('github'),
              borderRadius: BorderRadius.circular(20.0),
              child: Container(
                padding: const EdgeInsets.all(6.0),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromARGB(47, 255, 255, 255),
                ),
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _bitcoinWidgetStore(BuildContext context) {
    return GestureDetector(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CryptoPage(onConfigured: () {
                _addArea(
                    'crypto'); // Utilisez _addArea pour activer et naviguer
              }),
            ),
          );
        },
        child: Align(
          child: Container(
              margin: kIsWeb
                  ? const EdgeInsets.only(
                      left: 25.0, right: 25.0, top: 50.0, bottom: 8.0)
                  : const EdgeInsets.only(
                      left: 25.0, right: 25.0, top: 20.0, bottom: 8.0),
              padding: const EdgeInsets.all(16.0),
              height: 170.0,
              width: kIsWeb
                  ? MediaQuery.of(context).size.width * 0.5
                  : double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange[200]!, Colors.orange[400]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 6,
                    offset: const Offset(3, 3),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.only(right: 30.0, left: 30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Configure Bitcoin Price Alerts',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Receive an alert once the Price of Bitcoin is above or below a certain value',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                          fontSize: 12.0),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/bitcoinBag.png',
                            width: 40.0, height: 40.0),
                        const SizedBox(
                            width:
                                40.0), // Adjust the width as needed for spacing
                        Image.asset('assets/images/bitcoinStack.png',
                            width: 50.0, height: 50.0),
                      ],
                    ),
                  ],
                ),
              )),
        ));
  }

  Widget _weatherWidgetStore(BuildContext context) {
    return GestureDetector(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WeatherPage(onConfigured: () {
                _addArea('meteo');
              }),
            ),
          );
        },
        child: Align(
          child: Container(
            margin: const EdgeInsets.only(
                left: 25.0, right: 25.0, top: 20.0, bottom: 8.0),
            padding: const EdgeInsets.all(16.0),
            height: 170.0,
            width: kIsWeb
                ? MediaQuery.of(context).size.width * 0.5
                : double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[200]!, Colors.blue[400]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 6,
                  offset: const Offset(3, 3),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.only(right: 30.0, left: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Configure Weather Alerts',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Receive alerts based on weather conditions',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                        fontSize: 12.0),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/weatherIcons.png',
                          height: 40.0), // Adjust the image path
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _nasaWidgetStore(BuildContext context) {
    return GestureDetector(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NasaPage(onConfigured: () {
                _addArea('nasa');
              }),
            ),
          );
        },
        child: Align(
          child: Container(
            margin: const EdgeInsets.only(
                left: 25.0, right: 25.0, top: 20.0, bottom: 8.0),
            padding: const EdgeInsets.all(16.0),
            height: 170.0,
            width: kIsWeb
                ? MediaQuery.of(context).size.width * 0.5
                : double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple[200]!, Colors.purple[400]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 6,
                  offset: const Offset(3, 3),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.only(right: 30.0, left: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Configure NASA Alert',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Receive the NASA picture of the day in your email',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                        fontSize: 12.0),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/nasaSpaceIcons.png',
                          height: 40.0), // Adjust the image path
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _chuckNorrisWidgetStore(BuildContext context) {
    return GestureDetector(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChuckNorrisPage(onConfigured: () {
                _addArea('norris');
              }),
            ),
          );
        },
        child: Align(
          child: Container(
            margin: const EdgeInsets.only(
                left: 25.0, right: 25.0, top: 20.0, bottom: 8.0),
            padding: const EdgeInsets.all(16.0),
            height: 170.0,
            width: kIsWeb
                ? MediaQuery.of(context).size.width * 0.5
                : double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[200]!, Colors.green[400]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 6,
                  offset: const Offset(3, 3),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.only(right: 30.0, left: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Configure Chuck Norris Alert',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Receive emails with Chuck Norris jokes and fun facts',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                        fontSize: 12.0),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/chuckNorrisIcons.png',
                          height: 50.0), // Adjust the image path
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _bourseWidgetStore(BuildContext context) {
    return GestureDetector(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BoursePage(onConfigured: () {
                _addArea('bourse');
              }),
            ),
          );
        },
        child: Align(
          child: Container(
            margin: const EdgeInsets.only(
                left: 25.0, right: 25.0, top: 20.0, bottom: 8.0),
            padding: const EdgeInsets.all(16.0),
            height: 170.0,
            width: kIsWeb
                ? MediaQuery.of(context).size.width * 0.5
                : double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red[200]!, Colors.red[400]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 6,
                  offset: const Offset(3, 3),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.only(right: 30.0, left: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Configure Stock Market Alerts',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Receive alerts based on stock market conditions',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                        fontSize: 12.0),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/tradingIcons.png',
                          height: 40.0), // Adjust the image path
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _githubWidgetStore(BuildContext context) {
    return GestureDetector(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  GitHubSignInWidget(onConfigured: (accessToken) {
                _addArea('github');
              }),
            ),
          );
        },
        child: Align(
          child: Container(
            margin: const EdgeInsets.only(
                left: 25.0, right: 25.0, top: 20.0, bottom: 8.0),
            padding: const EdgeInsets.all(16.0),
            height: 170.0,
            width: kIsWeb
                ? MediaQuery.of(context).size.width * 0.5
                : double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 94, 94, 94),
                  Color.fromARGB(255, 29, 29, 29)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 6,
                  offset: const Offset(3, 3),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.only(right: 30.0, left: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Configure Github Repo',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Receive alerts based on merge github repo',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                        fontSize: 12.0),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/gitHubAreaIcons.png',
                          height: 40.0), // Adjust the image path
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
