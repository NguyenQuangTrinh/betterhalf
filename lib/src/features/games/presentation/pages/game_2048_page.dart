import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- Logic Models ---

class Tile {
  final int id;
  int x;
  int y;
  int value;
  bool isNew;
  bool isMerged;

  Tile({
    required this.id,
    required this.x,
    required this.y,
    required this.value,
    this.isNew = false,
    this.isMerged = false,
  });
}

class Game2048Page extends StatefulWidget {
  const Game2048Page({super.key});

  @override
  State<Game2048Page> createState() => _Game2048PageState();
}

class _Game2048PageState extends State<Game2048Page>
    with TickerProviderStateMixin {
  // Grid Dimensions
  static const int gridSize = 4;

  // State
  List<Tile> _tiles = [];
  int _score = 0;
  int _highScore = 0;
  bool _isGameOver = false;

  // ID Generator
  int _idCounter = 0;

  // Animation Controller - used to block input during animation
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
    _startNewGame();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highScore = prefs.getInt('high_score_2048') ?? 0;
    });
  }

  Future<void> _updateHighScore() async {
    if (_score > _highScore) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('high_score_2048', _score);
      setState(() {
        _highScore = _score;
      });
    }
  }

  void _startNewGame() {
    setState(() {
      _tiles = [];
      _score = 0;
      _isGameOver = false;
      _idCounter = 0;
      _spawnNewTile();
      _spawnNewTile();
    });
  }

  // --- Core Game Logic ---

  void _spawnNewTile() {
    List<Point<int>> emptySpots = [];

    // Find all empty spots
    for (int x = 0; x < gridSize; x++) {
      for (int y = 0; y < gridSize; y++) {
        bool occupied = _tiles.any((t) => t.x == x && t.y == y);
        if (!occupied) {
          emptySpots.add(Point(x, y));
        }
      }
    }

    if (emptySpots.isNotEmpty) {
      final random = Random();
      Point<int> spot = emptySpots[random.nextInt(emptySpots.length)];
      int value = random.nextDouble() < 0.9 ? 2 : 4;

      setState(() {
        _tiles.add(
          Tile(
            id: _idCounter++,
            x: spot.x,
            y: spot.y,
            value: value,
            isNew: true,
          ),
        );
      });
    }
  }

  // Helper to get tile at x,y
  Tile? _getTileAt(int x, int y) {
    try {
      return _tiles.firstWhere((t) => t.x == x && t.y == y);
    } catch (e) {
      return null;
    }
  }

  // Checking for Valid Moves
  bool _canMove() {
    if (_tiles.length < 16) return true; // Has empty space

    for (var tile in _tiles) {
      // Check Right
      if (tile.x < 3) {
        var right = _getTileAt(tile.x + 1, tile.y);
        if (right != null && right.value == tile.value) return true;
      }
      // Check Down
      if (tile.y < 3) {
        var down = _getTileAt(tile.x, tile.y + 1);
        if (down != null && down.value == tile.value) return true;
      }
    }
    return false;
  }

  // --- Movement Engine ---

  Future<void> _move(int direction) async {
    // direction: 0: Up, 1: Down, 2: Left, 3: Right
    // For consistency with previous logic, let's map:
    // Up: y decreases. Down: y increases. Left: x decreases. Right: x increases.

    if (_isAnimating || _isGameOver) return;
    _isAnimating = true;

    bool moved = false;
    List<Tile> tilesToRemove = [];
    List<Tile> tilesToAdd = [];

    // Reset merge flags
    for (var t in _tiles) t.isMerged = false;
    for (var t in _tiles) t.isNew = false; // Clear new flag for animation reset

    // We process line by line based on direction
    // Logic:
    // 1. Sort tiles based on direction to process 'leading' edge first.
    // 2. Move each tile as far as possible.
    // 3. If it hits a tile with same value that hasn't merged yet -> Merge.

    // Sort logic
    // Up (dir 0): sort by y ascending
    // Down (dir 1): sort by y descending
    // Left (dir 2): sort by x ascending
    // Right (dir 3): sort by x descending

    _tiles.sort((a, b) {
      if (direction == 0) return a.y.compareTo(b.y);
      if (direction == 1) return b.y.compareTo(a.y);
      if (direction == 2) return a.x.compareTo(b.x);
      if (direction == 3) return b.x.compareTo(a.x);
      return 0;
    });

    for (var tile in _tiles) {
      int targetX = tile.x;
      int targetY = tile.y;

      // Calculate farthest valid position
      // Simple iterative approach for clarity
      while (true) {
        int nextX = targetX;
        int nextY = targetY;

        if (direction == 0) nextY--; // Up
        if (direction == 1) nextY++; // Down
        if (direction == 2) nextX--; // Left
        if (direction == 3) nextX++; // Right

        // Bounds check
        if (nextX < 0 || nextX >= gridSize || nextY < 0 || nextY >= gridSize) {
          break;
        }

        // Collision check
        Tile? obstacle = _getTileAt(nextX, nextY);

        if (obstacle != null) {
          // Can we merge?
          if (obstacle.value == tile.value && !obstacle.isMerged) {
            // MERGE!
            // We move 'tile' to 'obstacle's position logic-wise for animation
            targetX = nextX;
            targetY = nextY;

            // Mark potential merge
            // We don't modify the lists yet, we just set the target coordinates for animation
            // and prepare the "future" state.

            // BUT: obstacle is already in the list. To merge, we will:
            // 1. Animate 'tile' to (nextX, nextY).
            // 2. Remove BOTH 'tile' and 'obstacle' after animation.
            // 3. Add a NEW tile at (nextX, nextY) with double value.

            // Problem: _getTileAt relies on current x,y.
            // If we update tile.x/y immediately for animation, subsequent loop iterations sees them there.
            // Correct approach: Update x/y immediately for the 'algorithm', but purely for collision checks?
            // Actually, in Flutter `setState` triggers the specific animation.

            // We need to flag this specific tile is merging into 'obstacle'.
            // Because 'obstacle' might have JUST moved there in this same turn?
            // No, because we sort by direction, 'obstacle' (which is 'ahead') has already moved.

            obstacle.isMerged = true; // Block further merges this turn
            tilesToRemove.add(tile);
            tilesToRemove.add(obstacle);

            Tile newTile = Tile(
              id: _idCounter++, // New ID for the merged result
              x: nextX,
              y: nextY,
              value: tile.value * 2,
              isNew:
                  false, // It's a "merge" pop not a "spawn" pop strictly, but simple scale is fine
              isMerged:
                  true, // Mark so it doesn't merge again (handled by obstacle check above though)
            );
            tilesToAdd.add(newTile);

            // Score update
            _score += newTile.value;

            moved = true;
          }
          break; // Hit something, stop (whether merged or not)
        } else {
          // Empty space, continue moving
          targetX = nextX;
          targetY = nextY;
        }
      }

      // Apply Move
      if (tile.x != targetX || tile.y != targetY) {
        tile.x = targetX;
        tile.y = targetY;
        moved = true;
      }
    }

    if (moved) {
      // Phase 1: Animate the slide
      setState(() {
        // Just calling setState updates specific Tile x/y fields which AnimatedPositioned listens to.
      });

      // Wait for slide to finish
      await Future.delayed(const Duration(milliseconds: 150));

      // Phase 2: Process Merges & Spawn
      setState(() {
        for (var t in tilesToRemove) {
          _tiles.remove(t);
        }
        for (var t in tilesToAdd) {
          t.isMerged = false; // Reset flag
          t.isNew = true; // Trigger pop animation for the new merged tile
          _tiles.add(t);
        }

        _spawnNewTile();
        _updateHighScore();

        if (!_canMove()) {
          _isGameOver = true;
          _showGameOverDialog();
        }
      });
    }

    _isAnimating = false;
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Game Over!'),
        content: Text('Điểm của bạn: $_score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _startNewGame();
            },
            child: const Text('Chơi lại'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  // --- UI Helpers ---

  Color _getTileColor(int value) {
    switch (value) {
      case 2:
        return const Color(0xFFEEE4DA);
      case 4:
        return const Color(0xFFEDE0C8);
      case 8:
        return const Color(0xFFF2B179);
      case 16:
        return const Color(0xFFF59563);
      case 32:
        return const Color(0xFFF67C5F);
      case 64:
        return const Color(0xFFF65E3B);
      case 128:
        return const Color(0xFFEDCF72);
      case 256:
        return const Color(0xFFEDCC61);
      case 512:
        return const Color(0xFFEDC850);
      case 1024:
        return const Color(0xFFEDC53F);
      case 2048:
        return const Color(0xFFEDC22E);
      default:
        return const Color(0xFF3C3A32);
    }
  }

  Color _getTextColor(int value) {
    return value <= 4 ? const Color(0xFF776E65) : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    // Layout Calculation
    // We need fixed size for Stack
    final double size = MediaQuery.of(context).size.width - 32;
    final double tileSize = (size - (gridSize + 1) * 10) / gridSize;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8EF),
      appBar: AppBar(
        title: Text(
          '2048',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 32,
            color: const Color(0xFF776E65),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF776E65)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF776E65)),
            onPressed: _startNewGame,
          ),
        ],
      ),
      body: Column(
        children: [
          // Score Board
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildScoreBox('ĐIỂM', '$_score'),
                _buildScoreBox('CAO NHẤT', '$_highScore'),
              ],
            ),
          ),

          const Spacer(),

          // GAME BOARD
          Center(
            child: Container(
              width: size,
              height: size,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFBBADA0),
                borderRadius: BorderRadius.circular(16),
              ),
              child: GestureDetector(
                onVerticalDragEnd: (details) {
                  if (details.primaryVelocity! < -200)
                    _move(0); // Up
                  else if (details.primaryVelocity! > 200)
                    _move(1); // Down
                },
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity! < -200)
                    _move(2); // Left
                  else if (details.primaryVelocity! > 200)
                    _move(3); // Right
                },
                child: Stack(
                  children: [
                    // Background Grid Cells (static placeholders)
                    ...List.generate(16, (index) {
                      int x = index % 4;
                      int y = (index / 4).floor();
                      return Positioned(
                        left: x * (tileSize + 10),
                        top: y * (tileSize + 10),
                        width: tileSize,
                        height: tileSize,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFCDC1B4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    }),

                    // Actual Moving Tiles
                    ..._tiles.map((tile) {
                      return AnimatedPositioned(
                        key: ValueKey(tile.id),
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeOutQuad,
                        left: tile.x * (tileSize + 10),
                        top: tile.y * (tileSize + 10),
                        width: tileSize,
                        height: tileSize,
                        child: _TileWidget(
                          value: tile.value,
                          color: _getTileColor(tile.value),
                          textColor: _getTextColor(tile.value),
                          isNew: tile.isNew,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),

          const Spacer(),

          Text(
            "Vuốt để di chuyển các ô",
            style: GoogleFonts.inter(
              color: const Color(0xFF776E65),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildScoreBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFBBADA0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              color: const Color(0xFFEEE4DA),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Separate Widget for the tile content to handle entry animation (Pop effect)
class _TileWidget extends StatefulWidget {
  final int value;
  final Color color;
  final Color textColor;
  final bool isNew;

  const _TileWidget({
    required this.value,
    required this.color,
    required this.textColor,
    this.isNew = false,
  });

  @override
  State<_TileWidget> createState() => _TileWidgetState();
}

class _TileWidgetState extends State<_TileWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    if (widget.isNew) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_TileWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isNew && !oldWidget.isNew) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            '${widget.value}',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: widget.value > 100 ? 24 : 32,
              color: widget.textColor,
            ),
          ),
        ),
      ),
    );
  }
}
