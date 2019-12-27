import 'package:flutter/material.dart';
import 'package:my_pickup/job.dart';
import 'package:toast/toast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as http;

void main() => runApp(JobDetailPage());

class JobDetailPage extends StatefulWidget {
  final Job job;
  final Function(String) delete;

  JobDetailPage({Key key, this.job, this.delete});

  @override
  _JobDetailPageState createState() => _JobDetailPageState();
}

class _JobDetailPageState extends State<JobDetailPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(widget.job.jobName),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.delete,
            ),
            onPressed: _onDelete,
          )
        ],
      ),
      body: SingleChildScrollView(
          child: Column(
        children: <Widget>[
          //TODO display job details
        ],
      )),
    );
  }

  Future<void> _onDelete() {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: SingleChildScrollView(
            child: Text(
                "Are you sure want to delete '" + widget.job.jobName + "' ?"),
          ),
          actions: <Widget>[
            FlatButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            FlatButton(
              child: Text('Delete'),
              onPressed: _delete,
            ),
          ],
        );
      },
    );
  }

  void _delete() {
    Navigator.of(context).pop();
    String url = 'http://pickupandlaundry.com/my_pickup/gifhary/delete_job.php';

    ProgressDialog pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    pr.style(message: "Deleting pickup detail");
    pr.show();

    http.post(url, body: {
      "job_id": widget.job.jobId,
    }).then((res) {
      print(res.statusCode);
      Toast.show(res.body, context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      pr.dismiss();
      if (res.body == "success") {
        widget.delete(widget.job.jobId);
        Navigator.of(context).pop();
      }
    }).catchError((err) {
      print(err);
    });
  }
}
