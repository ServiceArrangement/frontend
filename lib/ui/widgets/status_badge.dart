import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String estado;
  const StatusBadge({required this.estado, super.key});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.grey;
    if (estado == 'Pendiente') color = Colors.orange;
    if (estado == 'En Proceso') color = Colors.blue;
    if (estado == 'Finalizado') color = Colors.green;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(estado, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}