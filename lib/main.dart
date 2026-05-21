import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:js/js.dart';
import 'package:js/js_util.dart';

@JS()
external dynamic get ethereum;

@JS('window')
external dynamic get window;

@JS('Object.keys')
external List<String> getObjectKeys(dynamic obj);

@JS('console.log')
external void jsLog(dynamic msg);

void main() {
  runApp(const TerlineTApp());
}

class TerlineTApp extends StatelessWidget {
  const TerlineTApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TerlineT IT Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const InitialScreen(),
    );
  }
}

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/video.mp4')
      ..initialize().then((_) {
        _controller.setVolume(0.0);
        _controller.setLooping(true);
        _controller.play();
        setState(() {});
      }).catchError((error) {
        print("Error initializing video player: $error");
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: _controller.value.isInitialized
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  )
                : Container(
                    color: Colors.black,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.blueAccent),
                    ),
                  ),
          ),
          Container(color: Colors.black.withOpacity(0.4)),
          const Center(child: MainContent()),
          const FloatingCyberCube(),
        ],
      ),
    );
  }
}

class FloatingCyberCube extends StatefulWidget {
  const FloatingCyberCube({super.key});

  @override
  State<FloatingCyberCube> createState() => _FloatingCyberCubeState();
}

class _FloatingCyberCubeState extends State<FloatingCyberCube>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Offset _position = const Offset(100, 100);
  Offset _direction = const Offset(1, 1);
  double _rotationX = 0;
  double _rotationY = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_updatePosition);
    _controller.repeat();
  }

  void _updatePosition() {
    setState(() {
      _position += _direction * 1.5;
      _rotationX += 0.02;
      _rotationY += 0.03;
      final size = MediaQuery.of(context).size;
      if (_position.dx < 0) {
        _position = Offset(0, _position.dy);
        _direction = Offset(-_direction.dx, _direction.dy);
      } else if (_position.dx > size.width - 120) {
        _position = Offset(size.width - 120, _position.dy);
        _direction = Offset(-_direction.dx, _direction.dy);
      }
      if (_position.dy < 0) {
        _position = Offset(_position.dx, 0);
        _direction = Offset(_direction.dx, -_direction.dy);
      } else if (_position.dy > size.height - 120) {
        _position = Offset(_position.dx, size.height - 120);
        _direction = Offset(_direction.dx, -_direction.dy);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.002)
                    ..rotateX(_rotationX)
                    ..rotateY(_rotationY),
                  alignment: FractionalOffset.center,
                  child: _buildCube(),
                ),
                Text(
                  'ENTRAR',
                  style: GoogleFonts.orbitron(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [const Shadow(color: Colors.blueAccent, blurRadius: 10)],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCube() {
    return Stack(
      children: [
        _cubeFace(const Offset(0, 0), 50, Colors.blueAccent),
        _cubeFace(const Offset(0, 0), -50, Colors.blueAccent),
        Transform(
          transform: Matrix4.identity()..rotateY(math.pi / 2)..translate(0.0, 0.0, 50.0),
          child: _cubeFace(Offset.zero, 0, Colors.cyanAccent),
        ),
        Transform(
          transform: Matrix4.identity()..rotateY(-math.pi / 2)..translate(0.0, 0.0, 50.0),
          child: _cubeFace(Offset.zero, 0, Colors.cyanAccent),
        ),
        Transform(
          transform: Matrix4.identity()..rotateX(math.pi / 2)..translate(0.0, 0.0, 50.0),
          child: _cubeFace(Offset.zero, 0, Colors.blueAccent),
        ),
        Transform(
          transform: Matrix4.identity()..rotateX(-math.pi / 2)..translate(0.0, 0.0, 50.0),
          child: _cubeFace(Offset.zero, 0, Colors.blueAccent),
        ),
      ],
    );
  }

  Widget _cubeFace(Offset offset, double z, Color color) {
    return Transform(
      transform: Matrix4.identity()..translate(offset.dx, offset.dy, z),
      alignment: Alignment.center,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color.withOpacity(0.8), width: 2),
          boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 10, spreadRadius: 1)],
        ),
      ),
    );
  }
}

