import 'package:flutter/material.dart';
import 'package:medicpro/src/models/model.dart';
import 'package:medicpro/src/models/models.dart';
import 'package:medicpro/src/providers/providers.dart';
import 'package:medicpro/src/themes/theme.dart';
import 'package:medicpro/src/utils/funciones.dart';
import 'package:medicpro/src/utils/variables.dart';
import 'package:medicpro/src/widgets/widgets.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';

/// Builds the appointment editor with all the required elements based on the
/// tapped calendar element for mobile.
class AppointmentEditor extends StatefulWidget {
  /// Holds the value of appointment editor
  const AppointmentEditor(this.model, this.selectedAppointment,
      this.targetElement, this.selectedDate, this.colorCollection, this.events,
      [this.selectedResource]);

  /// Current sample model
  final SampleModel model;

  /// Selected appointment
  final Appointment? selectedAppointment;

  /// Calendar element
  final CalendarElement targetElement;

  /// Seelcted date value
  final DateTime selectedDate;

  /// Collection of colors
  final List<TiposConsultas> colorCollection;

  /// Holds the events value
  final CalendarDataSource events;

  /// Selected calendar resource
  final CalendarResource? selectedResource;

  @override
  _AppointmentEditorState createState() => _AppointmentEditorState();
}

class _AppointmentEditorState extends State<AppointmentEditor> {
  int _selectedColorIndex = 0;
  late DateTime _startDate;
  late TimeOfDay _startTime;
  late DateTime _endDate;
  late TimeOfDay _endTime;
  bool _isAllDay = false;
  String _subject = '';
  String? _notes;
  String? _location;
  List<Object>? _resourceIds;
  List<CalendarResource> _selectedResources = <CalendarResource>[];
  List<CalendarResource> _unSelectedResources = <CalendarResource>[];

  RecurrenceProperties? _recurrenceProperties;
  late RecurrenceType _recurrenceType;
  RecurrenceRange? _recurrenceRange;
  late int _interval;

  SelectRule? _rule = SelectRule.doesNotRepeat;

  @override
  void initState() {
    _updateAppointmentProperties();
    super.initState();
  }

  @override
  void didUpdateWidget(AppointmentEditor oldWidget) {
    _updateAppointmentProperties();
    super.didUpdateWidget(oldWidget);
  }

  /// Updates the required editor's default field
  void _updateAppointmentProperties() {
    if (widget.selectedAppointment != null) {
      _startDate = widget.selectedAppointment!.startTime;
      _endDate = widget.selectedAppointment!.endTime;
      _isAllDay = widget.selectedAppointment!.isAllDay;
      _selectedColorIndex = widget.colorCollection.indexWhere(
          (element) => element.tk == widget.selectedAppointment!.recurrenceId);
      _subject = widget.selectedAppointment!.subject == '(No title)'
          ? ''
          : widget.selectedAppointment!.subject;
      _notes = widget.selectedAppointment!.notes;
      _location = widget.selectedAppointment!.location;
      _resourceIds = widget.selectedAppointment!.resourceIds?.sublist(0);
      _recurrenceProperties =
          widget.selectedAppointment!.recurrenceRule != null &&
                  widget.selectedAppointment!.recurrenceRule!.isNotEmpty
              ? SfCalendar.parseRRule(
                  widget.selectedAppointment!.recurrenceRule!, _startDate)
              : null;
      if (_recurrenceProperties == null) {
        _rule = SelectRule.doesNotRepeat;
      } else {
        _updateMobileRecurrenceProperties();
      }
    } else {
      _isAllDay = widget.targetElement == CalendarElement.allDayPanel;
      _selectedColorIndex = 0;
      _subject = '';
      _notes = '';
      _location = '';

      final DateTime date = widget.selectedDate;
      _startDate = date;
      _endDate = date.add(const Duration(hours: 1));
      if (widget.selectedResource != null) {
        _resourceIds = <Object>[widget.selectedResource!.id];
      }
      _rule = SelectRule.doesNotRepeat;
      _recurrenceProperties = null;
    }

    _startTime = TimeOfDay(hour: _startDate.hour, minute: _startDate.minute);
    _endTime = TimeOfDay(hour: _endDate.hour, minute: _endDate.minute);
    _selectedResources =
        getSelectedResources(_resourceIds, widget.events.resources);
    _unSelectedResources =
        getUnSelectedResources(_selectedResources, widget.events.resources);
  }

