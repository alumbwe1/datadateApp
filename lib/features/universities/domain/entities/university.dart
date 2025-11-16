import 'package:equatable/equatable.dart';

class University extends Equatable {
  final int id;
  final String name;
  final String slug;
  final String? logo;

  const University({
    required this.id,
    required this.name,
    required this.slug,
    this.logo,
  });

  @override
  List<Object?> get props => [id, name, slug, logo];
}
