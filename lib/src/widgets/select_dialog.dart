import 'package:flutter/material.dart';
import 'package:medicpro/src/models/model.dart';
import 'package:medicpro/src/utils/funciones.dart';
import 'package:medicpro/src/utils/variables.dart';
import 'package:medicpro/src/widgets/widgets.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

// ignore: must_be_immutable
class SelectRuleDialog extends StatefulWidget {
  SelectRuleDialog(
      this.model, this.recurrenceProperties, this.appointmentColor, this.events,
      {required this.onChanged, this.selectedAppointment});

  final SampleModel model;

  final Appointment? selectedAppointment;

  RecurrenceProperties? recurrenceProperties;

  final Color appointmentColor;

  final CalendarDataSource events;

  final PickerChanged onChanged;

  @override
  SelectRuleDialogState createState() => SelectRuleDialogState();
}

class SelectRuleDialogState extends State<SelectRuleDialog> {
  late DateTime _startDate;
  RecurrenceProperties? _recurrenceProperties;
  late RecurrenceType _recurrenceType;
  late RecurrenceRange _recurrenceRange;
  late int _interval;

  SelectRule? _rule;

  @override
  void initState() {
    _updateAppointmentProperties();
    super.initState();
  }

  @override
  void didUpdateWidget(SelectRuleDialog oldWidget) {
    _updateAppointmentProperties();
    super.didUpdateWidget(oldWidget);
  }

  /// Updates the required editor's default field
  void _updateAppointmentProperties() {
    _startDate = widget.selectedAppointment!.startTime;
    _recurrenceProperties = widget.recurrenceProperties;
    if (widget.recurrenceProperties == null) {
      _rule = SelectRule.doesNotRepeat;
    } else {
      _updateRecurrenceType();
    }
  }

