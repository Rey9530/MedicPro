import 'package:flutter/material.dart';
import 'package:medicpro/src/models/model.dart';
import 'package:medicpro/src/themes/theme.dart';
import 'package:medicpro/src/utils/variables.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
class DeleteDialog extends StatefulWidget {
  const DeleteDialog(this.model, this.selectedAppointment, this.events);

  final SampleModel model;
  final Appointment selectedAppointment;
  final CalendarDataSource events;

  @override
  DeleteDialogState createState() => DeleteDialogState();
}

class DeleteDialogState extends State<DeleteDialog> {
  Delete _delete = Delete.event;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Color defaultTextColor =
        temaApp.brightness == Brightness.dark ? Colors.white : Colors.black87;
    return SimpleDialog(
      children: <Widget>[
        Container(
          width: 380,
          height: 210,
          padding: const EdgeInsets.only(top: 10),
          child: Container(
            width: 370,
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 30,
                  padding: const EdgeInsets.only(left: 25, top: 5),
                  child: Text(
                    'Delete recurring event',
                    style: TextStyle(
                        color: defaultTextColor, fontWeight: FontWeight.w500),
                  ),
                ),
                Container(
                  width: 20,
                ),
                RadioListTile<Delete>(
                  title: const Text('This event'),
                  value: Delete.event,
                  groupValue: _delete,
                  activeColor: widget.model.backgroundColor,
                  onChanged: (Delete? value) {
                    setState(() {
                      _delete = value!;
                    });
                  },
                ),
                RadioListTile<Delete>(
                  title: const Text('All events'),
                  value: Delete.series,
                  groupValue: _delete,
                  activeColor: widget.model.backgroundColor,
                  onChanged: (Delete? value) {
                    setState(() {
                      _delete = value!;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    RawMaterialButton(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                            color: widget.model.backgroundColor,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    RawMaterialButton(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        final Appointment? parentAppointment = widget.events
                            .getPatternAppointment(
                                widget.selectedAppointment, '') as Appointment?;
                        if (_delete == Delete.event) {
                          if (widget.selectedAppointment.recurrenceId != null) {
                            widget.events.appointments!
                                .remove(widget.selectedAppointment);
                            widget.events.notifyListeners(
                                CalendarDataSourceAction.remove,
                                <Appointment>[widget.selectedAppointment]);
                          }
                          widget.events.appointments!.removeAt(widget
                              .events.appointments!
                              .indexOf(parentAppointment));
                          widget.events.notifyListeners(
                              CalendarDataSourceAction.remove,
                              <Appointment>[parentAppointment!]);
                          parentAppointment.recurrenceExceptionDates != null
                              ? parentAppointment.recurrenceExceptionDates!
                                  .add(widget.selectedAppointment.startTime)
                              : parentAppointment.recurrenceExceptionDates =
                                  <DateTime>[
                                  widget.selectedAppointment.startTime
                                ];
                          widget.events.appointments!.add(parentAppointment);
                          widget.events.notifyListeners(
                              CalendarDataSourceAction.add,
                              <Appointment>[parentAppointment]);
                        } else {
                          if (parentAppointment!.recurrenceExceptionDates ==
                              null) {
                            widget.events.appointments!.removeAt(widget
                                .events.appointments!
                                .indexOf(parentAppointment));
                            widget.events.notifyListeners(
                                CalendarDataSourceAction.remove,
                                <Appointment>[parentAppointment]);
                          } else {
                            final List<DateTime>? exceptionDates =
                                parentAppointment.recurrenceExceptionDates;
                            for (int i = 0; i < exceptionDates!.length; i++) {
                              final Appointment? changedOccurrence =
                                  widget.events.getOccurrenceAppointment(
                                      parentAppointment, exceptionDates[i], '');
                              if (changedOccurrence != null) {
                                widget.events.appointments!
                                    .remove(changedOccurrence);
                                widget.events.notifyListeners(
                                    CalendarDataSourceAction.remove,
                                    <Appointment>[changedOccurrence]);
                              }
                            }
                            widget.events.appointments!.removeAt(widget
                                .events.appointments!
                                .indexOf(parentAppointment));
                            widget.events.notifyListeners(
                                CalendarDataSourceAction.remove,
                                <Appointment>[parentAppointment]);
                          }
                        }
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Delete',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: widget.model.backgroundColor),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}