  void _updateMobileRecurrenceProperties() {
    _recurrenceType = _recurrenceProperties!.recurrenceType;
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

  Widget _getAppointmentEditor(
      BuildContext context, Color backgroundColor, Color defaultColor) {
    return Container(
        color: backgroundColor,
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: <Widget>[
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
              leading: const Text(''),
              title: TextField(
                controller: TextEditingController(text: _subject),
                onChanged: (String value) {
                  _subject = value;
                },
                keyboardType: TextInputType.multiline,
                maxLines: null,
                style: TextStyle(
                    fontSize: 25,
                    color: defaultColor,
                    fontWeight: FontWeight.w400),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Add title',
                ),
              ),
            ),
            const Divider(
              height: 1.0,
              thickness: 1,
            ),
            ListTile(
                contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
                leading: Icon(
                  Icons.access_time,
                  color: defaultColor,
                ),
                title: Row(children: <Widget>[
                  const Expanded(
                    child: Text('All-day'),
                  ),
                  Expanded(
                      child: Align(
                          alignment: Alignment.centerRight,
                          child: Switch(
                            value: _isAllDay,
                            onChanged: (bool value) {
                              setState(() {
                                _isAllDay = value;
                              });
                            },
                          ))),
                ])),
            ListTile(
                contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
                leading: const Text(''),
                title: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        flex: 7,
                        child: GestureDetector(
                          onTap: () async {
                            final DateTime? date = await showDatePicker(
                                context: context,
                                initialDate: _startDate,
                                firstDate: DateTime(1900),
                                lastDate: DateTime(2100),
                                builder: (BuildContext context, Widget? child) {
                                  return Theme(
                                    data: ThemeData(
                                      brightness: temaApp.brightness,
                                      colorScheme:
                                          getColorScheme(widget.model, true),
                                      primaryColor:
                                          widget.model.backgroundColor,
                                    ),
                                    child: child!,
                                  );
                                });

                            if (date != null && date != _startDate) {
                              setState(() {
                                final Duration difference =
                                    _endDate.difference(_startDate);
                                _startDate = DateTime(
                                    date.year,
                                    date.month,
                                    date.day,
                                    _startTime.hour,
                                    _startTime.minute,
                                    0);
                                _endDate = _startDate.add(difference);
                                _endTime = TimeOfDay(
                                    hour: _endDate.hour,
                                    minute: _endDate.minute);
                              });
                            }
                          },
                          child: Text(
                              DateFormat('EEE, MMM dd yyyy').format(_startDate),
                              textAlign: TextAlign.left),
                        ),
                      ),
                      Expanded(
                          flex: 3,
                          child: _isAllDay
                              ? const Text('')
                              : GestureDetector(
                                  onTap: () async {
                                    final TimeOfDay? time =
                                        await showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay(
                                                hour: _startTime.hour,
                                                minute: _startTime.minute),
                                            builder: (BuildContext context,
                                                Widget? child) {
                                              return Theme(
                                                data: ThemeData(
                                                  brightness:
                                                      temaApp.brightness,
                                                  colorScheme: getColorScheme(
                                                      widget.model, false),
                                                  primaryColor: widget
                                                      .model.backgroundColor,
                                                ),
                                                child: child!,
                                              );
                                            });

                                    if (time != null && time != _startTime) {
                                      setState(
                                        () {
                                          _startTime = time;
                                          final Duration difference =
                                              _endDate.difference(_startDate);
                                          _startDate = DateTime(
                                              _startDate.year,
                                              _startDate.month,
                                              _startDate.day,
                                              _startTime.hour,
                                              _startTime.minute,
                                              0);
                                          _endDate = _startDate.add(difference);
                                          _endTime = TimeOfDay(
                                              hour: _endDate.hour,
                                              minute: _endDate.minute);
                                        },
                                      );
                                    }
                                  },
                                  child: Text(
                                    DateFormat('hh:mm a').format(_startDate),
                                    textAlign: TextAlign.right,
                                  ),
                                )),
                    ])),
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
              leading: const Text(''),
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 7,
                    child: GestureDetector(
                      onTap: () async {
                        final DateTime? date = await showDatePicker(
                            context: context,
                            initialDate: _endDate,
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2100),
                            builder: (BuildContext context, Widget? child) {
                              return Theme(
                                data: ThemeData(
                                  brightness: temaApp.brightness,
                                  colorScheme:
                                      getColorScheme(widget.model, true),
                                  primaryColor: widget.model.backgroundColor,
                                ),
                                child: child!,
                              );
                            });

                        if (date != null && date != _endDate) {
                          setState(() {
                            final Duration difference =
                                _endDate.difference(_startDate);
                            _endDate = DateTime(date.year, date.month, date.day,
                                _endTime.hour, _endTime.minute, 0);
                            if (_endDate.isBefore(_startDate)) {
                              _startDate = _endDate.subtract(difference);
                              _startTime = TimeOfDay(
                                  hour: _startDate.hour,
                                  minute: _startDate.minute);
                            }
                          });
                        }
                      },
                      child: Text(
                        DateFormat('EEE, dd MMM yyyy').format(_endDate),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: _isAllDay
                        ? const Text('')
                        : GestureDetector(
                            onTap: () async {
                              final TimeOfDay? time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay(
                                      hour: _endTime.hour,
                                      minute: _endTime.minute),
                                  builder:
                                      (BuildContext context, Widget? child) {
                                    return Theme(
                                      data: ThemeData(
                                        brightness: temaApp.brightness,
                                        colorScheme:
                                            getColorScheme(widget.model, false),
                                        primaryColor:
                                            widget.model.backgroundColor,
                                      ),
                                      child: child!,
                                    );
                                  });

                              if (time != null && time != _endTime) {
                                setState(
                                  () {
                                    _endTime = time;
                                    final Duration difference =
                                        _endDate.difference(_startDate);
                                    _endDate = DateTime(
                                        _endDate.year,
                                        _endDate.month,
                                        _endDate.day,
                                        _endTime.hour,
                                        _endTime.minute,
                                        0);
                                    if (_endDate.isBefore(_startDate)) {
                                      _startDate =
                                          _endDate.subtract(difference);
                                      _startTime = TimeOfDay(
                                          hour: _startDate.hour,
                                          minute: _startDate.minute);
                                    }
                                  },
                                );
                              }
                            },
                            child: Text(
                              DateFormat('hh:mm a').format(_endDate),
                              textAlign: TextAlign.right,
                            ),
                          ),
                  ),
                ],
              ),
            ),
            if (widget.events.resources == null ||
                widget.events.resources!.isEmpty)
              Container()
            else
              ListTile(
                contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
                leading: Icon(Icons.people, color: defaultColor),
                title: _getResourceEditor(TextStyle(
                    fontSize: 18,
                    color: defaultColor,
                    fontWeight: FontWeight.w300)),
                onTap: () {
                  showDialog<Widget>(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) {
                      return ResourcePicker(
                        _unSelectedResources,
                        widget.model,
                        onChanged: (PickerChangedDetails details) {
                          _resourceIds = _resourceIds == null
                              ? <Object>[details.resourceId!]
                              : (_resourceIds!.sublist(0)
                                ..add(details.resourceId!));
                          _selectedResources = getSelectedResources(
                              _resourceIds, widget.events.resources);
                          _unSelectedResources = getUnSelectedResources(
                              _selectedResources, widget.events.resources);
                        },
                      );
                    },
                  ).then((dynamic value) => setState(() {
                        /// update the color picker changes
                      }));
                },
              ),
            const Divider(
              height: 1.0,
              thickness: 1,
            ),
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
              leading: Icon(Icons.lens,
                  color: HexColor.fromHex(widget
                      .colorCollection[_selectedColorIndex].backgroundColor)),
              title: Text(
                widget.colorCollection[_selectedColorIndex].tipoconsulta,
              ),
              onTap: () {
                showDialog<Widget>(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) {
                    return CalendarColorPicker(
                      widget.colorCollection,
                      _selectedColorIndex,
                      widget.colorCollection,
                      widget.model,
                      onChanged: (PickerChangedDetails details) {
                        _selectedColorIndex = details.index;
                      },
                    );
                  },
                ).then((dynamic value) => setState(() {
                      /// update the color picker changes
                    }));
              },
            ),
            const Divider(
              height: 1.0,
              thickness: 1,
            ),
            if (widget.model.isWebFullView)
              ListTile(
                contentPadding: const EdgeInsets.all(5),
                leading: Icon(
                  Icons.location_on,
                  color: defaultColor,
                ),
                title: TextField(
                  controller: TextEditingController(text: _location),
                  onChanged: (String value) {
                    _location = value;
                  },
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  style: TextStyle(
                      fontSize: 18,
                      color: defaultColor,
                      fontWeight: FontWeight.w300),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Add location',
                  ),
                ),
              )
            else
              Container(),
            if (widget.model.isWebFullView)
              const Divider(
                height: 1.0,
                thickness: 1,
              )
            else
              Container(),
            ListTile(
              contentPadding: const EdgeInsets.all(5),
              leading: Icon(
                Icons.subject,
                color: defaultColor,
              ),
              title: TextField(
                controller: TextEditingController(text: _notes),
                cursorColor: widget.model.backgroundColor,
                onChanged: (String value) {
                  _notes = value;
                },
                keyboardType: TextInputType.multiline,
                maxLines: widget.model.isWebFullView ? 1 : null,
                style: TextStyle(
                    fontSize: 18,
                    color: defaultColor,
                    fontWeight: FontWeight.w400),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Add description',
                ),
              ),
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: temaApp,
        child: Scaffold(
            backgroundColor: temaApp.brightness == Brightness.dark
                ? Colors.grey[850]
                : Colors.white,
            appBar: AppBar(
              backgroundColor: HexColor.fromHex(
                  widget.colorCollection[_selectedColorIndex].backgroundColor),
              leading: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              actions: <Widget>[
                IconButton(
                    padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                    icon: const Icon(
                      Icons.done,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (widget.selectedAppointment != null) {
                        if (widget.selectedAppointment!.appointmentType !=
                            AppointmentType.normal) {
                          final Appointment newAppointment = Appointment(
                            startTime: _startDate,
                            endTime: _endDate,
                            color: HexColor.fromHex(widget
                                .colorCollection[_selectedColorIndex]
                                .backgroundColor),
                            notes: _notes,
                            isAllDay: _isAllDay,
                            subject: _subject == '' ? '(No title)' : _subject,
                            recurrenceExceptionDates: widget
                                .selectedAppointment!.recurrenceExceptionDates,
                            resourceIds: _resourceIds,
                            id: widget.selectedAppointment!.id,
                            recurrenceId:
                                widget.selectedAppointment!.recurrenceId,
                            recurrenceRule: _recurrenceProperties == null
                                ? null
                                : SfCalendar.generateRRule(
                                    _recurrenceProperties!,
                                    _startDate,
                                    _endDate),
                          );
                          showDialog<Widget>(
                              context: context,
                              builder: (BuildContext context) {
                                return WillPopScope(
                                  onWillPop: () async {
                                    return true;
                                  },
                                  child: Theme(
                                    data: temaApp,
                                    // ignore: prefer_const_literals_to_create_immutables
                                    child: EditDialog(
                                      widget.model,
                                      newAppointment,
                                      widget.selectedAppointment!,
                                      _recurrenceProperties,
                                      widget.events,
                                    ),
                                  ),
                                );
                              });
                        } else {
                          final List<Appointment> appointment = <Appointment>[];
                          if (widget.selectedAppointment != null) {
                            widget.events.appointments!.removeAt(widget
                                .events.appointments!
                                .indexOf(widget.selectedAppointment));
                            widget.events.notifyListeners(
                                CalendarDataSourceAction.remove,
                                <Appointment>[widget.selectedAppointment!]);
                          }
                          appointment.add(Appointment(
                            startTime: _startDate,
                            endTime: _endDate,
                            color: HexColor.fromHex(widget
                                .colorCollection[_selectedColorIndex]
                                .backgroundColor),
                            notes: _notes,
                            isAllDay: _isAllDay,
                            subject: _subject == '' ? '(No title)' : _subject,
                            resourceIds: _resourceIds,
                            id: widget.selectedAppointment!.id,
                            recurrenceRule: _recurrenceProperties == null
                                ? null
                                : SfCalendar.generateRRule(
                                    _recurrenceProperties!,
                                    _startDate,
                                    _endDate),
                          ));
                          widget.events.appointments!.add(appointment[0]);

                          widget.events.notifyListeners(
                              CalendarDataSourceAction.add, appointment);
                          Navigator.pop(context);
                        }
                      } else {
                        final List<Appointment> appointment = <Appointment>[];
                        if (widget.selectedAppointment != null) {
                          widget.events.appointments!.removeAt(widget
                              .events.appointments!
                              .indexOf(widget.selectedAppointment));
                          widget.events.notifyListeners(
                              CalendarDataSourceAction.remove,
                              <Appointment>[widget.selectedAppointment!]);
                        }
                        appointment.add(Appointment(
                          startTime: _startDate,
                          endTime: _endDate,
                          color: HexColor.fromHex(widget
                              .colorCollection[_selectedColorIndex]
                              .backgroundColor),
                          notes: _notes,
                          isAllDay: _isAllDay,
                          subject: _subject == '' ? '(No title)' : _subject,
                          resourceIds: _resourceIds,
                          recurrenceRule: _rule == SelectRule.doesNotRepeat ||
                                  _recurrenceProperties == null
                              ? null
                              : SfCalendar.generateRRule(
                                  _recurrenceProperties!, _startDate, _endDate),
                        ));

                        widget.events.appointments!.add(appointment[0]);

                        widget.events.notifyListeners(
                            CalendarDataSourceAction.add, appointment);
                        Navigator.pop(context);
                      }
                    })
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
              child: Stack(
                children: <Widget>[
                  _getAppointmentEditor(
                      context,
                      (temaApp.brightness == Brightness.dark
                          ? Colors.grey[850]
                          : Colors.white)!,
                      temaApp.brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87)
                ],
              ),
            ),
            floatingActionButton: widget.model.isWebFullView
                ? null
                : widget.selectedAppointment == null
                    ? const Text('')
                    : FloatingActionButton(
                        onPressed: () {
                          if (widget.selectedAppointment != null) {
                            if (widget.selectedAppointment!.appointmentType ==
                                AppointmentType.normal) {
                              widget.events.appointments!.removeAt(widget
                                  .events.appointments!
                                  .indexOf(widget.selectedAppointment));
                              widget.events.notifyListeners(
                                  CalendarDataSourceAction.remove,
                                  <Appointment>[widget.selectedAppointment!]);
                              Navigator.pop(context);
                            } else {
                              showDialog<Widget>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return WillPopScope(
                                        onWillPop: () async {
                                          return true;
                                        },
                                        child: Theme(
                                          data: temaApp,
                                          // ignore: prefer_const_literals_to_create_immutables
                                          child: DeleteDialog(
                                              widget.model,
                                              widget.selectedAppointment!,
                                              widget.events),
                                        ));
                                  });
                            }
                          }
                        },
                        backgroundColor: widget.model.backgroundColor,
                        child: const Icon(Icons.delete_outline,
                            color: Colors.white),
                      )));
  }

  /// Return the resource editor to edit the resource collection for an
  /// appointment
  Widget _getResourceEditor(TextStyle hintTextStyle) {
    if (_selectedResources.isEmpty) {
      return Text('Add people', style: hintTextStyle);
    }

    final List<Widget> chipWidgets = <Widget>[];
    for (int i = 0; i < _selectedResources.length; i++) {
      final CalendarResource selectedResource = _selectedResources[i];
      chipWidgets.add(Chip(
        padding: const EdgeInsets.only(left: 0),
        avatar: CircleAvatar(
          backgroundColor: widget.model.backgroundColor,
          backgroundImage: selectedResource.image,
          child: selectedResource.image == null
              ? Text(selectedResource.displayName[0])
              : null,
        ),
        label: Text(selectedResource.displayName),
        onDeleted: () {
          _selectedResources.removeAt(i);
          _resourceIds?.removeAt(i);
          _unSelectedResources = getUnSelectedResources(
              _selectedResources, widget.events.resources);
          setState(() {});
        },
      ));
    }

    return Wrap(
      spacing: 6.0,
      runSpacing: 6.0,
      children: chipWidgets,
    );
  }
}
