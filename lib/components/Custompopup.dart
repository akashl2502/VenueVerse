import 'package:flutter/material.dart';

class CustomPopupDialog extends StatefulWidget {
  final String title;
  final String confirmButtonText;
  final Function(TimeOfDay) onConfirm;

  CustomPopupDialog({
    required this.title,
    required this.confirmButtonText,
    required this.onConfirm,
  });

  @override
  _CustomPopupDialogState createState() => _CustomPopupDialogState();
}

class _CustomPopupDialogState extends State<CustomPopupDialog> {
  TimeOfDay? selectedTime;

  _pickTime() async {
    final now = TimeOfDay.now();
    final startTime = TimeOfDay(hour: 9, minute: 0);
    final endTime = TimeOfDay(hour: 17, minute: 0);

    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? now,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (time != null) {
      final selectedDateTime = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        time.hour,
        time.minute,
      );

      final startDateTime = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        startTime.hour,
        startTime.minute,
      );

      final endDateTime = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        endTime.hour,
        endTime.minute,
      );

      if (selectedDateTime.isBefore(startDateTime) ||
          selectedDateTime.isAfter(endDateTime)) {
        // Show an error message or inform the user that the selected time is outside the allowed range.
        // You can use a SnackBar or AlertDialog for this purpose.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Please select a time between 9 AM and 5 PM."),
          ),
        );
      } else {
        setState(() {
          selectedTime = time;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (selectedTime != null)
            Text(
              'Selected Time: ${selectedTime!.format(context)}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          SizedBox(height: 16),
          GestureDetector(
            onTap: _pickTime,
            child: AbsorbPointer(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Select Time (9 AM - 5 PM)',
                  hintText: 'Select Time (9 AM - 5 PM)',
                  suffixIcon: Icon(Icons.access_time),
                ),
                controller: TextEditingController(
                    text: selectedTime != null
                        ? selectedTime!.format(context)
                        : ''),
              ),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text(widget.confirmButtonText),
          onPressed: () {
            if (selectedTime != null) {
              widget.onConfirm(selectedTime!);
            }
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
