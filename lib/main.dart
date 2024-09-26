import 'package:flutter/material.dart';
import 'dart:async';

void main() => runApp(const MemoryGame());

class MemoryGame extends StatelessWidget {
  const MemoryGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memory Card Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const GameBoard(),
    );
  }
}

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  List<String> _cardItems = [];
  List<bool> _isCardFlipped = [];
  int _firstFlippedIndex = -1;
  bool _isWaiting = false;
  int _matchedPairsCount = 0;
  int _elapsedSeconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    _cardItems = [
      'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H',
      'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'
    ];
    _cardItems.shuffle();
    _isCardFlipped = List.generate(16, (_) => false);
    _matchedPairsCount = 0;
    _firstFlippedIndex = -1;
    _isWaiting = false;
    _elapsedSeconds = 0;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  String _formatTime(int elapsedSeconds) {
    final int minutes = elapsedSeconds ~/ 60;
    final int seconds = elapsedSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}분 ${seconds.toString().padLeft(2, '0')}초';
  }

  void _handleCardTap(int index) {
    if (_isWaiting || _isCardFlipped[index]) return;

    setState(() {
      _isCardFlipped[index] = true;
    });

    if (_firstFlippedIndex == -1) {
      _firstFlippedIndex = index;
    } else {
      if (_firstFlippedIndex == index) {
        // Prevent matching the same card clicked twice
        return;
      }

      _isWaiting = true;

      Timer(const Duration(seconds: 1), () {
        if (_cardItems[_firstFlippedIndex] == _cardItems[index]) {
          _matchedPairsCount++;
          if (_matchedPairsCount == 8) {
            _showGameCompleteDialog();
          }
        } else {
          setState(() {
            _isCardFlipped[_firstFlippedIndex] = false;
            _isCardFlipped[index] = false;
          });
        }

        setState(() {
          _firstFlippedIndex = -1;
          _isWaiting = false;
        });
      });
    }
  }

  void _showGameCompleteDialog() {
    _stopTimer();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('축하합니다!'),
          content: Text('모든 카드를 매칭했습니다!\n소요 시간: ${_formatTime(_elapsedSeconds)}'),
          actions: <Widget>[
            TextButton(
              child: const Text('다시 하기'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _initializeGame();
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('메모리 카드 게임'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '매칭된 쌍: $_matchedPairsCount / 8',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '시간: ${_formatTime(_elapsedSeconds)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1.0,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
              ),
              itemCount: 16,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _handleCardTap(index),
                  child: Card(
                    color: _isCardFlipped[index] ? Colors.white : Colors.blue,
                    child: Center(
                      child: _isCardFlipped[index]
                          ? Text(
                              _cardItems[index],
                              style: const TextStyle(fontSize: 24.0),
                            )
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}