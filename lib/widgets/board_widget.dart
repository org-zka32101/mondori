import 'package:flutter/material.dart';
import 'package:mondori/models/board.dart';
import 'package:mondori/models/piece.dart';

class BoardWidget extends StatelessWidget {
  final Board board;
  final Piece? selectedPiece;
  final Function(Piece) onPieceSelected;
  final Function(Position) onPositionTapped;

  const BoardWidget({
    Key? key,
    required this.board,
    required this.selectedPiece,
    required this.onPieceSelected,
    required this.onPositionTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const columns = ['a', 'b', 'c', 'd', 'e', 'f'];
    const rows = [6, 5, 4, 3, 2, 1];

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: AspectRatio(
        aspectRatio: 1,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                // 列ラベル
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: columns
                        .map((col) => SizedBox(
                      width: 48,
                      child: Center(
                        child: Text(
                          col,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 4),
                // ゲーム盤
                Expanded(
                  child: Row(
                    children: [
                      // 行ラベル
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: rows
                            .map((row) => SizedBox(
                          height: 48,
                          child: Center(
                            child: Text(
                              '$row',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ))
                            .toList(),
                      ),
                      const SizedBox(width: 8),
                      // グリッド
                      Expanded(
                        child: GridView.builder(
                          padding: EdgeInsets.zero,
                          gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 6,
                          ),
                          itemCount: 36,
                          itemBuilder: (context, index) {
                            final col = index % 6;
                            final row = index ~/ 6;
                            final column = columns[col];
                            final rowNum = rows[row];
                            final position = Position(
                              column: column,
                              row: rowNum,
                            );

                            final piece = board.getPieceAt(position);
                            final isSelected = selectedPiece?.position == position;
                            final isMovable = selectedPiece != null &&
                                selectedPiece!.getMovablePositions()
                                    .contains(position) &&
                                piece == null;
                            final isCaptureable = selectedPiece != null &&
                                selectedPiece!.position
                                    .getAdjacentPositions()
                                    .contains(position) &&
                                piece != null &&
                                piece.side != selectedPiece!.side;
                            final isConvertible = selectedPiece != null &&
                                selectedPiece!.position
                                    .getAdjacentPositions()
                                    .contains(position) &&
                                piece != null &&
                                piece.side == selectedPiece!.side &&
                                piece.seal == SealType.none;

                            return GestureDetector(
                              onTap: () {
                                if (piece != null &&
                                    piece.seal != SealType.none) {
                                  onPieceSelected(piece);
                                } else {
                                  onPositionTapped(position);
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _getCellColor(
                                    isSelected,
                                    isMovable,
                                    isCaptureable,
                                    isConvertible,
                                  ),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: piece != null
                                    ? _PieceWidget(
                                  piece: piece,
                                  isSelected: isSelected,
                                )
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCellColor(
    bool isSelected,
    bool isMovable,
    bool isCaptureable,
    bool isConvertible,
  ) {
    if (isSelected) {
      return Colors.blue.shade100;
    } else if (isMovable) {
      return Colors.green.shade100;
    } else if (isCaptureable) {
      return Colors.red.shade100;
    } else if (isConvertible) {
      return Colors.amber.shade100;
    }
    return Colors.white;
  }
}

class _PieceWidget extends StatelessWidget {
  final Piece piece;
  final bool isSelected;

  const _PieceWidget({
    required this.piece,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: piece.side == PlayerSide.A
            ? Colors.deepPurple
            : Colors.orange,
        border: isSelected ? Border.all(
          color: Colors.blue,
          width: 3,
        ) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _getSealLabel(piece.seal),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getSealLabel(SealType seal) {
    switch (seal) {
      case SealType.advance:
        return '進';
      case SealType.swift:
        return '早';
      case SealType.counter:
        return '対';
      case SealType.king:
        return '王';
      case SealType.none:
        return '';
    }
  }
}
