class GalleryPhotoModel {
  final int id;
  final int user;
  final String image;
  final int order;
  final String uploadedAt;

  GalleryPhotoModel({
    required this.id,
    required this.user,
    required this.image,
    required this.order,
    required this.uploadedAt,
  });

  factory GalleryPhotoModel.fromJson(Map<String, dynamic> json) {
    return GalleryPhotoModel(
      id: json['id'] as int,
      user: json['user'] as int,
      image: json['image'] as String,
      order: json['order'] as int,
      uploadedAt: json['uploaded_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'image': image,
      'order': order,
      'uploaded_at': uploadedAt,
    };
  }
}
