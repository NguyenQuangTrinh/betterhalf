import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';

enum GameDifficulty { easy, medium, hard, superHard }

enum GameType { memory, onet }

class PokemonMemoryGamePage extends StatefulWidget {
  const PokemonMemoryGamePage({super.key});

  @override
  State<PokemonMemoryGamePage> createState() => _PokemonMemoryGamePageState();
}

class CardModel {
  final int id;
  final String imageUrl;
  bool isFaceUp;
  bool isMatched;
  bool isVisible;

  CardModel({
    required this.id,
    required this.imageUrl,
    this.isFaceUp = false,
    this.isMatched = false,
    this.isVisible = true,
  });
}

class _PokemonMemoryGamePageState extends State<PokemonMemoryGamePage> {
  final List<int> _pokemonIds = [
    1, 4, 7, 25, 39, 52, 54, 133, // 8 Basic
    150, 151, 143, 94, 65, 35, // +6
    6, 9, 3, 12, // +4
    24, 59, 68, 130, 149, 58,
    // New additions for Extreme Difficulty
    11, 15, 18, 28, 31, 34, 37, 42, 45, 50,
    60, 63, 74, 81, 86, 92, 98, 104, 115, 120,
    125, 123, 137, 140, // 24 more IDs (Total 48+)
  ];

  List<CardModel> _cards = [];
  int _score = 0;
  int _moves = 0;
  CardModel? _firstFlippedCard;
  bool _isProcessing = false;
  bool _isPaused = false;

  bool _isPlaying = false;
  GameDifficulty? _currentDifficulty;
  GameType? _selectedGameType;
  List<Point<int>> _onetPath = []; // Indices of path for line drawing
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    // Allow landscape for this game
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Timer? _gameTimer;
  int _remainingSeconds = 0;
  int _maxSeconds = 0;

  @override
  void dispose() {
    _gameTimer?.cancel();
    _hintTimer?.cancel();
    // Revert to portrait only when exiting
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _audioPlayer.dispose();
    super.dispose();
  }

  void _selectGameType(GameType type) {
    setState(() {
      _selectedGameType = type;
    });
  }

  void _backToGameSelection() {
    setState(() {
      _selectedGameType = null;
      _currentDifficulty = null;
    });
  }

