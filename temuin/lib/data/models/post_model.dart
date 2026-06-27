import 'package:equatable/equatable.dart';

class PostModel extends Equatable {
  final String id;
  final String title;
  final String category;
  final String status;
  final String station;
  final String description;
  final String imageUrl;
  final DateTime date;

  const PostModel({
    required this.id,
    required this.title,
    required this.category,
    required this.status,
    required this.station,
    required this.description,
    required this.imageUrl,
    required this.date,
  });

  PostModel copyWith({
    String? id,
    String? title,
    String? category,
    String? status,
    String? station,
    String? description,
    String? imageUrl,
    DateTime? date,
  }) {
    return PostModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      status: status ?? this.status,
      station: station ?? this.station,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      date: date ?? this.date,
    );
  }

  @override
  List<Object> get props => [
        id,
        title,
        category,
        status,
        station,
        description,
        imageUrl,
        date,
      ];
}
