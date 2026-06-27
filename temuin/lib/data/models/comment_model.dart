import 'package:equatable/equatable.dart';

class CommentModel extends Equatable {
  final String id;
  final String postId;
  final String username;
  final String comment;
  final DateTime createdAt;

  const CommentModel({
    required this.id,
    required this.postId,
    required this.username,
    required this.comment,
    required this.createdAt,
  });

  CommentModel copyWith({
    String? id,
    String? postId,
    String? username,
    String? comment,
    DateTime? createdAt,
  }) {
    return CommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      username: username ?? this.username,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object> get props => [id, postId, username, comment, createdAt];
}
