import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';

const Color _backgroundColor = Color(0xFFFBF5DD);
const Color _surfaceColor = Color(0xFFE7E1B1);
const Color _surfaceSoftColor = Color(0xFFFBF8E8);
const Color _primaryColor = Color(0xFF0D530E);
const Color _secondaryColor = Color(0xFF306D29);
const Color _mutedTextColor = Color(0xFF74705F);
const Color _dangerColor = Color(0xFFFF4E42);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const SmartFarmApp());
}

class SmartFarmApp extends StatelessWidget {
  const SmartFarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Farm',
      theme: ThemeData(
        scaffoldBackgroundColor: _backgroundColor,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primaryColor,
          primary: _primaryColor,
          secondary: _secondaryColor,
          surface: _surfaceColor,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 34,
            height: 1.05,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
            color: _primaryColor,
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            height: 1.2,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
            color: _primaryColor,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            height: 1.25,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
            color: _primaryColor,
          ),
          bodyLarge: TextStyle(
            fontSize: 15,
            height: 1.35,
            letterSpacing: 0,
            color: _mutedTextColor,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            height: 1.35,
            letterSpacing: 0,
            color: _mutedTextColor,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            height: 1.2,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.selected)
                ? _secondaryColor
                : _mutedTextColor;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.selected)
                ? _secondaryColor.withValues(alpha: 0.25)
                : Colors.black12;
          }),
        ),
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedIndex = 0;

  final List<Widget> pages = const [DashboardPage(), NotificationPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],

      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: _primaryColor.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            navButton(icon: Icons.home, label: "Dashboard", index: 0),

            navButton(icon: Icons.notifications, label: "Notifikasi", index: 1),
          ],
        ),
      ),
    );
  }

  Widget navButton({
    required IconData icon,
    required String label,
    required int index,
  }) {
    bool isActive = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 140,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? _surfaceSoftColor : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? _primaryColor : _mutedTextColor),

            const SizedBox(height: 4),

            Text(
              label,
              style: TextStyle(
                color: isActive ? _primaryColor : _mutedTextColor,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref(
    "smartfarm",
  );
  StreamSubscription<DatabaseEvent>? _smartfarmSubscription;

  int soil = 0;
  int water = 0;

  String status = "OFFLINE";
  String hama = "AMAN";
  String mode = "MONITORING";

  bool online = false;
  bool pompaMasuk = false;
  bool pompaKeluar = false;
  bool buzzer = false;

  bool get monitoring => mode == "MONITORING";

  @override
  void initState() {
    super.initState();

    _smartfarmSubscription = databaseRef.onValue.listen((event) {
      final snapshotValue = event.snapshot.value;

      if (snapshotValue is! Map) {
        return;
      }

      final data = Map<String, dynamic>.from(snapshotValue);

      setState(() {
        soil = _readInt(data["soil"], soil);
        water = _readInt(data["water"], water);
        status = _readString(data["status"], status);
        hama = _readString(data["hama"], hama);
        mode = _readString(data["mode"], mode);
        online = _readBool(data["online"], online);
        pompaMasuk = _readBool(data["pompaMasuk"], pompaMasuk);
        pompaKeluar = _readBool(data["pompaKeluar"], pompaKeluar);
        buzzer = _readBool(data["buzzer"], buzzer);
      });
    });
  }

  @override
  void dispose() {
    _smartfarmSubscription?.cancel();
    super.dispose();
  }

  int _readInt(Object? value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.round();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  String _readString(Object? value, String fallback) {
    if (value is String && value.isNotEmpty) return value;
    return fallback;
  }

  bool _readBool(Object? value, bool fallback) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lowerValue = value.toLowerCase();
      if (lowerValue == "true") return true;
      if (lowerValue == "false") return false;
    }
    return fallback;
  }

  double _percentValue(int value) {
    return value.clamp(0, 100) / 100;
  }

  double _waterHeight() {
    return _waterFillHeight * _percentValue(water);
  }

  static const double _waterFillHeight = 210;

  Future<void> _updateSmartfarmValue(String key, Object value) async {
    await databaseRef.update({key: value});
  }

  Future<void> _updateMode(bool value) async {
    await databaseRef.update({"mode": value ? "MONITORING" : "PINTAR"});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "SMART FARM",
                      style: TextStyle(
                        fontSize: 36,
                        height: 1.02,
                        fontWeight: FontWeight.w900,
                        color: _primaryColor,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "Monitoring & Control System",
                      style: TextStyle(
                        fontSize: 17,
                        color: _mutedTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 18),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: online
                            ? _secondaryColor.withValues(alpha: 0.12)
                            : _dangerColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            online ? Icons.wifi : Icons.wifi_off,
                            size: 20,

                            color: online ? _secondaryColor : _dangerColor,
                          ),

                          const SizedBox(width: 8),

                          Text(
                            online ? "ONLINE" : "OFFLINE",

                            style: TextStyle(
                              color: online ? _secondaryColor : _dangerColor,

                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                Container(
                  width: 104,
                  height: 104,

                  decoration: BoxDecoration(
                    color: _surfaceColor,
                    borderRadius: BorderRadius.circular(28),
                  ),

                  child: const Icon(
                    Icons.agriculture,
                    size: 58,
                    color: _secondaryColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 26),

            // MODE
            buildCard(
              child: Column(
                children: [
                  const Text(
                    "MODE SISTEM",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: _primaryColor,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _surfaceSoftColor,
                      borderRadius: BorderRadius.circular(24),
                    ),

                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              _updateMode(true);
                            },

                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 15),

                              decoration: BoxDecoration(
                                color: monitoring
                                    ? _secondaryColor
                                    : Colors.transparent,

                                borderRadius: BorderRadius.circular(18),
                              ),

                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.visibility,
                                    color: monitoring
                                        ? Colors.white
                                        : _primaryColor,
                                  ),

                                  const SizedBox(width: 8),

                                  Text(
                                    "MONITORING",
                                    style: TextStyle(
                                      color: monitoring
                                          ? Colors.white
                                          : _primaryColor,

                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              _updateMode(false);
                            },

                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 15),

                              decoration: BoxDecoration(
                                color: !monitoring
                                    ? _secondaryColor
                                    : Colors.transparent,

                                borderRadius: BorderRadius.circular(18),
                              ),

                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.touch_app,
                                    color: !monitoring
                                        ? Colors.white
                                        : _primaryColor,
                                  ),

                                  const SizedBox(width: 8),

                                  Text(
                                    "PINTAR",
                                    style: TextStyle(
                                      color: !monitoring
                                          ? Colors.white
                                          : _primaryColor,

                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // STATUS
            Row(
              children: [
                Expanded(
                  child: statusCard(
                    title: "STATUS SAWAH",
                    status: status,
                    description: _statusDescription(status),
                    color: _statusColor(status),
                    icon: Icons.water_damage,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: statusCard(
                    title: "STATUS HAMA",
                    status: hama,
                    description: _hamaDescription(hama),
                    color: _hamaColor(hama),
                    icon: Icons.shield,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // SENSOR
            Row(
              children: [
                Expanded(child: kelembabanCard()),

                const SizedBox(width: 16),

                Expanded(child: waterCard()),
              ],
            ),

            const SizedBox(height: 20),

            // CONTROL
            buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "KONTROL PERANGKAT",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: _primaryColor,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: controlCard(
                          title: "POMPA MASUK",
                          icon: Icons.water,
                          value: pompaMasuk,
                          onChanged: (value) {
                            _updateSmartfarmValue("pompaMasuk", value);
                          },
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: controlCard(
                          title: "POMPA KELUAR",
                          icon: Icons.water_damage,
                          value: pompaKeluar,
                          onChanged: (value) {
                            _updateSmartfarmValue("pompaKeluar", value);
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  buzzerCard(),
                ],
              ),
            ),

            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(26),
      ),

      child: child,
    );
  }

  String _statusDescription(String value) {
    final normalizedValue = value.toUpperCase();
    if (normalizedValue == "BANJIR") return "Kondisi air terlalu tinggi";
    if (normalizedValue == "KERING") return "Kelembaban tanah terlalu rendah";
    if (normalizedValue == "NORMAL") return "Kondisi sawah normal";
    return "Menunggu data kondisi sawah";
  }

  Color _statusColor(String value) {
    final normalizedValue = value.toUpperCase();
    if (normalizedValue == "NORMAL") return _secondaryColor;
    if (normalizedValue == "BANJIR") return Colors.blue.shade700;
    if (normalizedValue == "KERING") return _dangerColor;
    return _mutedTextColor;
  }

  String _hamaDescription(String value) {
    final normalizedValue = value.toUpperCase();
    if (normalizedValue == "AMAN") return "Tidak ada hama";
    if (normalizedValue == "TERDETEKSI") return "Hama terdeteksi";
    return "Menunggu data status hama";
  }

  Color _hamaColor(String value) {
    return value.toUpperCase() == "TERDETEKSI" ? _dangerColor : _secondaryColor;
  }

  Widget statusCard({
    required String title,
    required String status,
    required String description,
    required Color color,
    required IconData icon,
  }) {
    return SizedBox(
      height: 210,
      child: Container(
        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(24),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
            ),

            const SizedBox(height: 18),

            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                status,
                maxLines: 2,
                style: TextStyle(
                  fontSize: 32,
                  height: 1.12,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Text(description, style: const TextStyle(color: _mutedTextColor)),

            const Spacer(),

            Align(
              alignment: Alignment.bottomRight,

              child: CircleAvatar(
                radius: 24,
                backgroundColor: color.withValues(alpha: 0.15),

                child: Icon(icon, color: color, size: 27),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget kelembabanCard() {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(24),
      ),

      child: Column(
        children: [
          const Text(
            "KELEMBABAN TANAH",
            style: TextStyle(fontWeight: FontWeight.bold, color: _primaryColor),
          ),

          const SizedBox(height: 22),

          SizedBox(
            width: 156,
            height: 156,

            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 156,
                  height: 156,

                  child: CircularProgressIndicator(
                    value: _percentValue(soil),
                    strokeWidth: 13,
                    strokeCap: StrokeCap.round,
                    backgroundColor: _surfaceSoftColor,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      _secondaryColor,
                    ),
                  ),
                ),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "$soil%",
                      style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
                      ),
                    ),

                    Text(
                      _soilLabel(),
                      style: const TextStyle(color: _mutedTextColor),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(12),

            decoration: BoxDecoration(
              color: _surfaceSoftColor,
              borderRadius: BorderRadius.circular(16),
            ),

            child: Row(
              children: [
                const Icon(Icons.eco, color: _secondaryColor, size: 22),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    _soilDescription(),
                    style: const TextStyle(fontSize: 12, height: 1.25),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget waterCard() {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(24),
      ),

      child: Column(
        children: [
          const Text(
            "WATER LEVEL",
            style: TextStyle(fontWeight: FontWeight.bold, color: _primaryColor),
          ),

          const SizedBox(height: 20),

          Text(
            "$water%",
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: _secondaryColor,
            ),
          ),

          const SizedBox(height: 20),

          Container(
            width: 92,
            height: _waterFillHeight,

            decoration: BoxDecoration(
              color: _surfaceSoftColor,
              borderRadius: BorderRadius.circular(20),
            ),

            alignment: Alignment.bottomCenter,

            child: Container(
              height: _waterHeight(),
              width: double.infinity,

              decoration: const BoxDecoration(
                color: _secondaryColor,

                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget controlCard({
    required String title,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: _surfaceSoftColor,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,

            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: _primaryColor,
            ),
          ),

          const SizedBox(height: 18),

          Icon(icon, size: 52, color: _secondaryColor),

          const SizedBox(height: 18),

          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget buzzerCard() {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: _surfaceSoftColor,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: _secondaryColor.withValues(alpha: 0.15),

            child: const Icon(
              Icons.volume_up,
              size: 36,
              color: _secondaryColor,
            ),
          ),

          const SizedBox(width: 16),

          const Expanded(
            child: Text(
              "BUZZER",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
            ),
          ),

          Switch(
            value: buzzer,
            onChanged: (value) {
              _updateSmartfarmValue("buzzer", value);
            },
          ),
        ],
      ),
    );
  }

  String _soilLabel() {
    if (soil < 40) return "Kering";
    if (soil > 80) return "Basah";
    return "Lembab";
  }

  String _soilDescription() {
    if (soil < 40) return "Kondisi tanah membutuhkan air";
    if (soil > 80) return "Kondisi tanah terlalu basah";
    return "Kondisi tanah ideal untuk tanaman";
  }
}

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "NOTIFIKASI",
              style: TextStyle(
                fontSize: 36,
                height: 1.02,
                fontWeight: FontWeight.w900,
                color: _primaryColor,
              ),
            ),

            const SizedBox(height: 22),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 120),
                children: [
                  notifCard(
                    title: "SAWAH BANJIR",
                    desc: "Ketinggian air melebihi batas aman",
                    time: "21:14",
                    color: Colors.blue.shade700,
                    icon: Icons.warning,
                  ),

                  notifCard(
                    title: "SAWAH KERING",
                    desc: "Kelembaban tanah terlalu rendah",
                    time: "19:22",
                    color: _dangerColor,
                    icon: Icons.water_drop,
                  ),

                  notifCard(
                    title: "HAMA TERDETEKSI",
                    desc: "Sensor PIR mendeteksi hama",
                    time: "18:11",
                    color: _dangerColor,
                    icon: Icons.pest_control,
                  ),

                  notifCard(
                    title: "KONDISI NORMAL",
                    desc: "Sawah kembali normal",
                    time: "18:30",
                    color: _secondaryColor,
                    icon: Icons.check_circle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget notifCard({
    required String title,
    required String desc,
    required String time,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(22),
      ),

      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: color.withValues(alpha: 0.15),

            child: Icon(icon, color: color, size: 26),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  desc,
                  style: const TextStyle(
                    color: _mutedTextColor,
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Text(
            time,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: _mutedTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
