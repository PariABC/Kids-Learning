import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const PariKidsApp());
}

class PariKidsApp extends StatelessWidget {
  const PariKidsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pari Kids - Pari ABC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFFF9C4), // Light Cream Yellow
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class ClassCardModel {
  final String title;
  final String subtitle;
  final String ageGroup;
  final Color cardColor;
  final Color accentColor;
  final String lottieAsset;
  final String audioAsset;

  const ClassCardModel({
    required this.title,
    required this.subtitle,
    required this.ageGroup,
    required this.cardColor,
    required this.accentColor,
    required this.lottieAsset,
    required this.audioAsset,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  final List<ClassCardModel> _classes = const [
    ClassCardModel(
      title: 'NURSERY',
      subtitle: 'ICSE Foundation',
      ageGroup: 'Age 3-4 Years',
      cardColor: Color(0xFFFFEB3B), // Bright Yellow
      accentColor: Color(0xFFF57F17),
      lottieAsset: 'assets/animations/apple_jump.json',
      audioAsset: 'audio/lets_go_nursery.mp3',
    ),
    ClassCardModel(
      title: 'LKG',
      subtitle: 'ICSE Early Steps',
      ageGroup: 'Age 4-5 Years',
      cardColor: Color(0xFF81C784), // Fresh Green
      accentColor: Color(0xFF1B5E20),
      lottieAsset: 'assets/animations/ball_bounce.json',
      audioAsset: 'audio/lets_go_lkg.mp3',
    ),
    ClassCardModel(
      title: 'UKG',
      subtitle: 'ICSE Advanced Prep',
      ageGroup: 'Age 5-6 Years',
      cardColor: Color(0xFF64B5F6), // Sky Blue
      accentColor: Color(0xFF0D47A1),
      lottieAsset: 'assets/animations/lion_walk.json',
      audioAsset: 'audio/lets_go_ukg.mp3',
    ),
  ];

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _handleClassTap(ClassCardModel classItem) async {
    // Play offline voice cue
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(classItem.audioAsset));
    } catch (_) {
      // Fails gracefully if audio asset is not yet placed in assets/audio/
    }

    if (!mounted) return;

    // Navigate to the selected Class Page
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: ClassDetailPage(classModel: classItem),
        ),
      ),
    );
  }

  void _openParentGate() {
    showDialog(
      context: context,
      builder: (context) => const ParentGateDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 650;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9C4),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 40.0 : 22.0,
                vertical: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 1. TOP APP LOGO HEADER
                  _buildHeaderLogo(isTablet),
                  const SizedBox(height: 24),

                  // 2. TOP HERO MASCOT SECTION (Pari, Elephant & Lion)
                  _buildHeroMascotSection(isTablet),
                  const SizedBox(height: 32),

                  // 3. MIDDLE SECTION: 3 BIG CLASS CARDS
                  isTablet
                      ? Row(
                          children: _classes
                              .map(
                                (item) => Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child: BouncyClassCard(
                                      model: item,
                                      isTablet: true,
                                      onTap: () => _handleClassTap(item),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        )
                      : Column(
                          children: _classes
                              .map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 20.0),
                                  child: BouncyClassCard(
                                    model: item,
                                    isTablet: false,
                                    onTap: () => _handleClassTap(item),
                                  ),
                                ),
                              )
                              .toList(),
                        ),

                  const SizedBox(height: 28),

                  // 4. BOTTOM SECTION: RHYMES & FOR PARENTS BUTTONS
                  _buildBottomButtons(isTablet),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderLogo(bool isTablet) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.18),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome, color: Color(0xFFFF8F00), size: 28),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              'Pari Kids - Pari ABC',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: isTablet ? 30 : 22,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2E294E),
                letterSpacing: 0.4,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.auto_awesome, color: Color(0xFFFF8F00), size: 28),
        ],
      ),
    );
  }

  Widget _buildHeroMascotSection(bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 32 : 18,
        vertical: isTablet ? 24 : 18,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Mascot Animation Row: Pari (Fairy) + Elephant + Lion
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Small Smiling Elephant
              _SafeLottieWidget(
                assetPath: 'assets/animations/elephant.json',
                width: isTablet ? 105 : 70,
                height: isTablet ? 105 : 70,
                fallbackIcon: Icons.pets,
                fallbackColor: Colors.blueGrey,
              ),
              const SizedBox(width: 8),

              // Main Flying Fairy (Pari) Waving Hand
              _SafeLottieWidget(
                assetPath: 'assets/animations/fairy.json',
                width: isTablet ? 155 : 115,
                height: isTablet ? 155 : 115,
                fallbackIcon: Icons.face_retouching_natural,
                fallbackColor: Colors.pinkAccent,
              ),
              const SizedBox(width: 8),

              // Small Smiling Lion
              _SafeLottieWidget(
                assetPath: 'assets/animations/lion_smile.json',
                width: isTablet ? 105 : 70,
                height: isTablet ? 105 : 70,
                fallbackIcon: Icons.emoji_nature,
                fallbackColor: Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Greeting Text
          Text(
            "Hello Kids! Let's Learn Together",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: isTablet ? 26 : 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E2749),
            ),
          ),
          const SizedBox(height: 4),

          // Sub-text
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9C4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Learn, Play & Grow',
              style: GoogleFonts.poppins(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFE65100),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(bool isTablet) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 20,
      runSpacing: 14,
      children: [
        _BottomPillButton(
          label: 'Rhymes',
          icon: Icons.music_note_rounded,
          backgroundColor: const Color(0xFFFF7043),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RhymesPage()),
            );
          },
        ),
        _BottomPillButton(
          label: 'For Parents',
          icon: Icons.lock_rounded,
          backgroundColor: const Color(0xFF5C6BC0),
          onTap: _openParentGate,
        ),
      ],
    );
  }
}

