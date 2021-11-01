
import 'package:flutter/material.dart';
import 'package:medicpro/src/models/model.dart';
import 'package:medicpro/src/themes/theme.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';


enum _Edit { event, series }

class EditDialog extends StatefulWidget {
  const EditDialog(this.model, this.newAppointment, this.selectedAppointment,
      this.recurrenceProperties, this.events);

  final SampleModel model;
  final Appointment newAppointment, selectedAppointment;
  final RecurrenceProperties? recurrenceProperties;
  final CalendarDataSource events;

  @override
  EditDialogState createState() => EditDialogState();
}

class EditDialogState extends State<EditDialog> {
  _Edit _edit = _Edit.event;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Color defaultTextColor =
         temaApp.brightness == Brightness.dark
            ? Colors.white
            : Colors.black87;
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
                    'Save recurring event',
                    style: TextStyle(
                        color: defaultTextColor, fontWeight: FontWeight.w500),
                  ),
                ),
                Container(
                  width: 20,
                ),
                RadioListTile<_Edit>(
                  title: const Text('This event'),
                  value: _Edit.event,
                  groupValue: _edit,
                  activeColor: widget.model.backgroundColor,
                  onChanged: (_Edit? value) {
                    setState(() {
                      _edit = value!;
                    });
                  },
                ),
                RadioListTile<_Edit>(
                  title: const Text('All events'),
                  value: _Edit.series,
                  groupValue: _edit,
                  activeColor: widget.model.backgroundColor,
                  onChanged: (_Edit? value) {
                    setState(() {
                      _edit = value!;
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
                        if (_edit == _Edit.event) {
                          final Appointment? parentAppointment = widget.events
                                  .getPatternAppointment(
                                      widget.selectedAppointment, '')
                              as Appointment?;

                          final Appointment newAppointment = Appointment(
                              startTime: widget.newAppointment.startTime,
                              endTime: widget.newAppointment.endTime,
                              color: widget.newAppointment.color,
                              notes: widget.newAppointment.notes,
                              isAllDay: widget.newAppointment.isAllDay,
                              location: widget.newAppointment.location,
                              subject: widget.newAppointment.subject,
                              resourceIds: widget.newAppointment.resourceIds,
                              id: widget.selectedAppointment.appointmentType ==
                                      AppointmentType.changedOccurrence
                                  ? widget.selectedAppointment.id
                                  : null,
                              recurrenceId: parentAppointment!.id,
                              recurrenceRule: null,
                              recurrenceExceptionDates: null,
                              startTimeZone:
                                  widget.newAppointment.startTimeZone,
                              endTimeZone: widget.newAppointment.endTimeZone);

                          parentAppointment.recurrenceExceptionDates != null
                              ? parentAppointment.recurrenceExceptionDates!
                                  .add(widget.selectedAppointment.startTime)
                              : parentAppointment.recurrenceExceptionDates =
                                  <DateTime>[
                                  widget.selectedAppointment.startTime
                                ];
                          widget.events.appointments!.removeAt(widget
                              .events.appointments!
                              .indexOf(parentAppointment));
                          widget.events.notifyListeners(
                              CalendarDataSourceAction.remove,
                              <Appointment>[parentAppointment]);
                          widget.events.appointments!.add(parentAppointment);
                          widget.events.notifyListeners(
                              CalendarDataSourceAction.add,
                              <Appointment>[parentAppointment]);
                          if (widget.selectedAppointment.appointmentType ==
                              AppointmentType.changedOccurrence) {
                            widget.events.appointments!.removeAt(widget
                                .events.appointments!
                                .indexOf(widget.selectedAppointment));
                            widget.events.notifyListeners(
                                CalendarDataSourceAction.remove,
                                <Appointment>[widget.selectedAppointment]);
                          }
                          widget.events.appointments!.add(newAppointment);
                          widget.events.notifyListeners(
                              CalendarDataSourceAction.add,
                              <Appointment>[newAppointment]);
                        } else {
                          Appointment? parentAppointment = widget.events
                                  .getPatternAppointment(
                                      widget.selectedAppointment, '')
                              as Appointment?;
                          final List<DateTime>? exceptionDates =
                              parentAppointment!.recurrenceExceptionDates;
                          if (exceptionDates != null &&
                              exceptionDates.isNotEmpty) {
                            for (int i = 0; i < exceptionDates.length; i++) {
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
                          }

                          widget.events.appointments!.removeAt(widget
                              .events.appointments!
                              .indexOf(parentAppointment));
                          widget.events.notifyListeners(
                              CalendarDataSourceAction.remove,
                              <Appointment>[parentAppointment]);
                          DateTime _startDate, _endDate;
                          if ((widget.newAppointment.startTime)
                              .isBefore(parentAppointment.startTime)) {
                            _startDate = widget.newAppointment.startTime;
                            _endDate = widget.newAppointment.endTime;
                          } else {
                            _startDate = DateTime(
                                parentAppointment.startTime.year,
                                parentAppointment.startTime.month,
                                parentAppointment.startTime.day,
                                widget.newAppointment.startTime.hour,
                                widget.newAppointment.startTime.minute);
                            _endDate = DateTime(
                                parentAppointment.endTime.year,
                                parentAppointment.endTime.month,
                                parentAppointment.endTime.day,
                                widget.newAppointment.endTime.hour,
                                widget.newAppointment.endTime.minute);
                          }
                          parentAppointment = Appointment(
                              startTime: _startDate,
                              endTime: _endDate,
                              color: widget.newAppointment.color,
                              notes: widget.newAppointment.notes,
                              isAllDay: widget.newAppointment.isAllDay,
                              location: widget.newAppointment.location,
                              subject: widget.newAppointment.subject,
                              resourceIds: widget.newAppointment.resourceIds,
                              id: parentAppointment.id,
                              recurrenceId: null,
                              recurrenceRule:
                                  widget.recurrenceProperties == null
                                      ? null
                                      : SfCalendar.generateRRule(
                                          widget.recurrenceProperties!,
                                          _startDate,
                                          _endDate),
                              recurrenceExceptionDates: null,
                              startTimeZone:
                                  widget.newAppointment.startTimeZone,
                              endTimeZone: widget.newAppointment.endTimeZone);
                          widget.events.appointments!.add(parentAppointment);
                          widget.events.notifyListeners(
                              CalendarDataSourceAction.add,
                              <Appointment>[parentAppointment]);
                        }
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Save',
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