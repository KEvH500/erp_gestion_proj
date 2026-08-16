import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'unplanned_tasks_controller.dart';
import 'widgets/quick_task_sheet.dart';
import 'widgets/unplanned_task_list_widget.dart';

/// Vue dédiée à la gestion des tâches imprévues et urgences
class UnplannedTasksView extends GetView<UnplannedTasksController> {
  const UnplannedTasksView({super.key});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE d MMMM yyyy', 'fr_FR');

    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final formattedDate = dateFormat.format(controller.selectedDate.value);
          final capitalizedDate = formattedDate[0].toUpperCase() + formattedDate.substring(1);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Imprévus & Urgences', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text(capitalizedDate, style: const TextStyle(fontSize: 11)),
            ],
          );
        }),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_rounded),
            tooltip: 'Changer la date',
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: controller.selectedDate.value,
                firstDate: DateTime.now().subtract(const Duration(days: 90)),
                lastDate: DateTime.now().add(const Duration(days: 90)),
              );
              if (picked != null) {
                controller.setDate(picked);
              }
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.only(bottom: 80),
          children: [
            UnplannedTaskListWidget(
              date: controller.selectedDate.value,
              initiallyExpanded: true,
              onTasksChanged: controller.loadTasks,
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          QuickTaskSheet.show(context, initialDate: controller.selectedDate.value)
              .then((_) => controller.loadTasks());
        },
        icon: const Icon(Icons.bolt_rounded),
        label: const Text('Nouvel Imprévu', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
