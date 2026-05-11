import 'package:flutter/material.dart';
import '../../models/project.dart';
import '../../theme/app_theme.dart';

class ModuleListItem extends StatelessWidget {
  final Module module;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onToggleDone;

  const ModuleListItem({
    super.key,
    required this.module,
    required this.isSelected,
    required this.onTap,
    required this.onToggleDone,
  });

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (d.inHours > 0) {
      return '${d.inHours}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 1,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      color: isSelected ? AppTheme.softGray : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppTheme.navyBlue : Colors.transparent,
          width: 2,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(
          module.title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            decoration: module.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(
          '${_formatDuration(module.startTime)} - ${_formatDuration(module.endTime)}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: IconButton(
          icon: Icon(
            module.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: module.isCompleted ? AppTheme.forestGreen : Colors.grey,
          ),
          onPressed: onToggleDone,
        ),
      ),
    );
  }
}
