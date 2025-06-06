import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/feedback_model.dart';
import 'package:hive/hive.dart';

class FeedbackPage extends StatefulWidget {
  final Function(FeedbackModel) onSubmit;
  final int recipeId;
  final String recipeImage;
  final String recipeTitle;
  final String recipeCity;

  FeedbackPage({
    required this.onSubmit,
    required this.recipeId,
    required this.recipeImage,
    required this.recipeTitle,
    required this.recipeCity,
  });

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}


class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  String selectedTimezone = "WIB";
  final timezones = ["WIB", "WITA", "WIT", "London"];

  DateTime now = DateTime.now();

  String getConvertedTime(String timezone) {
    int offset = 0;
    switch (timezone) {
      case 'WITA':
        offset = 1;
        break;
      case 'WIT':
        offset = 2;
        break;
      case 'London':
        offset = -6; // WIB ke GMT
        break;
      default:
        offset = 0;
    }
    return DateFormat('yyyy-MM-dd – HH:mm').format(now.add(Duration(hours: offset)));
  }

  void _submitFeedback() async {
    if (_formKey.currentState!.validate()) {
      final feedback = FeedbackModel(
        recipeId: widget.recipeId,
        comment: _controller.text.trim(),
        submittedAt: DateTime.now().toUtc().add(Duration(
          hours: selectedTimezone == "WITA"
              ? 8
              : selectedTimezone == "WIT"
                  ? 9
                  : selectedTimezone == "London"
                      ? 1
                      : 7,
        )),
        timezone: selectedTimezone,
      );

      final box = await Hive.openBox<FeedbackModel>('feedbacks');
      await box.add(feedback);

      widget.onSubmit(feedback);
      Navigator.pop(context);
    }
  }


  @override
  Widget build(BuildContext context) {
    String convertedTime = getConvertedTime(selectedTimezone);

    return Scaffold(
      appBar: AppBar(
        title: Text('Kirim Catatan'),
      ),
      
      body: Padding(
        
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.recipeImage,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.recipeTitle,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.recipeCity,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text("Zona Waktu"),
              DropdownButton<String>(
                value: selectedTimezone,
                onChanged: (value) {
                  setState(() {
                    selectedTimezone = value!;
                  });
                },
                items: timezones.map((String tz) {
                  return DropdownMenuItem<String>(
                    value: tz,
                    child: Text(tz),
                  );
                }).toList(),
              ),
              SizedBox(height: 8),
              Text("Waktu Kirim: $convertedTime ($selectedTimezone)"),
              SizedBox(height: 16),
              TextFormField(
                controller: _controller,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Tulis catatan Anda...',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Catatan tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _submitFeedback,
                  child: Text('Kirim'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
