import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:vocalipt_v2/Highlights/manage_highlights_dialog.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vocalipt',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const SpeechScreen(),
    );
  }
}

class SpeechScreen extends StatefulWidget {
  const SpeechScreen({Key? key}) : super(key: key);

  @override
  State<SpeechScreen> createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  final List<String> _baseWords = ['flutter', 'code'];
  late Map<String, HighlightedWord> _highlights;

  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = '';
  double _confidence = 1.0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initHighlights();
  }

  void _initHighlights() {
    _highlights = {};
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.pink,
      Colors.cyan,
    ];

    for (int i = 0; i < _baseWords.length; i++) {
      final word = _baseWords[i];
      final color = colors[i % colors.length];

      _highlights[word.toLowerCase()] = HighlightedWord(
        onTap: () => _showHighlightInfo(word),
        textStyle: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
          decorationColor: color.withOpacity(0.4),
        ),
      );
    }
  }

  void _showHighlightInfo(String word) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keyword: $word',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'This word is highlighted dynamically. You can link any action or feature to it.',
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }

  void _showManageHighlightsDialog() {
    showDialog(
      context: context,
      builder:
          (context) => ManageHighlightsDialog(
            baseWords: _baseWords,
            onWordAdded: (newWord) {
              setState(() {
                _baseWords.add(newWord.toLowerCase());
                _initHighlights();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Word "$newWord" added successfully!')),
              );
            },
            onWordDeleted: (deletedWord) {
              setState(() {
                _baseWords.remove(deletedWord);
                _initHighlights();
              });
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vocalipt',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'Manage Highlights',
            onPressed: _showManageHighlightsDialog,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: _isListening,
        glowColor: colorScheme.primary,
        glowRadiusFactor: 0.3,
        duration: const Duration(milliseconds: 1800),
        repeat: true,
        child: FloatingActionButton.large(
          onPressed: _listen,
          backgroundColor:
              _isListening
                  ? colorScheme.errorContainer
                  : colorScheme.primaryContainer,
          foregroundColor:
              _isListening
                  ? colorScheme.onErrorContainer
                  : colorScheme.onPrimaryContainer,
          child: Icon(_isListening ? Icons.mic : Icons.mic_none),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_text.isNotEmpty) _buildActionBar(colorScheme),
            Expanded(
              child: Card(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 140),
                elevation: 0,
                color: colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SingleChildScrollView(
                    reverse: false,
                    physics: const BouncingScrollPhysics(),
                    child:
                        _text.isEmpty
                            ? _buildEmptyState(colorScheme)
                            : Align(
                              alignment: Alignment.topLeft,
                              child: TextHighlight(
                                text: _text,
                                words: _highlights,
                                textStyle: TextStyle(
                                  fontSize: 24.0,
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w400,
                                  height: 1.4,
                                ),
                              ),
                            ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBar(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InputChip(
            avatar: Icon(Icons.done, size: 16, color: colorScheme.primary),
            label: Text('Accuracy: ${(_confidence * 100).toStringAsFixed(0)}%'),
            onPressed: () {},
          ),
          Row(
            children: [
              IconButton.filledTonal(
                icon: const Icon(Icons.copy_all_outlined, size: 20),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _text));
                  HapticFeedback.mediumImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Text copied to clipboard')),
                  );
                },
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                icon: const Icon(Icons.delete_sweep_outlined, size: 20),
                color: colorScheme.error,
                onPressed: () {
                  setState(() {
                    _text = '';
                    _confidence = 1.0;
                  });
                  HapticFeedback.lightImpact();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mic_none,
              size: 72,
              color: colorScheme.primary.withOpacity(0.2),
            ),
            const SizedBox(height: 16),
            Text(
              'Ready to Record',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Press the button below and start speaking.\nMatched keywords will highlight automatically.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'notListening') setState(() => _isListening = false);
        },
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        HapticFeedback.heavyImpact();
        setState(() => _isListening = true);
        _speech.listen(
          localeId: 'en_US',
          onResult:
              (val) => setState(() {
                _text = val.recognizedWords;
                if (val.hasConfidenceRating && val.confidence > 0) {
                  _confidence = val.confidence;
                }
              }),
        );
      }
    } else {
      HapticFeedback.mediumImpact();
      setState(() => _isListening = false);
      _speech.stop();
    }
  }
}
