import 'package:flutter/material.dart';

class ServicesPage extends StatelessWidget {
  final List<Map<String, String>> sampleServices = [
    {'name': 'Corte clásico', 'desc': 'Corte con máquina y tijera, lavado y peinado.', 'price': '250'},
    {'name': 'Degradado', 'desc': 'Fade o degradado profesional', 'price': '280'},
    {'name': 'Barba', 'desc': 'Perfilado, recorte y tratamiento', 'price': '180'},
    {'name': 'Combo (Corte + Barba)', 'desc': 'Corte + perfilado de barba', 'price': '400'},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: ValueKey('services'),
      padding: EdgeInsets.all(20),
      child: GridView.count(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: MediaQuery.of(context).size.width > 900 ? 3 : 1,
        childAspectRatio: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: sampleServices.map((s) => ListTile(
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Colors.grey[200]!)),
          leading: Icon(Icons.content_cut, size: 32),
          title: Text(s['name']!, style: TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(s['desc']!),
          trailing: Text('\$${s['price']}', style: TextStyle(fontWeight: FontWeight.w700)),
        )).toList(),
      ),
    );
  }
}
