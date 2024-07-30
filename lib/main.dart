import 'package:flutter/material.dart';

void main() {
  runApp(Game());
}

class Game extends StatefulWidget {
  @override
  GameState createState() => GameState();
}

class GameState extends State<Game> {
  late List<List<String?>> history = [List<String?>.filled(9, null)];
  int currentMove = 0;

  bool get xIsNext => currentMove % 2 == 0;
  List<String?> get currentSquares => history[currentMove];

  void handlePlay(List<String?> nextSquares) {
    setState(() {
      history = history.sublist(0, currentMove + 1)..add(nextSquares);
      currentMove = history.length - 1;
    });
  }

  void jumpTo(int nextMove) {
    setState(() {
      currentMove = nextMove;
      if (nextMove == 0) {
        history = [List<String?>.filled(9, null)];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var winnerData = calculateWinner(currentSquares);
    String? winner = winnerData['winner'];
    List<int>? winningLine = winnerData['line'];

    String statusGame;
    if (winner != null) {
      statusGame = 'Ganador: $winner';
    } else if (!currentSquares.contains(null)) {
      statusGame = 'Juego Terminado';
    } else {
      statusGame = 'Jugador: ${xIsNext ? 'X' : 'O'}';
    }

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Tic Tac Toñawer'),
        ),
        body: Column(
          children: [
            Text(statusGame),
            for (int i = 0; i < 3; i++)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int j = 0; j < 3; j++)
                    Square(
                      value: currentSquares[i * 3 + j],
                      onSquareClick: () => handleClick(i * 3 + j),
                      isWinningSquare:
                          winningLine?.contains(i * 3 + j) ?? false,
                      winner: winner,
                    ),
                ],
              ),
            Expanded(
              child: ListView(
                children: history.asMap().entries.map((entry) {
                  int move = entry.key;
                  return ListTile(
                    title: FloatingActionButton(
                      onPressed: () => jumpTo(move),
                      child: Text(
                          move > 0 ? 'Movimiento #$move' : 'Reiniciar Juego'),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void handleClick(int i) {
    if (calculateWinner(currentSquares)['winner'] != null ||
        currentSquares[i] != null) {
      return;
    }
    List<String?> nextSquares = List.from(currentSquares);
    nextSquares[i] = xIsNext ? 'X' : 'O';
    handlePlay(nextSquares);
  }
}

class Square extends StatelessWidget {
  final String? value;
  final VoidCallback onSquareClick;
  final bool isWinningSquare;
  final String? winner;

  Square({
    required this.value,
    required this.onSquareClick,
    this.isWinningSquare = false,
    this.winner,
  });

  @override
  Widget build(BuildContext context) {
    Color? backgroundColor;
    if (isWinningSquare) {
      if (winner == 'X') {
        backgroundColor = Colors.pink; // Rosa para 'X'
      } else if (winner == 'O') {
        backgroundColor = Colors.lightBlueAccent; // Azul claro para 'O'
      }
    }

    return GestureDetector(
      onTap: onSquareClick,
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          border: Border.all(),
        ),
        child: Center(
          child: Text(
            value ?? '',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}

Map<String, dynamic> calculateWinner(List<String?> squares) {
  const lines = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6],
  ];
  for (var line in lines) {
    int a = line[0];
    int b = line[1];
    int c = line[2];
    if (squares[a] != null &&
        squares[a] == squares[b] &&
        squares[a] == squares[c]) {
      return {'winner': squares[a], 'line': line};
    }
  }
  return {'winner': null, 'line': null};
}