/// Interactive Card with Smooth Spring Bounce Animation on Tap
class BouncyClassCard extends StatefulWidget {
  final ClassCardModel model;
  final bool isTablet;
  final VoidCallback onTap;

  const BouncyClassCard({
    super.key,
    required this.model,
    required this.isTablet,
    required this.onTap,
  });

  @override
  State<BouncyClassCard> createState() => _BouncyClassCardState();
}

class _BouncyClassCardState extends State<BouncyClassCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      reverseDuration: const Duration(milliseconds: 220),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _triggerBounceAndNavigate() async {
    HapticFeedback.lightImpact();
    await _controller.forward();
    await _controller.reverse();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapCancel: () => _controller.reverse(),
      onTap: _triggerBounceAndNavigate,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          height: widget.isTablet ? 270 : 148,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: widget.model.cardColor,
            borderRadius: BorderRadius.circular(20), // Exact 20px rounded corners
            border: Border.all(
              color: Colors.white.withOpacity(0.75),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: widget.isTablet
              ? _buildTabletCardContent()
              : _buildMobileCardContent(),
        ),
      ),
    );
  }

  Widget _buildMobileCardContent() {
    return Row(
      children: [
        // Left Lottie Animation Container
        Container(
          width: 105,
          height: 105,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.65),
            borderRadius: BorderRadius.circular(18),
          ),
          child: _SafeLottieWidget(
            assetPath: widget.model.lottieAsset,
            width: 90,
            height: 90,
            fallbackIcon: Icons.star_rounded,
            fallbackColor: widget.model.accentColor,
          ),
        ),
        const SizedBox(width: 20),

        // Right Text Info
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.model.title,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1A2E),
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.model.ageGroup,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: widget.model.accentColor,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Play Arrow Indicator
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.play_arrow_rounded,
            color: widget.model.accentColor,
            size: 28,
          ),
        ),
      ],
    );
  }

  Widget _buildTabletCardContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.65),
            shape: BoxShape.circle,
          ),
          child: _SafeLottieWidget(
            assetPath: widget.model.lottieAsset,
            width: 100,
            height: 100,
            fallbackIcon: Icons.star_rounded,
            fallbackColor: widget.model.accentColor,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.model.title,
          style: GoogleFonts.poppins(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            widget.model.ageGroup,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: widget.model.accentColor,
            ),
          ),
        ),
      ],
    );
  }
}

