import 'package:flutter/material.dart';

class ContactPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      key: ValueKey('contact'),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Contacto', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,color: Colors.white)),
          SizedBox(height: 12),
          ListTile(leading: Icon(Icons.location_on), title: Text('Calle Falsa 123', style: TextStyle(color: Colors.white),)),
          ListTile(leading: Icon(Icons.phone), title: Text('+52 1 55 1234 5678', style: TextStyle(color: Colors.white))),
          ListTile(leading: Icon(Icons.phone_android), title: Text('WhatsApp disponible', style: TextStyle(color: Colors.white))),
          SizedBox(height: 12),
          ElevatedButton.icon(onPressed: () {
            // TODO: abrir mapa o whatsapp con url_launcher
          }, icon: Icon(Icons.map), label: Text('Abrir en mapas')),
        ],
      ),
    );
  }
}
