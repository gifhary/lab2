import 'package:flutter/material.dart';
import 'package:my_pickup/job.dart';
 
void main() => runApp(JobDetailPage());
 
class JobDetailPage extends StatefulWidget {
  final Job job;

  JobDetailPage({Key key, this.job});

  @override
  _JobDetailPageState createState() => _JobDetailPageState();
}

class _JobDetailPageState extends State<JobDetailPage> {
  @override
  Widget build(BuildContext context) {
   return Scaffold(
     resizeToAvoidBottomPadding: false,
     appBar: AppBar(
        title: Text("Details"),
      ),
     body: SingleChildScrollView(
       //TODO display all job details
       child: Text(widget.job.jobName)
       ),
   );
  }
}