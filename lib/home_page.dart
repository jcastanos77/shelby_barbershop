import 'package:barbershop/service_card.dart';
import 'package:flutter/material.dart';

import 'galeria_page.dart';

class HomePage extends StatelessWidget {
  final List<Map<String, String>> sampleServices = [
    {'name': 'Corte clásico', 'desc': 'Corte con máquina y tijera, lavado y peinado.', 'price': '250'},
    {'name': 'Degradado', 'desc': 'Fade o degradado profesional', 'price': '280'},
    {'name': 'Barba', 'desc': 'Perfilado, recorte y tratamiento', 'price': '180'},
    {'name': 'Combo (Corte + Barba)', 'desc': 'Corte + perfilado de barba', 'price': '400'},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: ValueKey('home'),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: 'hero-banner',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                height: 220,
                width: double.infinity,
                color: Colors.brown[200],
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Placeholder for hero image
                    Center(child: Icon(Icons.face, size: 120, color: Colors.brown[800])),
                    Positioned(
                      left: 20,
                      bottom: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Shelby's BarberShop", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          SizedBox(height: 6),
                          Text('Cortes, Barba y Estilo. Reserva tu cita ahora.', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}