/// Bottom Pill Buttons ("Rhymes" & "For Parents")
class _BottomPillButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final VoidCallback onTap;

  const _BottomPillButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  State<_BottomPillButton> createState() => _BottomPillButtonState();
}

class _BottomPillButtonState extends State<_BottomPillButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.93),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.backgroundColor.withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Safely loads offline Lottie JSON files with a fallback icon if missing during setup
class _SafeLottieWidget extends StatelessWidget {
  final String assetPath;
  final double width;
  final double height;
  final IconData fallbackIcon;
  final Color fallbackColor;

  const _SafeLottieWidget({
    required this.assetPath,
    required this.width,
    required this.height,
    required this.fallbackIcon,
    required this.fallbackColor,
  });

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      assetPath,
      width: width,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          fallbackIcon,
          size: width * 0.65,
          color: fallbackColor,
        );
      },
    );
  }
}

/// Destination Class Page (ICSE Advanced Syllabus Modules)
class ClassDetailPage extends StatelessWidget {
  final ClassCardModel classModel;

  const ClassDetailPage({super.key, required this.classModel});

  @override
  Widget build(BuildContext context) {
    final subjects = [
      {'title': 'English Phonics & ABC', 'icon': Icons.abc_rounded},
      {'title': 'Numbers & Early Math', 'icon': Icons.calculate_rounded},
      {'title': 'Environmental Science', 'icon': Icons.eco_rounded},
      {'title': 'Stories & Vocabulary', 'icon': Icons.menu_book_rounded},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9C4),
      appBar: AppBar(
        backgroundColor: classModel.cardColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: Color(0xFF1A1A2E), size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${classModel.title} (${classModel.ageGroup})',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A1A2E),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ICSE Board - Advanced Syllabus',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2E294E),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                itemCount: subjects.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 340,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.5,
                ),
                itemBuilder: (context, index) {
                  final subject = subjects[index];
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          subject['icon'] as IconData,
                          size: 44,
                          color: classModel.accentColor,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          subject['title'] as String,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A1A2E),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rhymes Page Placeholder
class RhymesPage extends StatelessWidget {
  const RhymesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9C4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF7043),
        foregroundColor: Colors.white,
        title: Text(
          'English Rhymes',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
      ),
      body: Center(
        child: Text(
          'Offline English Rhymes Player',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2E294E),
          ),
        ),
      ),
    );
  }
}

/// Kid-Safe Parental Gate Dialog (Prevents toddlers from opening Parent settings)
class ParentGateDialog extends StatefulWidget {
  const ParentGateDialog({super.key});

  @override
  State<ParentGateDialog> createState() => _ParentGateDialogState();
}

class _ParentGateDialogState extends State<ParentGateDialog> {
  final TextEditingController _answerController = TextEditingController();
  String _errorText = '';

  void _verifyAnswer() {
    if (_answerController.text.trim() == '21') {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Parent Dashboard Unlocked'),
          backgroundColor: Color(0xFF5C6BC0),
        ),
      );
    } else {
      setState(() {
        _errorText = 'Please enter the correct answer.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'For Parents Only',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'To continue, please solve: 14 + 7 = ?',
            style: GoogleFonts.poppins(fontSize: 15),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _answerController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter answer',
              errorText: _errorText.isEmpty ? null : _errorText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _verifyAnswer,
          child: const Text('Unlock'),
        ),
      ],
    );
  }
}
