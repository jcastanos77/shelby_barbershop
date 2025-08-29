import 'package:flutter/material.dart';

class GalleryPage extends StatelessWidget {
  final List<String> sampleGallery = List.generate(8, (index) => 'img_$index');

  @override
  Widget build(BuildContext context) {
    final items = sampleGallery;
    return Padding(
      key: ValueKey('gallery'),
      padding: EdgeInsets.all(20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              color: Colors.grey[200],
              child: Center(child: Icon(Icons.image, size: 48)),
            ),
          );
        },
      ),
    );
  }
}
