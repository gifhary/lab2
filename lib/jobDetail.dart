import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
   return WillPopScope(
      onWillPop: _onBackPressAppBar,
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        body: SingleChildScrollView(
          //TODO display all job details
          child: Text("job detail")
          ),
      ),
    );
  }

  Future<bool> _onBackPressAppBar() async {
    SystemNavigator.pop();
    print('Backpress');
    return Future.value(false);
  }
}