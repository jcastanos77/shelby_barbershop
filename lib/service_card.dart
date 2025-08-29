import 'package:flutter/material.dart';

class ServiceCard extends StatelessWidget {
  final Map<String, String> service;
  ServiceCard({required this.service});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: EdgeInsets.only(right: 12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.content_cut, size: 34),
                SizedBox(height: 8),
                Text(service['name']!, style: TextStyle(fontWeight: FontWeight.w700)),
                SizedBox(height: 6),
                Text(service['desc']!, style: TextStyle(fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                SizedBox(height: 6),
                //Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('\$${service['price']}', style: TextStyle(fontWeight: FontWeight.w700)), ElevatedButton(onPressed: () { Navigator.of(context).push(MaterialPageRoute(builder: (_) => BookingPage())); }, child: Text('Reservar'))])
              ],
            ),
          ),
        ),
      ),
    );
  }
}