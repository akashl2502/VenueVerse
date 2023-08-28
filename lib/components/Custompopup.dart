import 'package:flutter/material.dart';

class CustomPopupDialog extends StatefulWidget {
  final String title;
  final String message;
  final String confirmButtonText;
  final Function onConfirm;
  final bool showDateTime;
  final bool showTextInput;
  final Function(String)? onTextInputChanged;

  CustomPopupDialog({
    required this.title,
    required this.message,
    required this.confirmButtonText,
    required this.onConfirm,
    this.showDateTime = false,
    this.showTextInput = false,
    this.onTextInputChanged,
  });

  @override
  _CustomPopupDialogState createState() => _CustomPopupDialogState();
}

class _CustomPopupDialogState extends State<CustomPopupDialog> {
  DateTime? selectedDateTime;
  TextEditingController dateTimeController = TextEditingController();
  TextEditingController textInputController = TextEditingController();

  _pickDateTime() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (date != null) {
      TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        final DateTime dateTime =
            DateTime(date.year, date.month, date.day, time.hour, time.minute);
        setState(() {
          selectedDateTime = dateTime;
          dateTimeController.text =
              "${dateTime.toLocal().toIso8601String().split(' ')[0]} ${time.format(context)}";
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
          Text(widget.message),
          SizedBox(height: 16),
          if (widget.showDateTime)
            GestureDetector(
              onTap: _pickDateTime,
              child: AbsorbPointer(
                child: TextFormField(
                  controller: dateTimeController,
                  decoration: InputDecoration(
                    labelText: 'Select Date & Time',
                    hintText: 'Select Date & Time',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ),
          if (widget.showDateTime) SizedBox(height: 16),
          if (widget.showTextInput)
            TextFormField(
              controller: textInputController,
              decoration: InputDecoration(
                labelText: 'New Mail Id',
                hintText: 'Enter New Mail Id',
              ),
              onChanged: (value) {
                if (widget.onTextInputChanged != null) {
                  widget.onTextInputChanged!(value);
                }
              },
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
            widget.onConfirm();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