  void _startGame(GameDifficulty difficulty) {
    int pairCount;
    switch (difficulty) {
      case GameDifficulty.easy:
        pairCount = 8; // 4x4
        break;
      case GameDifficulty.medium:
        pairCount = 12; // 6x4
        break;
      case GameDifficulty.hard:
        pairCount = 18; // 6x6
        break;
      case GameDifficulty.superHard:
        pairCount = 40; // ~ 80 cards
        break;
    }

    final availableIds = List<int>.from(_pokemonIds)..shuffle();
    final selectedIds = availableIds.take(pairCount);

    List<CardModel> generatedCards = [];
    for (var id in selectedIds) {
      final imageUrl =
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';
      generatedCards.add(CardModel(id: id, imageUrl: imageUrl));
      generatedCards.add(CardModel(id: id, imageUrl: imageUrl));
    }
    generatedCards.shuffle();

    // For Onet, cards are always face up initially
    if (_selectedGameType == GameType.onet) {
      for (var card in generatedCards) {
        card.isFaceUp = true;
      }
    }

    setState(() {
      _currentDifficulty = difficulty;
      _cards = generatedCards;
      _score = 0;
      _moves = 0;
      _firstFlippedCard = null;
      _isProcessing = false;
      _isPaused = false; // Ensure paused state is cleared
      _isPlaying = true;
      _onetPath = [];
    });

    if (_selectedGameType == GameType.onet) {
      int duration = 300; // 5 mins default
      if (difficulty == GameDifficulty.hard) duration = 180; // 3 mins
      if (difficulty == GameDifficulty.superHard) duration = 120; // 2 mins

      setState(() {
        _remainingSeconds = duration;
        _maxSeconds = duration;
      });
      _startTimer();
    }

    if (difficulty == GameDifficulty.hard ||
        difficulty == GameDifficulty.superHard) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (var card in generatedCards) {
        precacheImage(NetworkImage(card.imageUrl), context);
      }
    });

    _resetHintTimer();
  }

  Timer? _hintTimer;
  List<int> _hintPairIndices = [];

  void _resetHintTimer() {
    _hintTimer?.cancel();
    setState(() {
      _hintPairIndices = [];
    });

    if (_selectedGameType == GameType.onet) {
      _hintTimer = Timer(
        const Duration(seconds: 10),
        _showHint,
      ); // Hint after 10s
    }
  }

  void _showHint() {
    if (!mounted || !_isPlaying || _isPaused) return;

    int cols = _currentCols;

    for (int i = 0; i < _cards.length; i++) {
      if (!_cards[i].isVisible) continue;

      for (int j = i + 1; j < _cards.length; j++) {
        if (!_cards[j].isVisible) continue;
        if (_cards[i].id != _cards[j].id) continue;

        // Check if connectable
        List<Point<int>>? path = _findPath(i, j, cols);
        if (path != null) {
          setState(() {
            _hintPairIndices = [i, j];
          });
          return; // Found a hint
        }
      }
    }
  }

  void _exitGame() {
    setState(() {
      _isPlaying = false;
      _currentDifficulty = null;
      _selectedGameType = null;
      _onetPath = [];
      _gameTimer?.cancel();
      _hintTimer?.cancel();
    });
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void _pauseGame() {
    setState(() {
      _isPaused = true;
      _gameTimer?.cancel();
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Tạm dừng'),
        content: const Text('Trò chơi đang tạm dừng.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _resumeGame();
            },
            child: const Text('Tiếp tục'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (_currentDifficulty != null) {
                _startGame(_currentDifficulty!);
              }
            },
            child: const Text('Chơi lại'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _exitGame();
            },
            child: const Text('Thoát'),
          ),
        ],
      ),
    );
  }

  void _resumeGame() {
    setState(() {
      _isPaused = false;
    });
    if (_selectedGameType == GameType.onet) {
      _startTimer();
    }
  }

  Future<void> _playSound(String fileName) async {
    try {
      // Expects files in assets/audio/
      // e.g. flip.mp3, match.mp3, win.mp3, shuffle.mp3
      await _audioPlayer.play(AssetSource('audio/$fileName'));
    } catch (e) {
      // debugPrint('Error playing sound: $e');
    }
  }

  void _onCardTap(CardModel card) {
    if (_selectedGameType == GameType.onet) {
      _onOnetCardTap(card);
    } else {
      _onMemoryCardTap(card);
    }
  }

  void _onMemoryCardTap(CardModel card) {
    if (_isProcessing || card.isFaceUp || card.isMatched) return;

    setState(() {
      card.isFaceUp = true;
    });

    if (_firstFlippedCard == null) {
      _firstFlippedCard = card;
      _playSound('flip.mp3');
    } else {
      _isProcessing = true;
      _moves++;
      _playSound('flip.mp3');

      if (_firstFlippedCard!.id == card.id) {
        // Match
        setState(() {
          _firstFlippedCard!.isMatched = true;
          card.isMatched = true;
          _firstFlippedCard = null;
          _isProcessing = false;
          _score += 10;
        });
        _playSound('match.mp3');
        _checkWin();
      } else {
        // No Match
        Timer(const Duration(milliseconds: 1000), () {
          if (mounted) {
            setState(() {
              _firstFlippedCard!.isFaceUp = false;
              card.isFaceUp = false;
              _firstFlippedCard = null;
              _isProcessing = false;
            });
          }
        });
      }
    }
  }

  int _currentCols = 4;

  void _onOnetCardTap(CardModel card) {
    if (!card.isVisible || _isProcessing || _isPaused) return;
    _resetHintTimer();

    // Play flip sound on any valid interaction
    _playSound('flip.mp3');

    int index = _cards.indexOf(card);

    if (_firstFlippedCard == null) {
      if (!card.isMatched) {
        // Select
        setState(() {
          _firstFlippedCard = card;
          card.isMatched = true; // Highlight
        });
      }
    } else if (_firstFlippedCard == card) {
      // Deselect
      setState(() {
        card.isMatched = false;
        _firstFlippedCard = null;
      });
    } else {
      if (_firstFlippedCard!.id == card.id) {
        int index1 = _cards.indexOf(_firstFlippedCard!);
        int cols = _currentCols;

        List<Point<int>>? path = _findPath(index1, index, cols);

        if (path != null) {
          setState(() {
            _onetPath = path;
            _isProcessing = true;
          });

          Timer(const Duration(milliseconds: 300), () {
            if (mounted) {
              setState(() {
                _firstFlippedCard!.isVisible = false;
                card.isVisible = false;
                _firstFlippedCard!.isMatched = false;
                _firstFlippedCard = null;
                _onetPath = [];
                _isProcessing = false;
                _score += 10;
              });
              _playSound('match.mp3');
              _checkWin();
              _checkDeadlockAndShuffle();
            }
          });
        } else {
          // Blocked or No Path
          setState(() {
            _firstFlippedCard!.isMatched = false;
            _firstFlippedCard = null;
          });
        }
      } else {
        // Wrong match
        setState(() {
          _firstFlippedCard!.isMatched = false;
          _firstFlippedCard = null;
        });
      }
    }
  }

  void _checkDeadlockAndShuffle() {
    // Small delay to let the UI update (card hide) first
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted || !_isPlaying || _selectedGameType != GameType.onet) return;

      // If no visible cards left, it's a win, so don't shuffle
      if (!_cards.any((c) => c.isVisible)) return;

      if (!_hasAvailableMoves()) {
        _shuffleRemainingCards();
      }
    });
  }

  bool _hasAvailableMoves() {
    int cols = _currentCols;
    for (int i = 0; i < _cards.length; i++) {
      if (!_cards[i].isVisible) continue;
      for (int j = i + 1; j < _cards.length; j++) {
        if (!_cards[j].isVisible) continue;
        if (_cards[i].id != _cards[j].id) continue;

        if (_findPath(i, j, cols) != null) return true;
      }
    }
    return false;
  }

  void _shuffleRemainingCards() {
    if (!mounted) return;

    _playSound('shuffle.mp3');

    setState(() {
      // 1. Get visible indices
      List<int> visibleIndices = [];
      List<CardModel> visibleCards = [];

      for (int i = 0; i < _cards.length; i++) {
        if (_cards[i].isVisible) {
          visibleIndices.add(i);
          visibleCards.add(_cards[i]);
        }
      }

      // 2. Shuffle the card models
      visibleCards.shuffle();

      // 3. Put them back
      for (int i = 0; i < visibleIndices.length; i++) {
        int index = visibleIndices[i];
        _cards[index] = visibleCards[i];
      }

      // Reset hint
      _hintPairIndices = [];
    });

    // Recursive check in case new shuffle is also deadlocked (rare but possible)
    _checkDeadlockAndShuffle();
  }

  // BFS / Pathfinding with Border Support
  List<Point<int>>? _findPath(int index1, int index2, int cols) {
    int rows = (_cards.length / cols).ceil();
    Point<int> p1 = Point(index1 % cols, index1 ~/ cols);
    Point<int> p2 = Point(index2 % cols, index2 ~/ cols);

    if (p1 == p2) return null;

    // 0 turns
    var path = _checkLine(p1, p2, rows, cols, p2);
    if (path != null) return path;

    // 1 turn
    Point<int> c1 = Point(p1.x, p2.y);
    if (_isWalkable(c1, rows, cols)) {
      var s1 = _checkLine(p1, c1, rows, cols, p2);
      var s2 = _checkLine(c1, p2, rows, cols, p2);
      if (s1 != null && s2 != null) return [...s1, ...s2.skip(1)];
    }

    Point<int> c2 = Point(p2.x, p1.y);
    if (_isWalkable(c2, rows, cols)) {
      var s1 = _checkLine(p1, c2, rows, cols, p2);
      var s2 = _checkLine(c2, p2, rows, cols, p2);
      if (s1 != null && s2 != null) return [...s1, ...s2.skip(1)];
    }

    // 2 turns - Horizontal Scan (Y axis)
    for (int r = -1; r <= rows; r++) {
      Point<int> a = Point(p1.x, r);
      Point<int> b = Point(p2.x, r);

      var s1 = _checkLine(p1, a, rows, cols, p2);
      if (s1 == null) continue;

      var s2 = _checkLine(a, b, rows, cols, p2);
      if (s2 == null) continue;

      var s3 = _checkLine(b, p2, rows, cols, p2);
      if (s3 == null) continue;

      return [...s1, ...s2.skip(1), ...s3.skip(1)];
    }

    // 2 turns - Vertical Scan (X axis)
    for (int c = -1; c <= cols; c++) {
      Point<int> a = Point(c, p1.y);
      Point<int> b = Point(c, p2.y);

      var s1 = _checkLine(p1, a, rows, cols, p2);
      if (s1 == null) continue;

      var s2 = _checkLine(a, b, rows, cols, p2);
      if (s2 == null) continue;

      var s3 = _checkLine(b, p2, rows, cols, p2);
      if (s3 == null) continue;

      return [...s1, ...s2.skip(1), ...s3.skip(1)];
    }

    return null;
  }

  List<Point<int>>? _checkLine(
    Point<int> a,
    Point<int> b,
    int rows,
    int cols,
    Point<int> target,
  ) {
    if (a.x != b.x && a.y != b.y) return null;
    List<Point<int>> path = [];
    int dx = (b.x - a.x).sign;
    int dy = (b.y - a.y).sign;
    int steps = max((b.x - a.x).abs(), (b.y - a.y).abs());

    for (int i = 0; i <= steps; i++) {
      Point<int> p = Point(a.x + i * dx, a.y + i * dy);
      path.add(p);

      if (p == a) continue; // Start point
      if (p == target) continue; // End point

      if (!_isWalkable(p, rows, cols)) return null;
    }
    return path;
  }

  bool _isWalkable(Point<int> p, int rows, int cols) {
    if (p.x < 0 || p.x >= cols || p.y < 0 || p.y >= rows) return true;
    int index = p.y * cols + p.x;
    if (index < 0 || index >= _cards.length) return true;
    return !_cards[index].isVisible;
  }

  void _checkWin() {
    bool allCleared;
    if (_selectedGameType == GameType.onet) {
      allCleared = _cards.every((c) => !c.isVisible);
    } else {
      allCleared = _cards.every((c) => c.isMatched);
    }

    if (allCleared) {
      _gameTimer?.cancel();
      _showWinDialog();
    }
  }

  void _startTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _gameTimer?.cancel();
        _showGameOverDialog();
      }
    });
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Hết giờ!'),
        content: const Text('Bạn đã hết thời gian!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (_currentDifficulty != null) {
                _startGame(_currentDifficulty!);
              }
            },
            child: const Text('Chơi lại'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _exitGame();
            },
            child: const Text('Menu'),
          ),
        ],
      ),
    );
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Chúc mừng!'),
        content: Text('Bạn đã thắng sau $_moves lượt!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (_currentDifficulty != null) {
                _startGame(_currentDifficulty!);
              }
            },
            child: const Text('Chơi lại'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _exitGame();
            },
            child: const Text('Menu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF161B22)
        : const Color(0xFFF3F5FA);

    if (!_isPlaying) {
      if (_selectedGameType == null) {
        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: const BackButton(),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.videogame_asset,
                  size: 80,
                  color: isDark ? Colors.white : Colors.amber,
                ),
                const SizedBox(height: 24),
                Text(
                  'CHỌN GAME',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.pressStart2p(
                    fontSize: 24,
                    color: isDark ? Colors.white : Colors.black,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),
                _buildMenuButton(
                  'LẬT HÌNH (MEMORY)',
                  () => _selectGameType(GameType.memory),
                  Colors.teal,
                ),
                const SizedBox(height: 16),
                _buildMenuButton(
                  'NỐI HÌNH (ONET)',
                  () => _selectGameType(GameType.onet),
                  Colors.indigo,
                ),
              ],
            ),
          ),
        );
      }

      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: _backToGameSelection,
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _selectedGameType == GameType.memory ? Icons.flip : Icons.grain,
                size: 80,
                color: isDark ? Colors.white : Colors.red,
              ),
              const SizedBox(height: 24),
              Text(
                _selectedGameType == GameType.memory
                    ? 'POKEMON\nMEMORY'
                    : 'POKEMON\nONET',
                textAlign: TextAlign.center,
                style: GoogleFonts.pressStart2p(
                  fontSize: 24,
                  color: isDark ? Colors.white : Colors.black,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              _buildMenuButton(
                'DỄ (4x4)',
                () => _startGame(GameDifficulty.easy),
                Colors.green,
              ),
              const SizedBox(height: 16),
              _buildMenuButton(
                'THƯỜNG (4x6)',
                () => _startGame(GameDifficulty.medium),
                Colors.blue,
              ),
              const SizedBox(height: 16),
              _buildMenuButton(
                'KHÓ (6x6)',
                () => _startGame(GameDifficulty.hard),
                Colors.orange,
              ),
              const SizedBox(height: 16),
              _buildMenuButton(
                'SIÊU KHÓ (8x6)',
                () => _startGame(GameDifficulty.superHard),
                Colors.purple,
              ),
            ],
          ),
        ),
      );
    }

    // Game UI
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.pause_circle_filled,
                    color: isDark ? Colors.white : Colors.blue,
                    size: 32,
                  ),
                  onPressed: _pauseGame,
                ),
                const SizedBox(width: 8),
                _buildStat('Lượt', '$_moves', isDark),
                const SizedBox(width: 16),
                Expanded(
                  child: _selectedGameType == GameType.onet
                      ? Column(
                          children: [
                            Text(
                              'Time',
                              style: GoogleFonts.inter(
                                color: isDark ? Colors.white70 : Colors.black54,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: _maxSeconds > 0
                                  ? _remainingSeconds / _maxSeconds
                                  : 0,
                              backgroundColor: isDark
                                  ? Colors.white24
                                  : Colors.grey[300],
                              color: _remainingSeconds < 30
                                  ? Colors.red
                                  : Colors.green,
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        )
                      : const Spacer(),
                ),
                const SizedBox(width: 16),
                _buildStat('Điểm', '$_score', isDark),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double availableWidth = constraints.maxWidth - 32;
                final double availableHeight = constraints.maxHeight - 32;
                final int totalCards = _cards.length;

                // Algorithm to find best column count that ensures all cards fit in viewport
                int bestCols = 4;

                // Try from 4 up to 18 columns
                for (int cols = 4; cols <= 18; cols++) {
                  final rows = (totalCards / cols).ceil();

                  // Calculate potential card size based on width
                  // availableWidth = (cols * cardWidth) + ((cols - 1) * spacing)
                  // width = (available - (c-1)*s) / c
                  final cardWidth =
                      (availableWidth - (cols - 1) * 4) / cols; // Spacing 4
                  final cardHeight = cardWidth / 0.8;

                  final totalHeight = rows * cardHeight + (rows - 1) * 4;

                  if (totalHeight <= availableHeight) {
                    bestCols = cols;
                    break;
                  }

                  // Keep track of the "best so far" (closest to fitting or fully fitting)
                  // If we haven't found a fit yet, we prefer more columns as it reduces height
                  bestCols = cols;
                }

                // If even with max columns it doesn't fit, bestCols will be 18.

                if (_currentCols != bestCols) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && _currentCols != bestCols) {
                      setState(() {
                        _currentCols = bestCols;
                      });
                    }
                  });
                }

                return Stack(
                  children: [
                    GridView.builder(
                      padding: const EdgeInsets.all(16),
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: bestCols,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: _cards.length,
                      itemBuilder: (context, index) {
                        final card = _cards[index];
                        if (!card.isVisible) return const SizedBox();

                        return FlipCard(
                          key: ObjectKey(card),
                          isFaceUp: card.isFaceUp || card.isMatched,
                          front: _buildCardFront(card),
                          back: _buildCardBack(),
                          onTap: () => _onCardTap(card),
                        );
                      },
                    ),
                    if (_onetPath.isNotEmpty)
                      IgnorePointer(
                        child: CustomPaint(
                          size: Size(
                            constraints.maxWidth,
                            constraints.maxHeight,
                          ),
                          painter: OnetPainter(
                            path: _onetPath,
                            cols: bestCols,
                            totalCards: totalCards,
                            padding: 16,
                            spacing: 4,
                            cardAspectRatio: 0.8,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(String label, VoidCallback onPressed, Color color) {
    return SizedBox(
      width: 220,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: Text(label, style: GoogleFonts.pressStart2p(fontSize: 12)),
      ),
    );
  }

  Widget _buildCardFront(CardModel card) {
    if (!card.isVisible) return const SizedBox();
    final isHinted = _hintPairIndices.contains(_cards.indexOf(card));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Strictly white
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isHinted
                ? Colors.cyan.withOpacity(0.5)
                : Colors.black.withOpacity(0.1),
            blurRadius: isHinted ? 8 : 4,
            offset: const Offset(0, 2),
            spreadRadius: isHinted ? 2 : 0,
          ),
        ],
        border: Border.all(
          color: isHinted
              ? Colors.cyanAccent
              : (card.isMatched ? Colors.amber : Colors.transparent),
          width: isHinted ? 4 : 2,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Image.network(
            card.imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.error),
          ),
        ),
      ),
    );
  }

  Widget _buildCardBack() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C3E50),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.white24, width: 2),
      ),
      child: Center(
        child: Icon(
          Icons.catching_pokemon,
          color: Colors.white.withOpacity(0.5),
          size: 24,
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: isDark ? Colors.white70 : Colors.black54,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.pressStart2p(
            // Use retro style for numbers
            color: isDark ? Colors.white : Colors.black,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class OnetPainter extends CustomPainter {
  final List<Point<int>> path;
  final int cols;
  final int totalCards;
  final double padding;
  final double spacing;
  final double cardAspectRatio;

  OnetPainter({
    required this.path,
    required this.cols,
    required this.totalCards,
    required this.padding,
    required this.spacing,
    required this.cardAspectRatio,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (path.isEmpty || cols == 0) return;

    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final double availableWidth = size.width - (padding * 2);
    final double cardWidth = (availableWidth - (cols - 1) * spacing) / cols;
    final double cardHeight = cardWidth / cardAspectRatio;

    Path drawPath = Path();

    for (int i = 0; i < path.length; i++) {
      Point<int> p = path[i];
      int r = p.y;
      int c = p.x;

      double x = padding + c * (cardWidth + spacing) + cardWidth / 2;
      double y = padding + r * (cardHeight + spacing) + cardHeight / 2;

      if (i == 0) {
        drawPath.moveTo(x, y);
      } else {
        drawPath.lineTo(x, y);
      }
    }
    canvas.drawPath(drawPath, paint);
  }

  @override
  bool shouldRepaint(covariant OnetPainter oldDelegate) {
    return oldDelegate.path != path || oldDelegate.cols != cols;
  }
}

class FlipCard extends StatefulWidget {
  final bool isFaceUp;
  final Widget front;
  final Widget back;
  final VoidCallback onTap;

  const FlipCard({
    super.key,
    required this.isFaceUp,
    required this.front,
    required this.back,
    required this.onTap,
  });

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.isFaceUp) {
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFaceUp != oldWidget.isFaceUp) {
      if (widget.isFaceUp) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * pi;
          final isUnder = angle > pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.002) // Perspective
              ..rotateY(angle),
            child: isUnder
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: widget.front,
                  )
                : widget.back,
          );
        },
      ),
    );
  }
}