class MainContent extends StatefulWidget {
  const MainContent({super.key});

  @override
  State<MainContent> createState() => _MainContentState();
}

class _MainContentState extends State<MainContent> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: const Duration(seconds: 2),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [ParticleText(text: 'TerlineT IT Manager')],
      ),
    );
  }
}

class ParticleText extends StatefulWidget {
  final String text;
  const ParticleText({super.key, required this.text});

  @override
  State<ParticleText> createState() => _ParticleTextState();
}

class _ParticleTextState extends State<ParticleText>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final List<Particle> particles = List.generate(40, (index) => Particle());

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(particles, _animationController.value),
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Text(
              widget.text,
              textAlign: TextAlign.center,
              style: GoogleFonts.orbitron(
                fontSize: 42,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 8,
                shadows: [
                  const Shadow(blurRadius: 20, color: Colors.blueAccent),
                  const Shadow(blurRadius: 10, color: Colors.cyanAccent),
                  Shadow(blurRadius: 2, color: Colors.white.withOpacity(0.8)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class Particle {
  double radius = math.Random().nextDouble() * 2 + 1;
  double angle = math.Random().nextDouble() * math.pi * 2;
  double distance = math.Random().nextDouble() * 100 + 100;
  double speed = math.Random().nextDouble() * 0.02 + 0.01;
  Color color = math.Random().nextBool() ? Colors.blueAccent : Colors.white;

  void update() {
    angle += speed;
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;

  ParticlePainter(this.particles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (var particle in particles) {
      particle.update();
      final x = center.dx + math.cos(particle.angle) * (particle.distance + math.sin(animationValue * math.pi * 2) * 10);
      final y = center.dy + math.sin(particle.angle) * (particle.distance + math.cos(animationValue * math.pi * 2) * 10);
      final paint = Paint()
        ..color = particle.color.withOpacity(0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(Offset(x, y), particle.radius, paint);
      final glowPaint = Paint()
        ..color = particle.color.withOpacity(0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(Offset(x, y), particle.radius * 3, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = false;
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _loadSavedUser();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _emailController.text = prefs.getString('saved_user') ?? '';
      _rememberMe = _emailController.text.isNotEmpty;
    });
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    try {
      String input = _emailController.text.trim();
      String fullEmail = input.contains('@') ? input : '$input@terlinet.com';
      final url = Uri.parse('https://tertulianoshow-terlinet-backend.hf.space/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': fullEmail, 'password': _passwordController.text}),
      );
      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        if (_rememberMe) {
          await prefs.setString('saved_user', input);
        } else {
          await prefs.remove('saved_user');
        }
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        }
      } else {
        final errorData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorData['detail'] ?? 'Erro no login'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de conexão: $e'), backgroundColor: Colors.orange),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blueAccent, width: 2),
                  boxShadow: [
                    BoxShadow(color: Colors.blueAccent.withOpacity(0.3), blurRadius: 40, spreadRadius: 2),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('LOGIN', style: GoogleFonts.orbitron(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2)),
                    const SizedBox(height: 40),
                    _buildTextField(controller: _emailController, label: 'USUÁRIO (ex: joao)', icon: Icons.person_outline, suffix: '@terlinet.com'),
                    const SizedBox(height: 20),
                    _buildTextField(controller: _passwordController, label: 'SENHA', icon: Icons.lock_outline, isPassword: true),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          activeColor: Colors.blueAccent,
                          onChanged: (value) => setState(() => _rememberMe = value ?? false),
                        ),
                        Text('Lembrar usuário', style: GoogleFonts.orbitron(fontSize: 10, color: Colors.white70)),
                        const Spacer(),
                        TextButton(
                          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ForgotPasswordScreen())),
                          child: Text('Esqueci a senha?', style: GoogleFonts.orbitron(fontSize: 10, color: Colors.blueAccent.withOpacity(0.8))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    _buildLoginButton(),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SignUpScreen())),
                      child: Text('Não tem uma conta? Registre-se', style: GoogleFonts.orbitron(fontSize: 10, color: Colors.blueAccent)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ...List.generate(5, (index) {
            return AnimatedBuilder(
              animation: _rotationController,
              builder: (context, child) {
                final size = MediaQuery.of(context).size;
                final x = (math.sin(_rotationController.value * 2 * math.pi + index) * 0.4 + 0.5) * size.width;
                final y = (math.cos(_rotationController.value * 2 * math.pi + index * 2) * 0.4 + 0.5) * size.height;
                return Positioned(
                  left: x - 40,
                  top: y - 40,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0.2,
                      child: Transform(
                        transform: Matrix4.identity()..setEntry(3, 2, 0.002)..rotateX(_rotationController.value * 2 * math.pi + index)..rotateY(_rotationController.value * 2 * math.pi),
                        alignment: Alignment.center,
                        child: _buildBackgroundCube(index.isEven ? Colors.blueAccent : Colors.cyanAccent),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
          Positioned(top: 40, left: 20, child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context))),
        ],
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, bool isPassword = false, String? suffix}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.blueAccent, size: 20),
        labelText: label,
        suffixText: suffix,
        suffixStyle: const TextStyle(color: Colors.white24),
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
      ),
    );
  }

  Widget _buildLoginButton() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _isLoading ? null : _handleLogin,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(colors: _isLoading ? [Colors.grey, Colors.grey] : [Colors.blueAccent, const Color(0xFF0055FF)]),
            boxShadow: [if (!_isLoading) BoxShadow(color: Colors.blueAccent.withOpacity(0.6), blurRadius: 20, spreadRadius: 2)],
            border: Border.all(color: Colors.white, width: 1),
          ),
          child: Center(
            child: _isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text('ACESSAR SISTEMA', style: GoogleFonts.orbitron(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 3)),
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundCube(Color color) {
    return Stack(
      children: [
        _miniCubeFace(const Offset(0, 0), 30, color),
        _miniCubeFace(const Offset(0, 0), -30, color),
        Transform(transform: Matrix4.identity()..rotateY(math.pi / 2)..translate(0.0, 0.0, 30.0), child: _miniCubeFace(Offset.zero, 0, color)),
        Transform(transform: Matrix4.identity()..rotateY(-math.pi / 2)..translate(0.0, 0.0, 30.0), child: _miniCubeFace(Offset.zero, 0, color)),
        Transform(transform: Matrix4.identity()..rotateX(math.pi / 2)..translate(0.0, 0.0, 30.0), child: _miniCubeFace(Offset.zero, 0, color)),
        Transform(transform: Matrix4.identity()..rotateX(-math.pi / 2)..translate(0.0, 0.0, 30.0), child: _miniCubeFace(Offset.zero, 0, color)),
      ],
    );
  }

  Widget _miniCubeFace(Offset offset, double z, Color color) {
    return Transform(
      transform: Matrix4.identity()..translate(offset.dx, offset.dy, z),
      alignment: Alignment.center,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(color: color.withOpacity(0.2), border: Border.all(color: color.withOpacity(0.9), width: 1.5), boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10)]),
      ),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with SingleTickerProviderStateMixin {
  final _userController = TextEditingController();
  final _altEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('As senhas não coincidem!'), backgroundColor: Colors.red));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final userEmail = _userController.text.trim().contains('@') ? _userController.text.trim() : '${_userController.text.trim()}@terlinet.com';
      final url = Uri.parse('https://tertulianoshow-terlinet-backend.hf.space/signup');
      final response = await http.post(url, headers: {'Content-Type': 'application/json'}, body: json.encode({'email': userEmail, 'alternative_email': _altEmailController.text.trim(), 'password': _passwordController.text}));
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF050505),
              shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.greenAccent, width: 1), borderRadius: BorderRadius.circular(15)),
              title: Text('Sucesso!', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 16)),
              content: Text('Usuário $userEmail cadastrado com sucesso!', style: const TextStyle(color: Colors.white70)),
              actions: [TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: Text('IR PARA LOGIN', style: GoogleFonts.orbitron(color: Colors.greenAccent)))],
            ),
          );
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Falha ao cadastrar');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro no cadastro: $e'), backgroundColor: Colors.orange));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: Stack(
        children: [
          ...List.generate(5, (index) {
            return AnimatedBuilder(
              animation: _rotationController,
              builder: (context, child) {
                final size = MediaQuery.of(context).size;
                final x = (math.cos(_rotationController.value * 2 * math.pi + index) * 0.4 + 0.5) * size.width;
                final y = (math.sin(_rotationController.value * 2 * math.pi + index * 2) * 0.4 + 0.5) * size.height;
                return Positioned(left: x - 40, top: y - 40, child: IgnorePointer(child: Opacity(opacity: 0.15, child: Transform(transform: Matrix4.identity()..setEntry(3, 2, 0.002)..rotateX(_rotationController.value * 2 * math.pi)..rotateY(_rotationController.value * 2 * math.pi + index), alignment: Alignment.center, child: _buildBackgroundCube(index.isEven ? Colors.greenAccent : Colors.cyanAccent)))));
              },
            );
          }),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.8), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.cyanAccent.withOpacity(0.3), width: 1.5), boxShadow: [BoxShadow(color: Colors.cyanAccent.withOpacity(0.1), blurRadius: 30, spreadRadius: 5)]),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('CADASTRO', style: GoogleFonts.orbitron(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2)),
                    const SizedBox(height: 40),
                    _buildTextField(controller: _userController, label: 'NOVO USUÁRIO', icon: Icons.person_add_alt_1_outlined, suffix: '@terlinet.com'),
                    const SizedBox(height: 20),
                    _buildTextField(controller: _altEmailController, label: 'E-MAIL DE RECUPERAÇÃO', icon: Icons.alternate_email, hint: 'Para recuperar sua senha'),
                    const SizedBox(height: 20),
                    _buildTextField(controller: _passwordController, label: 'SENHA', icon: Icons.lock_outline, isPassword: true),
                    const SizedBox(height: 20),
                    _buildTextField(controller: _confirmPasswordController, label: 'CONFIRME A SENHA', icon: Icons.lock_reset, isPassword: true),
                    const SizedBox(height: 40),
                    _buildSignUpButton(),
                  ],
                ),
              ),
            ),
          ),
          Positioned(top: 40, left: 20, child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context))),
        ],
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, bool isPassword = false, String? suffix, String? hint}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.cyanAccent, size: 20),
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 10),
        suffixText: suffix,
        suffixStyle: const TextStyle(color: Colors.white24),
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _isLoading ? null : _handleSignUp,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), gradient: LinearGradient(colors: _isLoading ? [Colors.grey, Colors.grey] : [const Color(0xFF00FF88), const Color(0xFF00AAFF)]), boxShadow: [if (!_isLoading) BoxShadow(color: const Color(0xFF00FF88).withOpacity(0.3), blurRadius: 15, spreadRadius: 1)], border: Border.all(color: Colors.white24, width: 0.5)),
          child: Center(child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text('CRIAR CONTA', style: GoogleFonts.orbitron(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2))),
        ),
      ),
    );
  }

  Widget _buildBackgroundCube(Color color) {
    return Stack(
      children: [
        _miniCubeFace(const Offset(0, 0), 30, color),
        _miniCubeFace(const Offset(0, 0), -30, color),
        Transform(transform: Matrix4.identity()..rotateY(math.pi / 2)..translate(0.0, 0.0, 30.0), child: _miniCubeFace(Offset.zero, 0, color)),
        Transform(transform: Matrix4.identity()..rotateY(-math.pi / 2)..translate(0.0, 0.0, 30.0), child: _miniCubeFace(Offset.zero, 0, color)),
      ],
    );
  }

  Widget _miniCubeFace(Offset offset, double z, Color color) {
    return Transform(
      transform: Matrix4.identity()..translate(offset.dx, offset.dy, z),
      alignment: Alignment.center,
      child: Container(width: 60, height: 60, decoration: BoxDecoration(color: color.withOpacity(0.05), border: Border.all(color: color.withOpacity(0.4), width: 1))),
    );
  }
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleRecovery() async {
    setState(() => _isLoading = true);
    try {
      final url = Uri.parse('https://tertulianoshow-terlinet-backend.hf.space/recover');
      await http.post(url, headers: {'Content-Type': 'application/json'}, body: json.encode({'identifier': _emailController.text.trim()}));
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF050505),
            shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.blueAccent, width: 1), borderRadius: BorderRadius.circular(15)),
            title: Text('RECUPERAÇÃO', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 16)),
            content: const Text('Se este usuário existir, as instruções de recuperação foram enviadas.', style: TextStyle(color: Colors.white70)),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('OK', style: GoogleFonts.orbitron(color: Colors.blueAccent)))],
          ),
        );
      }
    } catch (e) {
      print("ERRO NA RECUPERAÇÃO: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(40),
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.8), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.blueAccent.withOpacity(0.3))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_reset, size: 60, color: Colors.blueAccent),
              const SizedBox(height: 20),
              Text('RECUPERAR ACESSO', style: GoogleFonts.orbitron(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 30),
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'SEU USUÁRIO OU E-MAIL', labelStyle: TextStyle(color: Colors.white54, fontSize: 12), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent))),
              ),
              const SizedBox(height: 40),
              _buildRecoveryButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecoveryButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _handleRecovery,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), gradient: const LinearGradient(colors: [Colors.blueAccent, Color(0xFF0055FF)])),
        child: Center(child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text('ENVIAR INSTRUÇÕES', style: GoogleFonts.orbitron(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold))),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _walletAddress = "";
  bool _isConnected = false;
  bool _isConnecting = false;

  Future<void> _connectWallet() async {
    setState(() => _isConnecting = true);
    jsLog("Iniciando busca por provedores de carteira...");

    try {
      final hasEth = hasProperty(window, 'ethereum');

      if (!hasEth) {
        jsLog("Nenhum provedor ethereum encontrado no window.");
        _showError('Carteira não detectada! Verifique se a MetaMask está instalada.');
        return;
      }

      var eth = getProperty(window, 'ethereum');

      // Lógica para lidar com múltiplos provedores (ex: MetaMask + TronLink)
      if (hasProperty(eth, 'providers')) {
        jsLog("Múltiplos provedores detectados. Procurando MetaMask...");
        final List providers = getProperty(eth, 'providers');
        eth = providers.firstWhere(
          (p) => hasProperty(p, 'isMetaMask') && getProperty(p, 'isMetaMask') == true,
          orElse: () => providers.first,
        );
      }

      jsLog("Solicitando contas à carteira selecionada...");

      // Solicita acesso às contas via requestAccounts com timeout
      final dynamic response = await promiseToFuture(
        callMethod(eth, 'request', [
          jsify({'method': 'eth_requestAccounts'})
        ]),
      ).timeout(const Duration(seconds: 30));

      final List accounts = response as List;

      if (accounts.isNotEmpty) {
        jsLog("Conexão bem sucedida: " + accounts[0].toString());
        setState(() {
          _walletAddress = accounts[0];
          _isConnected = true;
        });
        _showSuccess('Carteira conectada!');
      }
    } catch (e) {
      jsLog("Falha na conexão Web3: " + e.toString());
      _showError('Erro ao conectar: Verifique se há notificações pendentes na sua carteira.');
    } finally {
      if (mounted) {
        setState(() => _isConnecting = false);
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.orange),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: Row(
        children: [
          Container(
            width: 80,
            color: Colors.black,
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Icon(Icons.shield_outlined, color: Colors.blueAccent, size: 30),
                const Spacer(),
                _buildSidebarIcon(Icons.dashboard_customize_outlined, true),
                _buildSidebarIcon(Icons.account_balance_wallet_outlined, false),
                _buildSidebarIcon(Icons.message_outlined, false),
                _buildSidebarIcon(Icons.settings_outlined, false),
                const Spacer(),
                IconButton(icon: const Icon(Icons.logout, color: Colors.redAccent), onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const InitialScreen()))),
                const SizedBox(height: 20),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(gradient: RadialGradient(center: Alignment.topLeft, radius: 1.5, colors: [Colors.blueAccent.withOpacity(0.05), Colors.transparent])),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('SISTEMA DE GERENCIAMENTO IT', style: GoogleFonts.orbitron(fontSize: 12, color: Colors.blueAccent, letterSpacing: 2)),
                          const SizedBox(height: 10),
                          Text('Olá, Administrador', style: GoogleFonts.orbitron(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                      GestureDetector(
                        onTap: (_isConnected || _isConnecting) ? null : _connectWallet,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                                color: _isConnected
                                    ? Colors.greenAccent
                                    : Colors.blueAccent.withOpacity(0.5)),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.blueAccent.withOpacity(0.1),
                                  blurRadius: 10)
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                  _isConnected
                                      ? Icons.verified_user
                                      : Icons.account_balance_wallet_outlined,
                                  color: _isConnected
                                      ? Colors.greenAccent
                                      : Colors.cyanAccent,
                                  size: 18),
                              const SizedBox(width: 10),
                              Text(
                                _isConnected
                                    ? "terlinet.blockchain"
                                    : (_isConnecting
                                        ? "PROCESSANDO..."
                                        : 'CONECTAR CARTEIRA'),
                                style: GoogleFonts.orbitron(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_isConnected)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text("Wallet: ${_walletAddress.substring(0, 6)}...${_walletAddress.substring(_walletAddress.length - 4)}", style: const TextStyle(color: Colors.white54, fontSize: 10)),
                    ),
                  const SizedBox(height: 50),
                  // Grid de Status interativo
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 3,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      children: [
                        _buildStatusCard('SERVIDORES', 'ONLINE', Icons.dns, Colors.greenAccent),
                        _buildStatusCard('TRÁFEGO REDE', 'ESTÁVEL', Icons.speed, Colors.blueAccent),
                        _buildStatusCard('SEGURANÇA', 'PROTEGIDO', Icons.lock, Colors.cyanAccent),
                        _buildClickableStatusCard(
                          'CAIXA WEB3',
                          _isConnected ? 'ABRIR INBOX' : 'CONECTE WALLET',
                          Icons.mail_outline,
                          Colors.purpleAccent,
                          () => _showXMTPInbox(context),
                        ),
                        _buildStatusCard('UPTIME', '99.9%', Icons.timer_outlined, Colors.orangeAccent),
                        _buildStatusCard('USUÁRIOS', 'VER TODOS', Icons.people_outline, Colors.white60),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showXMTPInbox(BuildContext context) {
    if (!_isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Conecte sua carteira primeiro!')));
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0A0A0A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('CENTRAL XMTP - terlinet.blockchain', style: GoogleFonts.orbitron(color: Colors.purpleAccent, fontSize: 18)),
                IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const Divider(color: Colors.white10, height: 40),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_person_outlined, size: 60, color: Colors.white24),
                    const SizedBox(height: 20),
                    const Text('Sincronizando com a rede descentralizada...', style: TextStyle(color: Colors.white54)),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent),
                      onPressed: () {
                        // Aqui entrará a inicialização do cliente XMTP real
                      },
                      child: const Text('ATIVAR PROTOCOLO XMTP'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClickableStatusCard(String title, String value, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: _buildStatusCard(title, value, icon, color),
      ),
    );
  }

  Widget _buildSidebarIcon(IconData icon, bool selected) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: Icon(icon, color: selected ? Colors.blueAccent : Colors.white24, size: 28));
  }

  Widget _buildStatusCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.2))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 40),
          const SizedBox(height: 20),
          Text(title, style: GoogleFonts.orbitron(fontSize: 10, color: Colors.white54, letterSpacing: 1)),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.orbitron(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
