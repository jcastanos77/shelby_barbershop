class ReviewModel {
  final String id;
  final String name;
  final String comment;
  final int rating;

  ReviewModel({
    required this.id,
    required this.name,
    required this.comment,
    required this.rating
  });

  factory ReviewModel.fromMap(String id, Map data) {
    return ReviewModel(
      id: id,
      name: data['name'],
      comment: data['comment'],
        rating:  data['rating']
    );
  }
}