  void _updateRecurrenceType() {
    _recurrenceType = widget.recurrenceProperties!.recurrenceType;
    _recurrenceRange = _recurrenceProperties!.recurrenceRange;
    _interval = _recurrenceProperties!.interval;
    if (_interval == 1 && _recurrenceRange == RecurrenceRange.noEndDate) {
      switch (_recurrenceType) {
        case RecurrenceType.daily:
          _rule = SelectRule.everyDay;
          break;
        case RecurrenceType.weekly:
          if (_recurrenceProperties!.weekDays.length == 1) {
            _rule = SelectRule.everyWeek;
          } else {
            _rule = SelectRule.custom;
          }
          break;
        case RecurrenceType.monthly:
          _rule = SelectRule.everyMonth;
          break;
        case RecurrenceType.yearly:
          _rule = SelectRule.everyYear;
          break;
      }
    } else {
      _rule = SelectRule.custom;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 400,
        height: 360,
        padding: const EdgeInsets.only(left: 20, top: 10),
        child: ListView(padding: const EdgeInsets.all(0.0), children: <Widget>[
          Container(
            width: 360,
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              children: <Widget>[
                RadioListTile<SelectRule>(
                  title: const Text('Does not repeat'),
                  value: SelectRule.doesNotRepeat,
                  groupValue: _rule,
                  toggleable: true,
                  activeColor: widget.model.backgroundColor,
                  onChanged: (SelectRule? value) {
                    setState(() {
                      if (value != null) {
                        _rule = value;
                        widget.recurrenceProperties = null;
                        widget.onChanged(
                            PickerChangedDetails(selectedRule: _rule));
                      }
                    });
                    Navigator.pop(context, widget.recurrenceProperties);
                  },
                ),
                RadioListTile<SelectRule>(
                  title: const Text('Every day'),
                  value: SelectRule.everyDay,
                  toggleable: true,
                  groupValue: _rule,
                  activeColor: widget.model.backgroundColor,
                  onChanged: (SelectRule? value) {
                    setState(() {
                      if (value != null) {
                        _rule = value;
                        widget.recurrenceProperties =
                            RecurrenceProperties(startDate: _startDate);
                        widget.recurrenceProperties!.recurrenceType =
                            RecurrenceType.daily;
                        widget.recurrenceProperties!.interval = 1;
                        widget.recurrenceProperties!.recurrenceRange =
                            RecurrenceRange.noEndDate;
                        widget.onChanged(
                            PickerChangedDetails(selectedRule: _rule));
                      }
                    });
                    Navigator.pop(context, widget.recurrenceProperties);
                  },
                ),
                RadioListTile<SelectRule>(
                  title: const Text('Every week'),
                  value: SelectRule.everyWeek,
                  toggleable: true,
                  groupValue: _rule,
                  activeColor: widget.model.backgroundColor,
                  onChanged: (SelectRule? value) {
                    setState(() {
                      if (value != null) {
                        _rule = value;
                        widget.recurrenceProperties =
                            RecurrenceProperties(startDate: _startDate);
                        widget.recurrenceProperties!.recurrenceType =
                            RecurrenceType.weekly;
                        widget.recurrenceProperties!.interval = 1;
                        widget.recurrenceProperties!.recurrenceRange =
                            RecurrenceRange.noEndDate;
                        widget.recurrenceProperties!.weekDays = _startDate
                                    .weekday ==
                                1
                            ? <WeekDays>[WeekDays.monday]
                            : _startDate.weekday == 2
                                ? <WeekDays>[WeekDays.tuesday]
                                : _startDate.weekday == 3
                                    ? <WeekDays>[WeekDays.wednesday]
                                    : _startDate.weekday == 4
                                        ? <WeekDays>[WeekDays.thursday]
                                        : _startDate.weekday == 5
                                            ? <WeekDays>[WeekDays.friday]
                                            : _startDate.weekday == 6
                                                ? <WeekDays>[WeekDays.saturday]
                                                : <WeekDays>[WeekDays.sunday];
                        widget.onChanged(
                            PickerChangedDetails(selectedRule: _rule));
                      }
                    });
                    Navigator.pop(context, widget.recurrenceProperties);
                  },
                ),
                RadioListTile<SelectRule>(
                  title: const Text('Every month'),
                  value: SelectRule.everyMonth,
                  toggleable: true,
                  groupValue: _rule,
                  activeColor: widget.model.backgroundColor,
                  onChanged: (SelectRule? value) {
                    setState(() {
                      if (value != null) {
                        _rule = value;
                        widget.recurrenceProperties =
                            RecurrenceProperties(startDate: _startDate);
                        widget.recurrenceProperties!.recurrenceType =
                            RecurrenceType.monthly;
                        widget.recurrenceProperties!.interval = 1;
                        widget.recurrenceProperties!.recurrenceRange =
                            RecurrenceRange.noEndDate;
                        widget.recurrenceProperties!.dayOfMonth =
                            widget.selectedAppointment!.startTime.day;
                        widget.onChanged(
                            PickerChangedDetails(selectedRule: _rule));
                      }
                    });
                    Navigator.pop(context, widget.recurrenceProperties);
                  },
                ),
                RadioListTile<SelectRule>(
                  title: const Text('Every year'),
                  value: SelectRule.everyYear,
                  toggleable: true,
                  groupValue: _rule,
                  activeColor: widget.model.backgroundColor,
                  onChanged: (SelectRule? value) {
                    setState(() {
                      if (value != null) {
                        _rule = value;
                        widget.recurrenceProperties =
                            RecurrenceProperties(startDate: _startDate);
                        widget.recurrenceProperties!.recurrenceType =
                            RecurrenceType.yearly;
                        widget.recurrenceProperties!.interval = 1;
                        widget.recurrenceProperties!.recurrenceRange =
                            RecurrenceRange.noEndDate;
                        widget.recurrenceProperties!.month =
                            widget.selectedAppointment!.startTime.month;
                        widget.recurrenceProperties!.dayOfMonth =
                            widget.selectedAppointment!.startTime.day;
                        widget.onChanged(
                            PickerChangedDetails(selectedRule: _rule));
                      }
                    });
                    Navigator.pop(context, widget.recurrenceProperties);
                  },
                ),
                RadioListTile<SelectRule>(
                  title: const Text('Custom'),
                  value: SelectRule.custom,
                  toggleable: true,
                  groupValue: _rule,
                  activeColor: widget.model.backgroundColor,
                  onChanged: (SelectRule? value) async {
                    final dynamic properties = await Navigator.push<dynamic>(
                      context,
                      MaterialPageRoute<dynamic>(
                          builder: (BuildContext context) => CustomRule(
                              widget.model,
                              widget.selectedAppointment!,
                              widget.appointmentColor,
                              widget.events,
                              widget.recurrenceProperties)),
                    );
                    if (properties != widget.recurrenceProperties) {
                      setState(() {
                        _rule = SelectRule.custom;
                        widget.onChanged(
                            PickerChangedDetails(selectedRule: _rule));
                      });
                    }
                    Navigator.pop(context, properties);
                  },
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}