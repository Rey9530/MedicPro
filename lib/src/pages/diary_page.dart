import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:medicpro/src/models/eventos_model.dart';
import 'package:medicpro/src/pages/pages.dart';
import 'package:medicpro/src/providers/providers.dart';
import 'package:medicpro/src/themes/theme.dart';
import 'package:medicpro/src/utils/funciones.dart';
import 'package:medicpro/src/utils/variables.dart';
import 'package:medicpro/src/widgets/widgets.dart';
import 'package:provider/provider.dart';

///calendar import
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_core/core.dart';

///Local import
import 'package:medicpro/src/models/sample_view.dart';
import 'package:medicpro/src/models/model.dart';

/// Render the widget of appointment editor calendar
class DiaryPage extends SampleView {
  /// creates the appointment editor
  const DiaryPage();

  @override
  _DiaryPageState createState() => _DiaryPageState();
}

class _DiaryPageState extends SampleViewState {
  _DiaryPageState();

  late List<Appointment> _appointments;
  late bool _isMobile;
  late bool _isloadin_events;
  late List<Appointment> _eventslist;

  late List<TiposConsultas> _colorCollection;
  late List<DateTime> _visibleDates;
  late _DataSource _events;
  late DateTime _initialSelectedDate;
  late CitasProvider _citasProvider;
  Appointment? _selectedAppointment;
  bool _isAllDay = false;
  String _subject = '';

  final List<CalendarView> allowedViews = <CalendarView>[
    CalendarView.day,
    CalendarView.week,
    CalendarView.workWeek,
    CalendarView.month,
    CalendarView.schedule
  ];

  final ScrollController controller = ScrollController();
  final CalendarController calendarController = CalendarController();

  /// Global key used to maintain the state,
  /// when we change the parent of the widget
  CalendarView _view = CalendarView.month;

  @override
  void initState() {
    _isMobile = false;
    calendarController.view = _view;
    _appointments = [];
    _events = _DataSource(_appointments);
    _selectedAppointment = null;
    _subject = '';
    _initialSelectedDate = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day, 0, 0, 0);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _citasProvider = Provider.of<CitasProvider>(context);
    _isloadin_events = _citasProvider.isLoading;
    _eventslist = _citasProvider.listEvents;

    //// Extra small devices (phones, 600px and down)
    //// @media only screen and (max-width: 600px) {...}
    ////
    //// Small devices (portrait tablets and large phones, 600px and up)
    //// @media only screen and (min-width: 600px) {...}
    ////
    //// Medium devices (landscape tablets, 768px and up)
    //// media only screen and (min-width: 768px) {...}
    ////
    //// Large devices (laptops/desktops, 992px and up)
    //// media only screen and (min-width: 992px) {...}
    ////
    //// Extra large devices (large laptops and desktops, 1200px and up)
    //// media only screen and (min-width: 1200px) {...}
    //// Default width to render the mobile UI in web, if the device width exceeds
    //// the given width agenda view will render the web UI.
    _isMobile = MediaQuery.of(context).size.width < 767;
  }

  @override
  Widget build(BuildContext context) {
    final double _screenHeight = MediaQuery.of(context).size.height;

    _events = _DataSource(_eventslist);

    final Widget _calendar = Theme(
      /// The key set here to maintain the state,
      ///  when we change the parent of the widget
      data: temaApp,
      child: _getAppointmentEditorCalendar(
        calendarController,
        _events,
        _onCalendarTapped,
        _onViewChanged,
        scheduleViewBuilder,
        _initialSelectedDate,
      ),
    );

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: (_isloadin_events)
            ? LoadingIndicater()
            : calendarController.view == CalendarView.month &&
                    model.isWebFullView &&
                    _screenHeight < 800
                ? Scrollbar(
                    isAlwaysShown: true,
                    controller: controller,
                    child: ListView(
                      controller: controller,
                      children: <Widget>[
                        Container(
                          color: model.cardThemeColor,
                          height: 600,
                          child: _calendar,
                        )
                      ],
                    ),
                  )
                : Container(
                    color: model.cardThemeColor,
                    child: _calendar,
                  ),
      ),
    );
  }

  /// Returns the builder for schedule view.
  Widget scheduleViewBuilder(
      BuildContext buildContext, ScheduleViewMonthHeaderDetails details) {
    final String monthName = getMonthDate(details.date.month);
    print(details.date);

    return Stack(
      children: <Widget>[
        Image(
          image: ExactAssetImage(
              'assets/meses/' + details.date.month.toString() + '.png'),
          fit: BoxFit.cover,
          width: details.bounds.width,
          height: details.bounds.height,
        ),
        Positioned(
          left: 55,
          right: 0,
          top: 20,
          bottom: 0,
          child: Text(
            monthName + ' ' + details.date.year.toString(),
            style: const TextStyle(fontSize: 18),
          ),
        )
      ],
    );
  }

  /// The method called whenever the calendar view navigated to previous/next
  /// view or switched to different calendar view.
  void _onViewChanged(ViewChangedDetails visibleDatesChangedDetails) { 

    //Actualizamos las fechas de inicio y fin antes de hacer la peticion a la api
    _citasProvider.fecha_inicio = visibleDatesChangedDetails.visibleDates[0];
    _citasProvider.fecha_fin = visibleDatesChangedDetails.visibleDates[visibleDatesChangedDetails.visibleDates.length - 1];
    //Se genera la peticion
    _citasProvider.getAllCitas();
    if (_view == calendarController.view ||
        !model.isWebFullView ||
        (_view != CalendarView.month &&
            calendarController.view != CalendarView.month)) {
      return;
    }

    SchedulerBinding.instance?.addPostFrameCallback((Duration timeStamp) {
      setState(() {
        _view = calendarController.view!;

        /// Update the current view when the calendar view changed to
        /// month view or from month view.
      });
    });
  }

  /// Navigates to appointment editor page when the calendar elements tapped
  /// other than the header, handled the editor fields based on tapped element.
  void _onCalendarTapped(CalendarTapDetails calendarTapDetails) {
    /// Condition added to open the editor, when the calendar elements tapped
    /// other than the header.
    if (calendarTapDetails.targetElement == CalendarElement.header ||
        calendarTapDetails.targetElement == CalendarElement.resourceHeader) {
      return;
    }

    _selectedAppointment = null;

    /// Navigates the calendar to day view,
    /// when we tap on month cells in mobile.
    if (!model.isWebFullView && calendarController.view == CalendarView.month) {
      calendarController.view = CalendarView.day;
    } else {
      if (calendarTapDetails.appointments != null &&
          calendarTapDetails.targetElement == CalendarElement.appointment) {
        final dynamic appointment = calendarTapDetails.appointments![0];
        if (appointment is Appointment) {
          _selectedAppointment = appointment;
        }
      }

      final DateTime selectedDate = calendarTapDetails.date!;
      final CalendarElement targetElement = calendarTapDetails.targetElement;

      /// To open the appointment editor for web,
      /// when the screen width is greater than 767.
      if (model.isWebFullView && !_isMobile) {
        final bool _isAppointmentTapped =
            calendarTapDetails.targetElement == CalendarElement.appointment;
        showDialog<Widget>(
            context: context,
            builder: (BuildContext context) {
              final List<Appointment> appointment = <Appointment>[];
              Appointment? newAppointment;

              /// Creates a new appointment, which is displayed on the tapped
              /// calendar element, when the editor is opened.
              if (_selectedAppointment == null) {
                _isAllDay = calendarTapDetails.targetElement ==
                    CalendarElement.allDayPanel;
                _subject = '';
                final DateTime date = calendarTapDetails.date!;

                newAppointment = Appointment(
                  startTime: date,
                  endTime: date.add(const Duration(hours: 1)),
                  color: Colors.red, // _colorCollection[_selectedColorIndex],
                  isAllDay: _isAllDay,
                  subject: _subject == '' ? '(No title)' : _subject,
                );
                appointment.add(newAppointment);

                _events.appointments.add(appointment[0]);

                SchedulerBinding.instance?.addPostFrameCallback(
                  (Duration duration) {
                    _events.notifyListeners(
                        CalendarDataSourceAction.add, appointment);
                  },
                );

                _selectedAppointment = newAppointment;
              }

              return WillPopScope(
                onWillPop: () async {
                  if (newAppointment != null) {
                    /// To remove the created appointment when the pop-up closed
                    /// without saving the appointment.
                    _events.appointments.removeAt(
                      _events.appointments.indexOf(newAppointment),
                    );
                    _events.notifyListeners(CalendarDataSourceAction.remove,
                        <Appointment>[newAppointment]);
                  }
                  return true;
                },
                child: Center(
                    child: Container(
                        alignment: Alignment.center,
                        width: _isAppointmentTapped ? 400 : 500,
                        height: _isAppointmentTapped
                            ? _selectedAppointment!.location == null ||
                                    _selectedAppointment!.location!.isEmpty
                                ? 150
                                : 200
                            : 390,
                        child: Theme(
                            data: temaApp,
                            child: Card(
                              margin: const EdgeInsets.all(0.0),
                              color: temaApp.brightness == Brightness.dark
                                  ? Colors.grey[850]
                                  : Colors.white,
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4))),
                              child: _isAppointmentTapped
                                  ? displayAppointmentDetails(
                                      context,
                                      targetElement,
                                      selectedDate,
                                      model,
                                      _selectedAppointment!,
                                      _colorCollection,
                                      _events,
                                      _visibleDates)
                                  : PopUpAppointmentEditor(
                                      model,
                                      newAppointment,
                                      appointment,
                                      _events,
                                      _colorCollection,
                                      _selectedAppointment!,
                                      _visibleDates),
                            )))),
              );
            });
      } else {
        /// Navigates to the appointment editor page on mobile
        Navigator.push<Widget>(
          context,
          MaterialPageRoute<Widget>(
            builder: (BuildContext context) => AppointmentEditor(
              model,
              _selectedAppointment,
              targetElement,
              selectedDate,
              _colorCollection,
              _events,
            ),
          ),
        );
      }
    }
  }

  /// Returns the calendar based on the properties passed.
  SfCalendar _getAppointmentEditorCalendar([
    CalendarController? _calendarController,
    CalendarDataSource? _calendarDataSource,
    dynamic calendarTapCallback,
    ViewChangedCallback? viewChangedCallback,
    dynamic scheduleViewBuilder,
    DateTime? initialSelectedDate,
  ]) {
    return SfCalendar(
      initialSelectedDate: initialSelectedDate,
      controller: _calendarController,
      showNavigationArrow: model.isWebFullView,
      allowedViews: allowedViews,
      showDatePickerButton: true,
      scheduleViewMonthHeaderBuilder: scheduleViewBuilder,
      dataSource: _calendarDataSource,
      onTap: calendarTapCallback,
      onViewChanged: viewChangedCallback,
      allowDragAndDrop: true,
      initialDisplayDate: initialSelectedDate,
      monthViewSettings: const MonthViewSettings(
        appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
        appointmentDisplayCount: 4,
      ),
      timeSlotViewSettings: const TimeSlotViewSettings(
        minimumAppointmentDuration: Duration(minutes: 60),
      ),
    );
  }
}

/// An object to set the appointment collection data source to collection, and
/// allows to add, remove or reset the appointment collection.
class _DataSource extends CalendarDataSource {
  _DataSource(this.source);

  List<Appointment> source;

  @override
  List<dynamic> get appointments => source;
}

/// Formats the tapped appointment time text, to display on the pop-up view.
String _getAppointmentTimeText(Appointment selectedAppointment) {
  if (selectedAppointment.isAllDay) {
    if (isSameDate(
        selectedAppointment.startTime, selectedAppointment.endTime)) {
      return DateFormat('EEEE, MMM dd')
          .format(selectedAppointment.startTime)
          .toString();
    }
    return DateFormat('EEEE, MMM dd').format(selectedAppointment.startTime) +
        ' - ' +
        DateFormat('EEEE, MMM dd')
            .format(selectedAppointment.endTime)
            .toString();
  } else if (selectedAppointment.startTime.day !=
          selectedAppointment.endTime.day ||
      selectedAppointment.startTime.month !=
          selectedAppointment.endTime.month ||
      selectedAppointment.startTime.year != selectedAppointment.endTime.year) {
    String endFormat = 'EEEE, ';
    if (selectedAppointment.startTime.month !=
        selectedAppointment.endTime.month) {
      endFormat += 'MMM';
    }

    endFormat += ' dd hh:mm a';
    return DateFormat('EEEE, MMM dd hh:mm a')
            .format(selectedAppointment.startTime) +
        ' - ' +
        DateFormat(endFormat).format(selectedAppointment.endTime);
  } else {
    return DateFormat('EEEE, MMM dd hh:mm a')
            .format(selectedAppointment.startTime) +
        ' - ' +
        DateFormat('hh:mm a').format(selectedAppointment.endTime);
  }
}

/// To edit the series which has the exception appointments, and allows
/// to edit and cancel the edit series action.
Widget _editExceptionSeries(
    BuildContext context,
    SampleModel model,
    Appointment selectedAppointment,
    Appointment recurrenceAppointment,
    CalendarDataSource events) {
  final Color defaultColor =
      temaApp.brightness == Brightness.dark ? Colors.white : Colors.black54;

  final Color defaultTextColor =
      temaApp.brightness == Brightness.dark ? Colors.white : Colors.black87;

  return Dialog(
    child: Container(
      width: 400,
      height: 200,
      padding: const EdgeInsets.only(left: 20, top: 10),
      child: ListView(padding: const EdgeInsets.all(0.0), children: <Widget>[
        Container(
          width: 360,
          height: 50,
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: <Widget>[
              Expanded(
                  flex: 8,
                  child: Text(
                    'Alert',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: defaultTextColor),
                  )),
              Expanded(
                flex: 2,
                child: IconButton(
                  splashRadius: 15,
                  tooltip: 'Close',
                  icon: Icon(Icons.close, color: defaultColor),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
        Container(
            width: 360,
            height: 80,
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
                'Do you want to cancel the changes made to specific instances of this series and match it to the whole series again?',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w300,
                    color: defaultTextColor))),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            RawMaterialButton(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
              fillColor: model.backgroundColor,
              onPressed: () {
                Navigator.pop(context);
                final List<DateTime>? exceptionDates =
                    selectedAppointment.recurrenceExceptionDates;
                for (int i = 0; i < exceptionDates!.length; i++) {
                  final Appointment? changedOccurrence =
                      events.getOccurrenceAppointment(
                          selectedAppointment, exceptionDates[i], '');
                  if (changedOccurrence != null) {
                    events.appointments!.removeAt(
                        events.appointments!.indexOf(changedOccurrence));
                    events.notifyListeners(CalendarDataSourceAction.remove,
                        <Appointment>[changedOccurrence]);
                  }
                }
                events.appointments!.removeAt(
                    events.appointments!.indexOf(selectedAppointment));
                events.notifyListeners(CalendarDataSourceAction.remove,
                    <Appointment>[selectedAppointment]);
                events.appointments!.add(recurrenceAppointment);
                events.notifyListeners(CalendarDataSourceAction.add,
                    <Appointment>[recurrenceAppointment]);
                Navigator.pop(context);
              },
              child: const Text(
                'YES',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
            Container(
              width: 20,
            ),
            RawMaterialButton(
              onPressed: () {
                Navigator.pop(context);
                recurrenceAppointment.recurrenceExceptionDates =
                    selectedAppointment.recurrenceExceptionDates;
                recurrenceAppointment.recurrenceRule =
                    selectedAppointment.recurrenceRule;
                events.appointments!.removeAt(
                    events.appointments!.indexOf(selectedAppointment));
                events.notifyListeners(CalendarDataSourceAction.remove,
                    <Appointment>[selectedAppointment]);
                events.appointments!.add(recurrenceAppointment);
                events.notifyListeners(CalendarDataSourceAction.add,
                    <Appointment>[recurrenceAppointment]);
                Navigator.pop(context);
              },
              child: Text(
                'NO',
                style: TextStyle(
                    fontWeight: FontWeight.w500, color: defaultTextColor),
              ),
            ),
            Container(
              width: 20,
            ),
            RawMaterialButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'CANCEL',
                style: TextStyle(
                    fontWeight: FontWeight.w500, color: defaultTextColor),
              ),
            ),
            Container(
              width: 20,
            ),
          ],
        ),
      ]),
    ),
  );
}

/// Allows to delete the single appointment from a series and
/// delete the entire series.
Widget _deleteRecurrence(BuildContext context, SampleModel model,
    Appointment selectedAppointment, CalendarDataSource events) {
  final Color defaultColor =
      temaApp.brightness == Brightness.dark ? Colors.white : Colors.black54;

  final Color defaultTextColor =
      temaApp.brightness == Brightness.dark ? Colors.white : Colors.black87;

  return Dialog(
      child: Container(
    width: 400,
    height: 170,
    padding: const EdgeInsets.only(left: 20, top: 10),
    child: ListView(padding: const EdgeInsets.all(0.0), children: <Widget>[
      Container(
        width: 360,
        height: 50,
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: <Widget>[
            Expanded(
                flex: 8,
                child: Text(
                  'Delete Event',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: defaultTextColor),
                )),
            Expanded(
              flex: 2,
              child: IconButton(
                splashRadius: 15,
                tooltip: 'Close',
                icon: Icon(Icons.close, color: defaultColor),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
      Container(
          width: 360,
          height: 50,
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
              'How would you like to change the appointment in the series?',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w300,
                  color: defaultTextColor))),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            width: 110,
            child: RawMaterialButton(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
              fillColor: model.backgroundColor,
              onPressed: () {
                if (selectedAppointment.recurrenceId != null) {
                  events.appointments!.remove(selectedAppointment);
                  events.notifyListeners(CalendarDataSourceAction.remove,
                      <Appointment>[selectedAppointment]);
                }
                final Appointment? parentAppointment =
                    events.getPatternAppointment(selectedAppointment, '')
                        as Appointment?;
                events.appointments!
                    .removeAt(events.appointments!.indexOf(parentAppointment));
                events.notifyListeners(CalendarDataSourceAction.remove,
                    <Appointment>[parentAppointment!]);
                parentAppointment.recurrenceExceptionDates != null
                    ? parentAppointment.recurrenceExceptionDates!
                        .add(selectedAppointment.startTime)
                    : parentAppointment.recurrenceExceptionDates = <DateTime>[
                        selectedAppointment.startTime
                      ];
                events.appointments!.add(parentAppointment);
                events.notifyListeners(CalendarDataSourceAction.add,
                    <Appointment>[parentAppointment]);
                Navigator.pop(context);
              },
              child: const Text(
                'DELETE EVENT',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Container(
            width: 20,
          ),
          Container(
            width: 110,
            child: RawMaterialButton(
              onPressed: () {
                final Appointment? parentAppointment =
                    events.getPatternAppointment(selectedAppointment, '')
                        as Appointment?;
                if (parentAppointment!.recurrenceExceptionDates == null) {
                  events.appointments!.removeAt(
                      events.appointments!.indexOf(parentAppointment));
                  events.notifyListeners(CalendarDataSourceAction.remove,
                      <Appointment>[parentAppointment]);
                } else {
                  final List<DateTime>? exceptionDates =
                      parentAppointment.recurrenceExceptionDates;
                  for (int i = 0; i < exceptionDates!.length; i++) {
                    final Appointment? changedOccurrence =
                        events.getOccurrenceAppointment(
                            parentAppointment, exceptionDates[i], '');
                    if (changedOccurrence != null) {
                      events.appointments!.remove(changedOccurrence);
                      events.notifyListeners(CalendarDataSourceAction.remove,
                          <Appointment>[changedOccurrence]);
                    }
                  }
                  events.appointments!.removeAt(
                      events.appointments!.indexOf(parentAppointment));
                  events.notifyListeners(CalendarDataSourceAction.remove,
                      <Appointment>[parentAppointment]);
                }
                Navigator.pop(context);
              },
              child: Text(
                'ENTIRE SERIES',
                style: TextStyle(
                    fontWeight: FontWeight.w500, color: defaultTextColor),
              ),
            ),
          ),
          Container(
            width: 20,
          ),
        ],
      ),
    ]),
  ));
}

/// Allows to edit single appointment from a series and edit entire series.
Widget _editRecurrence(
    BuildContext context,
    SampleModel model,
    Appointment selectedAppointment,
    List<TiposConsultas> colorCollection,
    CalendarDataSource events,
    List<DateTime> visibleDates) {
  final Color defaultColor =
      temaApp.brightness == Brightness.dark ? Colors.white : Colors.black54;

  final Color defaultTextColor =
      temaApp.brightness == Brightness.dark ? Colors.white : Colors.black87;

  final List<Appointment> appointmentCollection = <Appointment>[];
  final Appointment? parentAppointment =
      events.getPatternAppointment(selectedAppointment, '') as Appointment?;

  return Dialog(
      child: Container(
    width: 400,
    height: 170,
    padding: const EdgeInsets.only(left: 20, top: 10),
    child: ListView(padding: const EdgeInsets.all(0.0), children: <Widget>[
      Container(
        width: 360,
        height: 50,
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: <Widget>[
            Expanded(
                flex: 8,
                child: Text(
                  'Edit Event',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: defaultTextColor),
                )),
            Expanded(
              flex: 2,
              child: IconButton(
                splashRadius: 20,
                tooltip: 'Close',
                icon: Icon(Icons.close, color: defaultColor),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
      Container(
          width: 360,
          height: 50,
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
              'How would you like to change the appointment in the series?',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w300,
                  color: defaultTextColor))),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          RawMaterialButton(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
            fillColor: model.backgroundColor,
            onPressed: () {
              selectedAppointment.recurrenceId = parentAppointment!.id;
              selectedAppointment.id = selectedAppointment.appointmentType ==
                      AppointmentType.changedOccurrence
                  ? selectedAppointment.id
                  : null;
              selectedAppointment.recurrenceRule = null;
              Navigator.pop(context);
              showDialog<Widget>(
                  context: context,
                  builder: (BuildContext context) {
                    return WillPopScope(
                        onWillPop: () async {
                          return true;
                        },
                        child: Theme(
                          data: temaApp,
                          child: AppointmentEditorWeb(
                              model,
                              selectedAppointment,
                              colorCollection,
                              events,
                              appointmentCollection,
                              visibleDates),
                        ));
                  });
            },
            child: const Text(
              'EDIT EVENT',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            width: 20,
          ),
          RawMaterialButton(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            onPressed: () {
              Navigator.pop(context);
              showDialog<Widget>(
                  context: context,
                  builder: (BuildContext context) {
                    return WillPopScope(
                        onWillPop: () async {
                          return true;
                        },
                        child: Theme(
                          data: temaApp,
                          child: AppointmentEditorWeb(
                            model,
                            parentAppointment!,
                            colorCollection,
                            events,
                            appointmentCollection,
                            visibleDates,
                          ),
                        ));
                  });
            },
            child: Text(
              'ENTIRE SERIES',
              style: TextStyle(
                  fontWeight: FontWeight.w500, color: defaultTextColor),
            ),
          ),
          Container(
            width: 20,
          ),
        ],
      ),
    ]),
  ));
}

/// Displays the tapped appointment details in a pop-up view.
Widget displayAppointmentDetails(
    BuildContext context,
    CalendarElement targetElement,
    DateTime selectedDate,
    SampleModel model,
    Appointment selectedAppointment,
    List<TiposConsultas> colorCollection,
    CalendarDataSource events,
    List<DateTime> visibleDates) {
  final Color defaultColor =
      temaApp.brightness == Brightness.dark ? Colors.white : Colors.black54;

  final Color defaultTextColor =
      temaApp.brightness == Brightness.dark ? Colors.white : Colors.black87;

  final List<Appointment> appointmentCollection = <Appointment>[];

  return ListView(padding: const EdgeInsets.all(0.0), children: <Widget>[
    ListTile(
        trailing: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        IconButton(
          splashRadius: 20,
          icon: Icon(Icons.edit, color: defaultColor),
          onPressed: () {
            Navigator.pop(context);
            showDialog<Widget>(
                context: context,
                builder: (BuildContext context) {
                  return WillPopScope(
                      onWillPop: () async {
                        return true;
                      },
                      child: Theme(
                        data: temaApp,
                        child: selectedAppointment.appointmentType ==
                                AppointmentType.normal
                            ? AppointmentEditorWeb(
                                model,
                                selectedAppointment,
                                colorCollection,
                                events,
                                appointmentCollection,
                                visibleDates,
                              )
                            : _editRecurrence(
                                context,
                                model,
                                selectedAppointment,
                                colorCollection,
                                events,
                                visibleDates),
                      ));
                });
          },
        ),
        IconButton(
          icon: Icon(Icons.delete, color: defaultColor),
          splashRadius: 20,
          onPressed: () {
            if (selectedAppointment.appointmentType == AppointmentType.normal) {
              Navigator.pop(context);
              events.appointments!
                  .removeAt(events.appointments!.indexOf(selectedAppointment));
              events.notifyListeners(CalendarDataSourceAction.remove,
                  <Appointment>[selectedAppointment]);
            } else {
              Navigator.pop(context);
              showDialog<Widget>(
                  context: context,
                  builder: (BuildContext context) {
                    return WillPopScope(
                        onWillPop: () async {
                          return true;
                        },
                        child: Theme(
                          data: temaApp,
                          child: _deleteRecurrence(
                              context, model, selectedAppointment, events),
                        ));
                  });
            }
          },
        ),
        IconButton(
          splashRadius: 20,
          icon: Icon(Icons.close, color: defaultColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    )),
    ListTile(
        leading: Icon(
          Icons.lens,
          color: selectedAppointment.color,
          size: 20,
        ),
        title: Text(
            selectedAppointment.subject.isNotEmpty
                ? selectedAppointment.subject
                : '(No Text)',
            style: TextStyle(
                fontSize: 20,
                color: defaultTextColor,
                fontWeight: FontWeight.w400)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            _getAppointmentTimeText(selectedAppointment),
            style: TextStyle(
                fontSize: 15,
                color: defaultTextColor,
                fontWeight: FontWeight.w400),
          ),
        )),
    if (selectedAppointment.resourceIds == null ||
        selectedAppointment.resourceIds!.isEmpty)
      Container()
    else
      ListTile(
        leading: Icon(
          Icons.people,
          size: 20,
          color: defaultColor,
        ),
        title: Text(
            _getSelectedResourceText(
                selectedAppointment.resourceIds!, events.resources!),
            style: TextStyle(
                fontSize: 15,
                color: defaultTextColor,
                fontWeight: FontWeight.w400)),
      ),
    if (selectedAppointment.location == null ||
        selectedAppointment.location!.isEmpty)
      Container()
    else
      ListTile(
        leading: Icon(
          Icons.location_on,
          size: 20,
          color: defaultColor,
        ),
        title: Text(selectedAppointment.location ?? '',
            style: TextStyle(
                fontSize: 15,
                color: defaultColor,
                fontWeight: FontWeight.w400)),
      )
  ]);
}

/// Returns the selected resource display name based on the ids passed.
String _getSelectedResourceText(
    List<Object> resourceIds, List<CalendarResource> resourceCollection) {
  String? resourceNames;
  for (int i = 0; i < resourceIds.length; i++) {
    final String name = resourceCollection
        .firstWhere(
            (CalendarResource resource) => resource.id == resourceIds[i])
        .displayName;
    resourceNames = resourceNames == null ? name : resourceNames + ', ' + name;
  }

  return resourceNames!;
}

/// Builds the appointment editor with minimal elements in a pop-up based on the
/// tapped calendar element.
class PopUpAppointmentEditor extends StatefulWidget {
  /// Holds the data of appointment editor
  const PopUpAppointmentEditor(
      this.model,
      this.newAppointment,
      this.appointment,
      this.events,
      this.colorCollection,
      this.selectedAppointment,
      this.visibleDates);

  /// Model of appointment editor
  final SampleModel model;

  /// new appointment value
  final Appointment? newAppointment;

  /// List of appointments
  final List<Appointment> appointment;

  /// Holds the events value
  final CalendarDataSource events;

  /// Holds list of colors
  final List<TiposConsultas> colorCollection;

  /// Selected appointment value
  final Appointment selectedAppointment;

  /// The current visible dates collection
  final List<DateTime> visibleDates;

  @override
  _PopUpAppointmentEditorState createState() => _PopUpAppointmentEditorState();
}

class _PopUpAppointmentEditorState extends State<PopUpAppointmentEditor> {
  int _selectedColorIndex = 0;
  late DateTime _startDate;
  late DateTime _endDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  bool _isAllDay = false;
  String _subject = '';
  String? _notes;
  String? _location;
  List<Object>? _resourceIds;
  List<CalendarResource> _selectedResources = <CalendarResource>[];
  List<CalendarResource> _unSelectedResources = <CalendarResource>[];

  @override
  void initState() {
    _updateAppointmentProperties();
    super.initState();
  }

  @override
  void didUpdateWidget(PopUpAppointmentEditor oldWidget) {
    _updateAppointmentProperties();
    super.didUpdateWidget(oldWidget);
  }

  /// Updates the required editor's default field
  void _updateAppointmentProperties() {
    _startDate = widget.selectedAppointment.startTime;
    _endDate = widget.selectedAppointment.endTime;
    _isAllDay = widget.selectedAppointment.isAllDay;
    _selectedColorIndex = widget.colorCollection.indexWhere(
        (element) => element.tk == widget.selectedAppointment.recurrenceId);

    _subject = widget.selectedAppointment.subject == '(No title)'
        ? ''
        : widget.selectedAppointment.subject;
    _notes = widget.selectedAppointment.notes;
    _location = widget.selectedAppointment.location;

    _selectedColorIndex = _selectedColorIndex == -1 ? 0 : _selectedColorIndex;
    _resourceIds = widget.selectedAppointment.resourceIds?.sublist(0);

    _startTime = TimeOfDay(hour: _startDate.hour, minute: _startDate.minute);
    _endTime = TimeOfDay(hour: _endDate.hour, minute: _endDate.minute);
    _selectedResources =
        getSelectedResources(_resourceIds, widget.events.resources);
    _unSelectedResources =
        getUnSelectedResources(_selectedResources, widget.events.resources);
  }

  @override
  Widget build(BuildContext context) {
    final Color defaultColor =
        temaApp.brightness == Brightness.dark ? Colors.white : Colors.black54;

    final Color defaultTextColor =
        temaApp.brightness == Brightness.dark ? Colors.white : Colors.black87;

    final Widget _startDatePicker = RawMaterialButton(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      onPressed: () async {
        final DateTime? date = await showDatePicker(
            context: context,
            initialDate: _startDate,
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
            builder: (BuildContext context, Widget? child) {
              /// Theme widget used to apply the theme and primary color to the
              /// date picker.
              return Theme(
                /// The themedata created based
                ///  on the selected theme and primary color.
                data: ThemeData(
                  brightness: temaApp.brightness,
                  colorScheme: getColorScheme(widget.model, true),
                  primaryColor: widget.model.backgroundColor,
                ),
                child: child!,
              );
            });

        if (date != null && date != _startDate) {
          setState(() {
            final Duration difference = _endDate.difference(_startDate);
            _startDate = DateTime(date.year, date.month, date.day,
                _startTime.hour, _startTime.minute, 0);
            _endDate = _startDate.add(difference);
            _endTime = TimeOfDay(hour: _endDate.hour, minute: _endDate.minute);
          });
        }
      },
      child: Text(DateFormat('MMM dd, yyyy').format(_startDate),
          style:
              TextStyle(fontWeight: FontWeight.w500, color: defaultTextColor),
          textAlign: TextAlign.left),
    );

    final Widget _startTimePicker = RawMaterialButton(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      onPressed: () async {
        final TimeOfDay? time = await showTimePicker(
            context: context,
            initialTime:
                TimeOfDay(hour: _startTime.hour, minute: _startTime.minute),
            builder: (BuildContext context, Widget? child) {
              /// Theme widget used to apply the theme and primary color to the
              /// time picker.
              return Theme(
                /// The themedata created based
                /// on the selected theme and primary color.
                data: ThemeData(
                  brightness: temaApp.brightness,
                  colorScheme: getColorScheme(widget.model, false),
                  primaryColor: widget.model.backgroundColor,
                ),
                child: child!,
              );
            });

        if (time != null && time != _startTime) {
          setState(() {
            _startTime = time;
            final Duration difference = _endDate.difference(_startDate);
            _startDate = DateTime(_startDate.year, _startDate.month,
                _startDate.day, _startTime.hour, _startTime.minute, 0);
            _endDate = _startDate.add(difference);
            _endTime = TimeOfDay(hour: _endDate.hour, minute: _endDate.minute);
          });
        }
      },
      child: Text(
        DateFormat('hh:mm a').format(_startDate),
        style: TextStyle(fontWeight: FontWeight.w500, color: defaultTextColor),
        textAlign: TextAlign.left,
      ),
    );

    final Widget _endTimePicker = RawMaterialButton(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      onPressed: () async {
        final TimeOfDay? time = await showTimePicker(
            context: context,
            initialTime:
                TimeOfDay(hour: _endTime.hour, minute: _endTime.minute),
            builder: (BuildContext context, Widget? child) {
              /// Theme widget used to apply the theme and primary color to the
              /// date picker.
              return Theme(
                /// The themedata created based
                /// on the selected theme and primary color.
                data: ThemeData(
                  brightness: temaApp.brightness,
                  colorScheme: getColorScheme(widget.model, false),
                  primaryColor: widget.model.backgroundColor,
                ),
                child: child!,
              );
            });

        if (time != null && time != _endTime) {
          setState(() {
            _endTime = time;
            final Duration difference = _endDate.difference(_startDate);
            _endDate = DateTime(_endDate.year, _endDate.month, _endDate.day,
                _endTime.hour, _endTime.minute, 0);
            if (_endDate.isBefore(_startDate)) {
              _startDate = _endDate.subtract(difference);
              _startTime =
                  TimeOfDay(hour: _startDate.hour, minute: _startDate.minute);
            }
          });
        }
      },
      child: Text(
        DateFormat('hh:mm a').format(_endDate),
        style: TextStyle(fontWeight: FontWeight.w500, color: defaultTextColor),
        textAlign: TextAlign.left,
      ),
    );

    final Widget _endDatePicker = RawMaterialButton(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      onPressed: () async {
        final DateTime? date = await showDatePicker(
            context: context,
            initialDate: _endDate,
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
            builder: (BuildContext context, Widget? child) {
              /// Theme widget used to apply the theme and primary color to the
              /// date picker.
              return Theme(
                /// The themedata created based
                /// on the selected theme and primary color.
                data: ThemeData(
                  brightness: temaApp.brightness,
                  colorScheme: getColorScheme(widget.model, true),
                  primaryColor: widget.model.backgroundColor,
                ),
                child: child!,
              );
            });

        if (date != null && date != _startDate) {
          setState(() {
            final Duration difference = _endDate.difference(_startDate);
            _endDate = DateTime(date.year, date.month, date.day, _endTime.hour,
                _endTime.minute, 0);
            if (_endDate.isBefore(_startDate)) {
              _startDate = _endDate.subtract(difference);
              _startTime =
                  TimeOfDay(hour: _startDate.hour, minute: _startDate.minute);
            }
          });
        }
      },
      child: Text(DateFormat('MMM dd, yyyy').format(_endDate),
          style:
              TextStyle(fontWeight: FontWeight.w500, color: defaultTextColor),
          textAlign: TextAlign.left),
    );

    return ListView(padding: const EdgeInsets.all(0.0), children: <Widget>[
      Container(
          height: 50,
          child: ListTile(
            trailing: IconButton(
              icon: Icon(Icons.close, color: defaultColor),
              splashRadius: 20,
              onPressed: () {
                if (widget.newAppointment != null &&
                    widget.events.appointments!
                        .contains(widget.newAppointment)) {
                  /// To remove the created appointment, when the appointment editor
                  /// closed without saving the appointment.
                  widget.events.appointments!.removeAt(widget
                      .events.appointments!
                      .indexOf(widget.newAppointment));
                  widget.events.notifyListeners(CalendarDataSourceAction.remove,
                      <Appointment>[widget.newAppointment!]);
                }

                Navigator.pop(context);
              },
            ),
          )),
      Container(
          margin: const EdgeInsets.only(bottom: 5),
          height: 50,
          child: ListTile(
            leading: const Text(''),
            title: TextField(
              autofocus: true,
              cursorColor: widget.model.backgroundColor,
              controller: TextEditingController(text: _subject),
              onChanged: (String value) {
                _subject = value;
              },
              keyboardType: TextInputType.multiline,
              maxLines: null,
              style: TextStyle(
                  fontSize: 20,
                  color: defaultTextColor,
                  fontWeight: FontWeight.w400),
              decoration: InputDecoration(
                focusColor: widget.model.backgroundColor,
                border: const UnderlineInputBorder(),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: widget.model.backgroundColor,
                        width: 2.0,
                        style: BorderStyle.solid)),
                hintText: 'Add title and time',
              ),
            ),
          )),
      Container(
          margin: const EdgeInsets.only(bottom: 5),
          height: 50,
          child: ListTile(
            leading: Container(
                width: 30,
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.access_time,
                  size: 20,
                  color: defaultColor,
                )),
            title: _isAllDay
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                        _startDatePicker,
                        const Text(' - '),
                        _endDatePicker,
                        const Text(''),
                        const Text(''),
                      ])
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                        _startDatePicker,
                        _startTimePicker,
                        const Text(' - '),
                        _endTimePicker,
                        _endDatePicker,
                      ]),
          )),
      Container(
          margin: const EdgeInsets.only(bottom: 5),
          height: 50,
          child: ListTile(
            leading: Container(
                width: 30,
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.location_on,
                  color: defaultColor,
                  size: 20,
                )),
            title: TextField(
              cursorColor: widget.model.backgroundColor,
              controller: TextEditingController(text: _location),
              onChanged: (String value) {
                _location = value;
              },
              keyboardType: TextInputType.multiline,
              maxLines: null,
              style: TextStyle(
                fontSize: 15,
                color: defaultTextColor,
              ),
              decoration: const InputDecoration(
                filled: true,
                contentPadding: EdgeInsets.fromLTRB(5, 10, 10, 10),
                fillColor: Colors.transparent,
                border: InputBorder.none,
                hintText: 'Add location',
              ),
            ),
          )),
      Container(
          margin: const EdgeInsets.only(bottom: 5),
          height: 50,
          child: ListTile(
            leading: Container(
                width: 30,
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.subject,
                  size: 20,
                  color: defaultColor,
                )),
            title: TextField(
              controller: TextEditingController(text: _notes),
              onChanged: (String value) {
                _notes = value;
              },
              keyboardType: TextInputType.multiline,
              maxLines: widget.model.isWebFullView ? 1 : null,
              style: TextStyle(
                fontSize: 15,
                color: defaultTextColor,
              ),
              decoration: const InputDecoration(
                filled: true,
                contentPadding: EdgeInsets.fromLTRB(5, 10, 10, 10),
                fillColor: Colors.transparent,
                border: InputBorder.none,
                hintText: 'Add description',
              ),
            ),
          )),
      if (widget.events.resources == null || widget.events.resources!.isEmpty)
        Container()
      else
        Container(
            margin: const EdgeInsets.only(bottom: 5),
            height: 50,
            child: ListTile(
              leading: Container(
                  width: 30,
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.people,
                    color: defaultColor,
                    size: 20,
                  )),
              title: RawMaterialButton(
                padding: const EdgeInsets.only(left: 5),
                onPressed: () {
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
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: _getResourceEditor(TextStyle(
                      fontSize: 15,
                      color: defaultColor,
                      fontWeight: FontWeight.w300)),
                ),
              ),
            )),
      Container(
          margin: const EdgeInsets.only(bottom: 5),
          height: 50,
          child: ListTile(
            leading: Container(
              width: 30,
              alignment: Alignment.centerRight,
              child: Icon(
                Icons.lens,
                size: 20,
                color: HexColor.fromHex(widget
                    .colorCollection[_selectedColorIndex].backgroundColor),
              ),
            ),
            title: RawMaterialButton(
              padding: const EdgeInsets.only(left: 5),
              onPressed: () {
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
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.colorCollection[_selectedColorIndex].tipoconsulta,
                  style: TextStyle(
                      fontWeight: FontWeight.w500, color: defaultTextColor),
                  textAlign: TextAlign.start,
                ),
              ),
            ),
          )),
      Container(
          height: 50,
          child: ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: RawMaterialButton(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        showDialog<Widget>(
                            context: context,
                            builder: (BuildContext context) {
                              final Appointment selectedApp = Appointment(
                                startTime: _startDate,
                                endTime: _endDate,
                                color: HexColor.fromHex(widget
                                    .colorCollection[_selectedColorIndex]
                                    .backgroundColor),
                                notes: _notes,
                                isAllDay: _isAllDay,
                                location: _location,
                                subject:
                                    _subject == '' ? '(No title)' : _subject,
                                resourceIds: _resourceIds,
                              );
                              return WillPopScope(
                                onWillPop: () async {
                                  if (widget.newAppointment != null) {
                                    widget.events.appointments!.removeAt(widget
                                        .events.appointments!
                                        .indexOf(widget.newAppointment));
                                    widget.events.notifyListeners(
                                        CalendarDataSourceAction.remove,
                                        <Appointment>[widget.newAppointment!]);
                                  }
                                  return true;
                                },
                                child: AppointmentEditorWeb(
                                  widget.model,
                                  selectedApp,
                                  widget.colorCollection,
                                  widget.events,
                                  widget.appointment,
                                  widget.visibleDates,
                                  widget.newAppointment,
                                ),
                              );
                            });
                      },
                      child: Text(
                        'MORE OPTIONS',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: defaultTextColor),
                      ),
                    )),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: RawMaterialButton(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    fillColor: widget.model.backgroundColor,
                    onPressed: () {
                      if (widget.newAppointment != null) {
                        if (widget.events.appointments!.isNotEmpty &&
                            widget.events.appointments!
                                .contains(widget.selectedAppointment)) {
                          widget.events.appointments!.removeAt(widget
                              .events.appointments!
                              .indexOf(widget.selectedAppointment));
                          widget.events.notifyListeners(
                              CalendarDataSourceAction.remove,
                              <Appointment>[widget.selectedAppointment]);
                        }
                        if (widget.appointment.isNotEmpty &&
                            widget.appointment
                                .contains(widget.newAppointment)) {
                          widget.appointment.removeAt(widget.appointment
                              .indexOf(widget.newAppointment!));
                        }
                      }

                      widget.appointment.add(Appointment(
                        startTime: _startDate,
                        endTime: _endDate,
                        color: HexColor.fromHex(widget
                            .colorCollection[_selectedColorIndex]
                            .backgroundColor),
                        notes: _notes,
                        isAllDay: _isAllDay,
                        location: _location,
                        subject: _subject == '' ? '(No title)' : _subject,
                        resourceIds: _resourceIds,
                      ));

                      widget.events.appointments!.add(widget.appointment[0]);

                      widget.events.notifyListeners(
                          CalendarDataSourceAction.add, widget.appointment);

                      Navigator.pop(context);
                    },
                    child: const Text(
                      'SAVE',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          )),
    ]);
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
          _resourceIds!.removeAt(i);
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

/// Builds the appointment editor with all the required elements in a pop-up
/// based on the tapped calendar element.
class AppointmentEditorWeb extends StatefulWidget {
  /// Holds the information of appointments
  const AppointmentEditorWeb(this.model, this.selectedAppointment,
      this.colorCollection, this.events, this.appointment, this.visibleDates,
      [this.newAppointment]);

  /// Current sample model
  final SampleModel model;

  /// new appointment value
  final Appointment? newAppointment;

  /// List of appointments
  final List<Appointment> appointment;

  /// Selected appointment value
  final Appointment selectedAppointment;

  /// List of colors
  final List<TiposConsultas> colorCollection;

  /// Holds the Events values
  final CalendarDataSource events;

  /// The visible dates collection
  final List<DateTime> visibleDates;

  @override
  _AppointmentEditorWebState createState() => _AppointmentEditorWebState();
}

class _AppointmentEditorWebState extends State<AppointmentEditorWeb> {
  int _selectedColorIndex = 0;
  int _selectedTimeZoneIndex = 0;
  late DateTime _startDate;
  late TimeOfDay _startTime;
  late DateTime _endDate;
  late TimeOfDay _endTime;
  bool _isAllDay = false;
  String _subject = '';
  String? _notes;
  String? _location;
  bool _isTimeZoneEnabled = false;
  List<Object>? _resourceIds;
  List<CalendarResource> _selectedResources = <CalendarResource>[];
  List<CalendarResource> _unSelectedResources = <CalendarResource>[];

  late String _selectedRecurrenceType, _selectedRecurrenceRange, _ruleType;
  int? _count, _interval, _month, _week;
  late int _dayOfWeek, _weekNumber, _dayOfMonth;
  late double _padding, _margin;
  late DateTime _selectedDate, _firstDate;
  RecurrenceProperties? _recurrenceProperties;
  late RecurrenceType _recurrenceType;
  late RecurrenceRange _recurrenceRange;
  List<WeekDays>? _days;
  IconData? _monthDayRadio, weekDayRadio;
  Color? _weekIconColor, _monthIconColor;
  String? _monthName, _weekNumberText, _dayOfWeekText;

  @override
  void initState() {
    _updateAppointmentProperties();
    super.initState();
  }

  @override
  void didUpdateWidget(AppointmentEditorWeb oldWidget) {
    _updateAppointmentProperties();
    super.didUpdateWidget(oldWidget);
  }

  /// Updates the required editor's default field
  void _updateAppointmentProperties() {
    _startDate = widget.selectedAppointment.startTime;
    _endDate = widget.selectedAppointment.endTime;
    _isAllDay = widget.selectedAppointment.isAllDay;
    _selectedColorIndex = widget.colorCollection.indexWhere(
        (element) => element.tk == widget.selectedAppointment.recurrenceId);

    _subject = widget.selectedAppointment.subject == '(No title)'
        ? ''
        : widget.selectedAppointment.subject;
    _notes = widget.selectedAppointment.notes;
    _location = widget.selectedAppointment.location;

    _selectedColorIndex = _selectedColorIndex == -1 ? 0 : _selectedColorIndex;
    _resourceIds = widget.selectedAppointment.resourceIds?.sublist(0);

    _startTime = TimeOfDay(hour: _startDate.hour, minute: _startDate.minute);
    _endTime = TimeOfDay(hour: _endDate.hour, minute: _endDate.minute);
    _isTimeZoneEnabled = widget.selectedAppointment.startTimeZone != null &&
        widget.selectedAppointment.startTimeZone!.isNotEmpty;
    _selectedResources =
        getSelectedResources(_resourceIds, widget.events.resources);
    _unSelectedResources =
        getUnSelectedResources(_selectedResources, widget.events.resources);
    _selectedDate = _startDate.add(const Duration(days: 30));
    _firstDate = _startDate;
    _month = _startDate.month;
    _monthName = dayMonths[_month! - 1];
    _dayOfMonth = _startDate.day;
    _weekNumber = _getWeekNumber(_startDate);
    _weekNumberText = daysPosition[_weekNumber == -1 ? 4 : _weekNumber - 1];
    _dayOfWeek = _startDate.weekday;
    _dayOfWeekText = weekDay[_dayOfWeek - 1];
    if (_days == null) {
      _webInitialWeekdays(_startDate.weekday);
    }
    _recurrenceProperties = widget.selectedAppointment.recurrenceRule != null &&
            widget.selectedAppointment.recurrenceRule!.isNotEmpty
        ? SfCalendar.parseRRule(
            widget.selectedAppointment.recurrenceRule!, _startDate)
        : null;
    _recurrenceProperties == null
        ? _neverRule()
        : _updateWebRecurrenceProperties();
  }

  void _updateWebRecurrenceProperties() {
    _recurrenceType = _recurrenceProperties!.recurrenceType;
    _week = _recurrenceProperties!.week;
    _weekNumber = _recurrenceProperties!.week == 0
        ? _weekNumber
        : _recurrenceProperties!.week;
    _dayOfMonth = _recurrenceProperties!.dayOfMonth == 1
        ? _startDate.day
        : _recurrenceProperties!.dayOfMonth;
    switch (_recurrenceType) {
      case RecurrenceType.daily:
        _dailyRule();
        break;
      case RecurrenceType.weekly:
        _days = _recurrenceProperties!.weekDays;
        _weeklyRule();
        break;
      case RecurrenceType.monthly:
        _monthlyRule();
        break;
      case RecurrenceType.yearly:
        _month = _recurrenceProperties!.month;
        _yearlyRule();
        break;
    }
    _recurrenceRange = _recurrenceProperties!.recurrenceRange;
    switch (_recurrenceRange) {
      case RecurrenceRange.noEndDate:
        _noEndDateRange();
        break;
      case RecurrenceRange.endDate:
        final Appointment? parentAppointment =
            widget.events.getPatternAppointment(widget.selectedAppointment, '')
                as Appointment?;
        _firstDate = parentAppointment!.startTime;
        _endDateRange();
        break;
      case RecurrenceRange.count:
        _countRange();
        break;
    }
  }

  void _neverRule() {
    setState(() {
      _recurrenceProperties = null;
      _selectedRecurrenceType = 'Never';
      _selectedRecurrenceRange = 'Never';
      _padding = 0;
      _margin = 0;
      _ruleType = '';
    });
  }

  void _dailyRule() {
    setState(() {
      if (_recurrenceProperties == null) {
        _recurrenceProperties = RecurrenceProperties(startDate: _startDate);
        _interval = 1;
      } else {
        _interval = _recurrenceProperties!.interval;
      }
      _recurrenceProperties!.recurrenceType = RecurrenceType.daily;
      _ruleType = 'Day(s)';
      _selectedRecurrenceType = 'Daily';
      _padding = 6;
      _margin = 0;
    });
  }

  void _weeklyRule() {
    setState(() {
      if (_recurrenceProperties == null) {
        _recurrenceProperties = RecurrenceProperties(startDate: _startDate);
        _interval = 1;
      } else {
        _interval = _recurrenceProperties!.interval;
      }
      _recurrenceProperties!.recurrenceType = RecurrenceType.weekly;
      _selectedRecurrenceType = 'Weekly';
      _ruleType = 'Week(s)';
      _recurrenceProperties!.weekDays = _days!;
      _padding = 0;
      _margin = 6;
    });
  }

  void _monthlyRule() {
    setState(() {
      if (_recurrenceProperties == null) {
        _recurrenceProperties = RecurrenceProperties(startDate: _startDate);
        _monthDayIcon();
        _interval = 1;
      } else {
        _interval = _recurrenceProperties!.interval;
        _week == 0 || _week == null ? _monthDayIcon() : _monthWeekIcon();
      }
      _recurrenceProperties!.recurrenceType = RecurrenceType.monthly;
      _selectedRecurrenceType = 'Monthly';
      _ruleType = 'Month(s)';
      _padding = 0;
      _margin = 6;
    });
  }

  void _yearlyRule() {
    setState(() {
      if (_recurrenceProperties == null) {
        _recurrenceProperties = RecurrenceProperties(startDate: _startDate);
        _monthDayIcon();
        _interval = 1;
      } else {
        _interval = _recurrenceProperties!.interval;
        _monthName = dayMonths[_month! - 1];
        _week == 0 || _week == null ? _monthDayIcon() : _monthWeekIcon();
      }
      _recurrenceProperties!.recurrenceType = RecurrenceType.yearly;
      _selectedRecurrenceType = 'Yearly';
      _ruleType = 'Year(s)';
      _recurrenceProperties!.month = _month!;
      _padding = 0;
      _margin = 6;
    });
  }

  void _noEndDateRange() {
    _recurrenceProperties!.recurrenceRange = RecurrenceRange.noEndDate;
    _selectedRecurrenceRange = 'Never';
  }

  void _endDateRange() {
    _recurrenceProperties!.recurrenceRange = RecurrenceRange.endDate;
    _selectedDate = _recurrenceProperties!.endDate ??
        _startDate.add(const Duration(days: 30));
    _selectedRecurrenceRange = 'Until';
    _recurrenceProperties!.endDate = _selectedDate;
  }

  void _countRange() {
    _recurrenceProperties!.recurrenceRange = RecurrenceRange.count;
    _count = _recurrenceProperties!.recurrenceCount == 0
        ? 10
        : _recurrenceProperties!.recurrenceCount;
    _selectedRecurrenceRange = 'Count';
    _recurrenceProperties!.recurrenceCount = _count!;
  }

  void _addInterval() {
    setState(() {
      if (_interval! >= 999) {
        _interval = 999;
      } else {
        _interval = _interval! + 1;
      }
      _recurrenceProperties!.interval = _interval!;
    });
  }

  int _getWeekNumber(DateTime _startDate) {
    int weekOfMonth;
    weekOfMonth = (_startDate.day / 7).ceil();
    if (weekOfMonth == 5) {
      return -1;
    }
    return weekOfMonth;
  }

  void _removeInterval() {
    setState(() {
      if (_interval! > 1) {
        _interval = _interval! - 1;
      }
      _recurrenceProperties!.interval = _interval!;
    });
  }

  void _monthWeekIcon() {
    setState(() {
      _weekNumberText = daysPosition[_weekNumber == -1 ? 4 : _weekNumber - 1];
      _dayOfWeekText = weekDay[_dayOfWeek - 1];
      _recurrenceProperties!.week = _weekNumber;
      _recurrenceProperties!.dayOfWeek = _dayOfWeek;
      _monthIconColor =
          temaApp.brightness == Brightness.dark ? Colors.white : Colors.black54;
      _weekIconColor = widget.model.backgroundColor;
      _monthDayRadio = Icons.radio_button_unchecked;
      weekDayRadio = Icons.radio_button_checked;
    });
  }

  void _monthDayIcon() {
    setState(() {
      _recurrenceProperties!.dayOfWeek = 0;
      _recurrenceProperties!.week = 0;
      _recurrenceProperties!.dayOfMonth = _dayOfMonth;
      _weekIconColor =
          temaApp.brightness == Brightness.dark ? Colors.white : Colors.black54;
      _monthIconColor = widget.model.backgroundColor;
      _monthDayRadio = Icons.radio_button_checked;
      weekDayRadio = Icons.radio_button_unchecked;
    });
  }

  void _addDay() {
    setState(() {
      if (_dayOfMonth < 31) {
        _dayOfMonth = _dayOfMonth + 1;
      }
      _monthDayIcon();
    });
  }

  void _removeDay() {
    setState(() {
      if (_dayOfMonth > 1) {
        _dayOfMonth = _dayOfMonth - 1;
      }
      _monthDayIcon();
    });
  }

  void _addCount() {
    setState(() {
      if (_count! >= 999) {
        _count = 999;
      } else {
        _count = _count! + 1;
      }
      _recurrenceProperties!.recurrenceCount = _count!;
    });
  }

  void _removeCount() {
    setState(() {
      if (_count! > 1) {
        _count = _count! - 1;
      }
      _recurrenceProperties!.recurrenceCount = _count!;
    });
  }

  void _webSelectWeekDays(WeekDays day) {
    switch (day) {
      case WeekDays.sunday:
        if (_days!.contains(WeekDays.sunday) && _days!.length > 1) {
          _days!.remove(WeekDays.sunday);
          _recurrenceProperties!.weekDays = _days!;
        } else {
          _days!.add(WeekDays.sunday);
          _recurrenceProperties!.weekDays = _days!;
        }
        break;
      case WeekDays.monday:
        if (_days!.contains(WeekDays.monday) && _days!.length > 1) {
          _days!.remove(WeekDays.monday);
          _recurrenceProperties!.weekDays = _days!;
        } else {
          _days!.add(WeekDays.monday);
          _recurrenceProperties!.weekDays = _days!;
        }
        break;
      case WeekDays.tuesday:
        if (_days!.contains(WeekDays.tuesday) && _days!.length > 1) {
          _days!.remove(WeekDays.tuesday);
          _recurrenceProperties!.weekDays = _days!;
        } else {
          _days!.add(WeekDays.tuesday);
          _recurrenceProperties!.weekDays = _days!;
        }
        break;
      case WeekDays.wednesday:
        if (_days!.contains(WeekDays.wednesday) && _days!.length > 1) {
          _days!.remove(WeekDays.wednesday);
          _recurrenceProperties!.weekDays = _days!;
        } else {
          _days!.add(WeekDays.wednesday);
          _recurrenceProperties!.weekDays = _days!;
        }
        break;
      case WeekDays.thursday:
        if (_days!.contains(WeekDays.thursday) && _days!.length > 1) {
          _days!.remove(WeekDays.thursday);
          _recurrenceProperties!.weekDays = _days!;
        } else {
          _days!.add(WeekDays.thursday);
          _recurrenceProperties!.weekDays = _days!;
        }
        break;
      case WeekDays.friday:
        if (_days!.contains(WeekDays.friday) && _days!.length > 1) {
          _days!.remove(WeekDays.friday);
          _recurrenceProperties!.weekDays = _days!;
        } else {
          _days!.add(WeekDays.friday);
          _recurrenceProperties!.weekDays = _days!;
        }
        break;
      case WeekDays.saturday:
        if (_days!.contains(WeekDays.saturday) && _days!.length > 1) {
          _days!.remove(WeekDays.saturday);
          _recurrenceProperties!.weekDays = _days!;
        } else {
          _days!.add(WeekDays.saturday);
          _recurrenceProperties!.weekDays = _days!;
        }
        break;
    }
  }

  void _webInitialWeekdays(int day) {
    switch (_startDate.weekday) {
      case DateTime.monday:
        _days = <WeekDays>[WeekDays.monday];
        break;
      case DateTime.tuesday:
        _days = <WeekDays>[WeekDays.tuesday];
        break;
      case DateTime.wednesday:
        _days = <WeekDays>[WeekDays.wednesday];
        break;
      case DateTime.thursday:
        _days = <WeekDays>[WeekDays.thursday];
        break;
      case DateTime.friday:
        _days = <WeekDays>[WeekDays.friday];
        break;
      case DateTime.saturday:
        _days = <WeekDays>[WeekDays.saturday];
        break;
      case DateTime.sunday:
        _days = <WeekDays>[WeekDays.sunday];
        break;
    }
  }

  /// Return the resource editor to edit the resource collection for an
  /// appointment
  Widget _getResourceEditor(TextStyle hintTextStyle) {
    if (_selectedResources.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 25, bottom: 5),
        child: Text(
          'Add people',
          style: hintTextStyle,
        ),
      );
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
          _resourceIds!.removeAt(i);
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

  @override
  Widget build(BuildContext context) {
    final Color defaultColor =
        temaApp.brightness == Brightness.dark ? Colors.white : Colors.black54;

    final Color defaultTextColor =
        temaApp.brightness == Brightness.dark ? Colors.white : Colors.black87;

    final Color defaultButtonColor =
        temaApp.brightness == Brightness.dark ? Colors.white10 : Colors.white;
    final Color borderColor = temaApp.brightness == Brightness.dark
        ? Colors.white
        : Colors.transparent;

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: 600,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          color: temaApp.brightness == Brightness.dark
              ? Colors.grey[850]
              : Colors.white,
        ),
        height: widget.events.resources != null &&
                widget.events.resources!.isNotEmpty
            ? widget.selectedAppointment.recurrenceId == null
                ? _isTimeZoneEnabled || _selectedRecurrenceType != 'Never'
                    ? 640
                    : 580
                : _isTimeZoneEnabled || _selectedRecurrenceType != 'Never'
                    ? 560
                    : 480
            : widget.selectedAppointment.recurrenceId == null
                ? _isTimeZoneEnabled || _selectedRecurrenceType != 'Never'
                    ? 560
                    : 500
                : _isTimeZoneEnabled || _selectedRecurrenceType != 'Never'
                    ? 480
                    : 420,
        alignment: Alignment.center,
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(0.0),
                children: <Widget>[
                  Container(
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      child: ListTile(
                        title: Text(
                          widget.newAppointment == null
                              ? 'Edit appointment'
                              : 'New appointment',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: defaultTextColor),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.close, color: defaultColor),
                          onPressed: () {
                            if (widget.newAppointment != null &&
                                widget.events.appointments!
                                    .contains(widget.newAppointment)) {
                              /// To remove the created appointment when the pop-up closed
                              /// without saving the appointment.
                              widget.events.appointments!.removeAt(widget
                                  .events.appointments!
                                  .indexOf(widget.newAppointment));
                              widget.events.notifyListeners(
                                  CalendarDataSourceAction.remove,
                                  <Appointment>[widget.newAppointment!]);
                            }

                            Navigator.pop(context);
                          },
                        ),
                      )),
                  Container(
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                              flex: 4,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 5, right: 5, top: 2, bottom: 2),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Title',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: defaultColor,
                                          fontWeight: FontWeight.w300),
                                      textAlign: TextAlign.start,
                                    ),
                                    TextField(
                                      autofocus: true,
                                      cursorColor: widget.model.backgroundColor,
                                      controller:
                                          TextEditingController(text: _subject),
                                      onChanged: (String value) {
                                        _subject = value;
                                      },
                                      keyboardType: TextInputType.multiline,
                                      maxLines: null,
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: defaultTextColor,
                                          fontWeight: FontWeight.w400),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        focusColor:
                                            widget.model.backgroundColor,
                                        border: const UnderlineInputBorder(),
                                        focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: widget
                                                    .model.backgroundColor,
                                                width: 2.0,
                                                style: BorderStyle.solid)),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                          Expanded(
                            flex: 4,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 5, right: 5, top: 2, bottom: 2),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Location',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: defaultColor,
                                        fontWeight: FontWeight.w300),
                                    textAlign: TextAlign.start,
                                  ),
                                  TextField(
                                    controller:
                                        TextEditingController(text: _location),
                                    cursorColor: widget.model.backgroundColor,
                                    onChanged: (String value) {
                                      _location = value;
                                    },
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null,
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: defaultTextColor,
                                        fontWeight: FontWeight.w400),
                                    decoration: InputDecoration(
                                      focusColor: widget.model.backgroundColor,
                                      isDense: true,
                                      border: const UnderlineInputBorder(),
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color:
                                                  widget.model.backgroundColor,
                                              width: 2.0,
                                              style: BorderStyle.solid)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      )),
                  Container(
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      child: ListTile(
                          title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            flex: 4,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 5, right: 5, top: 5, bottom: 2),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Start',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: defaultColor,
                                        fontWeight: FontWeight.w300),
                                    textAlign: TextAlign.start,
                                  ),
                                  TextField(
                                    readOnly: true,
                                    controller: TextEditingController(
                                        text: (_isAllDay
                                                ? DateFormat('MM/dd/yyyy')
                                                : DateFormat('MM/dd/yy h:mm a'))
                                            .format(_startDate)),
                                    onChanged: (String value) {
                                      _startDate = DateTime.parse(value);
                                      _startTime = TimeOfDay(
                                          hour: _startDate.hour,
                                          minute: _startDate.minute);
                                    },
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null,
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: defaultTextColor,
                                        fontWeight: FontWeight.w400),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      suffix: Container(
                                        height: 20,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: <Widget>[
                                            ButtonTheme(
                                                minWidth: 50.0,
                                                child: MaterialButton(
                                                  elevation: 0,
                                                  focusElevation: 0,
                                                  highlightElevation: 0,
                                                  disabledElevation: 0,
                                                  hoverElevation: 0,
                                                  onPressed: () async {
                                                    final DateTime? date =
                                                        await showDatePicker(
                                                            context: context,
                                                            initialDate:
                                                                _startDate,
                                                            firstDate:
                                                                DateTime(1900),
                                                            lastDate:
                                                                DateTime(2100),
                                                            builder:
                                                                (BuildContext
                                                                        context,
                                                                    Widget?
                                                                        child) {
                                                              return Theme(
                                                                data: ThemeData(
                                                                    brightness:
                                                                        temaApp
                                                                            .brightness,
                                                                    colorScheme:
                                                                        getColorScheme(
                                                                            widget
                                                                                .model,
                                                                            true),
                                                                    primaryColor:
                                                                        widget
                                                                            .model
                                                                            .backgroundColor),
                                                                child: child!,
                                                              );
                                                            });

                                                    if (date != null &&
                                                        date != _startDate) {
                                                      setState(() {
                                                        final Duration
                                                            difference =
                                                            _endDate.difference(
                                                                _startDate);
                                                        _startDate = DateTime(
                                                            date.year,
                                                            date.month,
                                                            date.day,
                                                            _startTime.hour,
                                                            _startTime.minute,
                                                            0);
                                                        _endDate = _startDate
                                                            .add(difference);
                                                        _endTime = TimeOfDay(
                                                            hour: _endDate.hour,
                                                            minute: _endDate
                                                                .minute);
                                                      });
                                                    }
                                                  },
                                                  shape: const CircleBorder(),
                                                  padding:
                                                      const EdgeInsets.all(0.0),
                                                  child: Icon(
                                                    Icons.date_range,
                                                    color: defaultColor,
                                                    size: 20,
                                                  ),
                                                )),
                                            if (_isAllDay)
                                              Container(
                                                width: 0,
                                                height: 0,
                                              )
                                            else
                                              ButtonTheme(
                                                  minWidth: 50.0,
                                                  child: MaterialButton(
                                                    elevation: 0,
                                                    focusElevation: 0,
                                                    highlightElevation: 0,
                                                    disabledElevation: 0,
                                                    hoverElevation: 0,
                                                    shape: const CircleBorder(),
                                                    padding:
                                                        const EdgeInsets.all(
                                                            0.0),
                                                    onPressed: () async {
                                                      final TimeOfDay? time =
                                                          await showTimePicker(
                                                              context: context,
                                                              initialTime: TimeOfDay(
                                                                  hour:
                                                                      _startTime
                                                                          .hour,
                                                                  minute:
                                                                      _startTime
                                                                          .minute),
                                                              builder: (BuildContext
                                                                      context,
                                                                  Widget?
                                                                      child) {
                                                                return Theme(
                                                                  data:
                                                                      ThemeData(
                                                                    brightness:
                                                                        temaApp
                                                                            .brightness,
                                                                    colorScheme:
                                                                        getColorScheme(
                                                                            widget.model,
                                                                            false),
                                                                    primaryColor:
                                                                        widget
                                                                            .model
                                                                            .backgroundColor,
                                                                  ),
                                                                  child: child!,
                                                                );
                                                              });

                                                      if (time != null &&
                                                          time != _startTime) {
                                                        setState(() {
                                                          _startTime = time;
                                                          final Duration
                                                              difference =
                                                              _endDate.difference(
                                                                  _startDate);
                                                          _startDate = DateTime(
                                                              _startDate.year,
                                                              _startDate.month,
                                                              _startDate.day,
                                                              _startTime.hour,
                                                              _startTime.minute,
                                                              0);
                                                          _endDate = _startDate
                                                              .add(difference);
                                                          _endTime = TimeOfDay(
                                                              hour:
                                                                  _endDate.hour,
                                                              minute: _endDate
                                                                  .minute);
                                                        });
                                                      }
                                                    },
                                                    child: Icon(
                                                      Icons.access_time,
                                                      color: defaultColor,
                                                      size: 20,
                                                    ),
                                                  ))
                                          ],
                                        ),
                                      ),
                                      focusColor: widget.model.backgroundColor,
                                      border: const UnderlineInputBorder(),
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color:
                                                  widget.model.backgroundColor,
                                              width: 2.0,
                                              style: BorderStyle.solid)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 5, right: 5, top: 5, bottom: 2),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text('End',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: defaultColor,
                                          fontWeight: FontWeight.w300),
                                      textAlign: TextAlign.start),
                                  TextField(
                                    readOnly: true,
                                    controller: TextEditingController(
                                        text: (_isAllDay
                                                ? DateFormat('MM/dd/yyyy')
                                                : DateFormat('MM/dd/yy h:mm a'))
                                            .format(_endDate)),
                                    onChanged: (String value) {
                                      _endDate = DateTime.parse(value);
                                      _endTime = TimeOfDay(
                                          hour: _endDate.hour,
                                          minute: _endDate.minute);
                                    },
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null,
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: defaultTextColor,
                                        fontWeight: FontWeight.w400),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      suffix: Container(
                                        height: 20,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            ButtonTheme(
                                                minWidth: 50.0,
                                                child: MaterialButton(
                                                  elevation: 0,
                                                  focusElevation: 0,
                                                  highlightElevation: 0,
                                                  disabledElevation: 0,
                                                  hoverElevation: 0,
                                                  shape: const CircleBorder(),
                                                  padding:
                                                      const EdgeInsets.all(0.0),
                                                  onPressed: () async {
                                                    final DateTime? date =
                                                        await showDatePicker(
                                                            context: context,
                                                            initialDate:
                                                                _endDate,
                                                            firstDate:
                                                                DateTime(1900),
                                                            lastDate:
                                                                DateTime(2100),
                                                            builder:
                                                                (BuildContext
                                                                        context,
                                                                    Widget?
                                                                        child) {
                                                              return Theme(
                                                                data: ThemeData(
                                                                  brightness:
                                                                      temaApp
                                                                          .brightness,
                                                                  colorScheme:
                                                                      getColorScheme(
                                                                          widget
                                                                              .model,
                                                                          true),
                                                                  primaryColor:
                                                                      widget
                                                                          .model
                                                                          .backgroundColor,
                                                                ),
                                                                child: child!,
                                                              );
                                                            });

                                                    if (date != null &&
                                                        date != _endDate) {
                                                      setState(() {
                                                        final Duration
                                                            difference =
                                                            _endDate.difference(
                                                                _startDate);
                                                        _endDate = DateTime(
                                                            date.year,
                                                            date.month,
                                                            date.day,
                                                            _endTime.hour,
                                                            _endTime.minute,
                                                            0);
                                                        if (_endDate.isBefore(
                                                            _startDate)) {
                                                          _startDate =
                                                              _endDate.subtract(
                                                                  difference);
                                                          _startTime = TimeOfDay(
                                                              hour: _startDate
                                                                  .hour,
                                                              minute: _startDate
                                                                  .minute);
                                                        }
                                                      });
                                                    }
                                                  },
                                                  child: Icon(
                                                    Icons.date_range,
                                                    color: defaultColor,
                                                    size: 20,
                                                  ),
                                                )),
                                            if (_isAllDay)
                                              Container(
                                                width: 0,
                                                height: 0,
                                              )
                                            else
                                              ButtonTheme(
                                                  minWidth: 50.0,
                                                  child: MaterialButton(
                                                    elevation: 0,
                                                    focusElevation: 0,
                                                    highlightElevation: 0,
                                                    disabledElevation: 0,
                                                    hoverElevation: 0,
                                                    shape: const CircleBorder(),
                                                    padding:
                                                        const EdgeInsets.all(0),
                                                    onPressed: () async {
                                                      final TimeOfDay? time =
                                                          await showTimePicker(
                                                              context: context,
                                                              initialTime: TimeOfDay(
                                                                  hour: _endTime
                                                                      .hour,
                                                                  minute: _endTime
                                                                      .minute),
                                                              builder: (BuildContext
                                                                      context,
                                                                  Widget?
                                                                      child) {
                                                                return Theme(
                                                                  data:
                                                                      ThemeData(
                                                                    brightness:
                                                                        temaApp
                                                                            .brightness,
                                                                    colorScheme:
                                                                        getColorScheme(
                                                                            widget.model,
                                                                            false),
                                                                    primaryColor:
                                                                        widget
                                                                            .model
                                                                            .backgroundColor,
                                                                  ),
                                                                  child: child!,
                                                                );
                                                              });

                                                      if (time != null &&
                                                          time != _endTime) {
                                                        setState(() {
                                                          _endTime = time;
                                                          final Duration
                                                              difference =
                                                              _endDate.difference(
                                                                  _startDate);
                                                          _endDate = DateTime(
                                                              _endDate.year,
                                                              _endDate.month,
                                                              _endDate.day,
                                                              _endTime.hour,
                                                              _endTime.minute,
                                                              0);
                                                          if (_endDate.isBefore(
                                                              _startDate)) {
                                                            _startDate = _endDate
                                                                .subtract(
                                                                    difference);
                                                            _startTime = TimeOfDay(
                                                                hour: _startDate
                                                                    .hour,
                                                                minute:
                                                                    _startDate
                                                                        .minute);
                                                          }
                                                        });
                                                      }
                                                    },
                                                    child: Icon(
                                                      Icons.access_time,
                                                      color: defaultColor,
                                                      size: 20,
                                                    ),
                                                  ))
                                          ],
                                        ),
                                      ),
                                      focusColor: widget.model.backgroundColor,
                                      border: const UnderlineInputBorder(),
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color:
                                                  widget.model.backgroundColor,
                                              width: 2.0,
                                              style: BorderStyle.solid)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ))),
                  Container(
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      child: ListTile(
                        title: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Checkbox(
                              focusColor: widget.model.backgroundColor,
                              activeColor: widget.model.backgroundColor,
                              value: _isAllDay,
                              onChanged: (bool? value) {
                                if (value == null) {
                                  return;
                                }
                                setState(() {
                                  _isAllDay = value;
                                  if (_isAllDay) {
                                    _isTimeZoneEnabled = false;
                                  }
                                });
                              },
                            ),
                            Text(
                              'All day',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: defaultColor,
                                  fontWeight: FontWeight.w300),
                            ),
                            Container(width: 10),
                            if (_isAllDay)
                              Container()
                            else
                              Checkbox(
                                focusColor: widget.model.backgroundColor,
                                activeColor: widget.model.backgroundColor,
                                value: _isTimeZoneEnabled,
                                onChanged: (bool? value) {
                                  if (value == null) {
                                    return;
                                  }
                                  setState(() {
                                    _isTimeZoneEnabled = value;
                                    if (!_isTimeZoneEnabled &&
                                        _selectedTimeZoneIndex != 0) {
                                      _selectedTimeZoneIndex = 0;
                                    }
                                  });
                                },
                              ),
                            if (_isAllDay)
                              Container()
                            else
                              Text(
                                'Time zone',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: defaultColor,
                                    fontWeight: FontWeight.w300),
                              ),
                          ],
                        ),
                      )),
                  Visibility(
                    visible: widget.selectedAppointment.recurrenceId == null,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                              flex: 4,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 5, right: 5, top: 2, bottom: 2),
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Repeat',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: defaultColor,
                                            fontWeight: FontWeight.w300),
                                        textAlign: TextAlign.start,
                                      ),
                                      TextField(
                                        mouseCursor:
                                            MaterialStateMouseCursor.clickable,
                                        controller: TextEditingController(
                                            text: _selectedRecurrenceType),
                                        decoration: InputDecoration(
                                          isDense: true,
                                          suffix: Container(
                                              height: 28,
                                              child: DropdownButton<String>(
                                                  isExpanded: true,
                                                  underline: Container(),
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      color: defaultTextColor,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                  value:
                                                      _selectedRecurrenceType,
                                                  items: repeatOption
                                                      .map((String item) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: item,
                                                      child: Text(item),
                                                    );
                                                  }).toList(),
                                                  onChanged: (String? value) {
                                                    if (value == 'Weekly') {
                                                      _weeklyRule();
                                                    } else if (value ==
                                                        'Monthly') {
                                                      _monthlyRule();
                                                    } else if (value ==
                                                        'Yearly') {
                                                      _yearlyRule();
                                                    } else if (value ==
                                                        'Daily') {
                                                      _dailyRule();
                                                    } else if (value ==
                                                        'Never') {
                                                      _neverRule();
                                                    }
                                                  })),
                                          focusColor:
                                              widget.model.backgroundColor,
                                          border: const UnderlineInputBorder(),
                                          focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: widget
                                                      .model.backgroundColor,
                                                  width: 2.0,
                                                  style: BorderStyle.solid)),
                                        ),
                                      )
                                    ]),
                              )),
                          Expanded(
                            flex: 3,
                            child: Visibility(
                                visible: _selectedRecurrenceType != 'Never',
                                child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5, right: 5, top: 2, bottom: 0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Repeat every',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: defaultColor,
                                              fontWeight: FontWeight.w300),
                                          textAlign: TextAlign.start,
                                        ),
                                        TextField(
                                          textAlignVertical:
                                              TextAlignVertical.bottom,
                                          controller: TextEditingController
                                              .fromValue(TextEditingValue(
                                                  text: _interval.toString(),
                                                  selection:
                                                      TextSelection.collapsed(
                                                          offset: _interval
                                                              .toString()
                                                              .length))),
                                          cursorColor:
                                              widget.model.backgroundColor,
                                          onChanged: (String value) {
                                            if (value.isNotEmpty) {
                                              _interval = int.parse(value);
                                              if (_interval == 0) {
                                                _interval = 1;
                                              } else if (_interval! >= 999) {
                                                _interval = 999;
                                              }
                                            } else if (value.isEmpty) {
                                              _interval = 1;
                                            }
                                            _recurrenceProperties!.interval =
                                                _interval!;
                                          },
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter
                                                .digitsOnly
                                          ],
                                          maxLines: null,
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: defaultTextColor,
                                              fontWeight: FontWeight.w400),
                                          decoration: InputDecoration(
                                            isDense: true,
                                            // isCollapsed: true,
                                            contentPadding:
                                                const EdgeInsets.only(
                                                    top: 15, bottom: 5),
                                            suffixIconConstraints:
                                                const BoxConstraints(
                                              maxHeight: 35,
                                            ),
                                            suffixIcon: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: <Widget>[
                                                IconButton(
                                                    icon: Icon(
                                                        Icons
                                                            .arrow_drop_down_outlined,
                                                        color: defaultColor),
                                                    alignment:
                                                        Alignment.centerRight,
                                                    padding:
                                                        const EdgeInsets.only(
                                                      right: 0,
                                                      bottom: 3,
                                                    ),
                                                    onPressed: _removeInterval),
                                                IconButton(
                                                    icon: Icon(
                                                      Icons
                                                          .arrow_drop_up_outlined,
                                                      color: defaultColor,
                                                    ),
                                                    alignment:
                                                        Alignment.centerRight,
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 3, left: 0),
                                                    onPressed: _addInterval),
                                              ],
                                            ),
                                            focusColor:
                                                widget.model.backgroundColor,
                                            border:
                                                const UnderlineInputBorder(),
                                            focusedBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: widget
                                                        .model.backgroundColor,
                                                    width: 2.0,
                                                    style: BorderStyle.solid)),
                                          ),
                                        )
                                      ],
                                    ))),
                          ),
                          Expanded(
                              flex: 1,
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text('  ' + _ruleType,
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: defaultTextColor,
                                            fontWeight: FontWeight.w400))
                                  ])),
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                      visible: _selectedRecurrenceType != 'Never',
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 3),
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              flex: _selectedRecurrenceType == 'Weekly' ? 4 : 0,
                              child: Visibility(
                                  visible: _selectedRecurrenceType == 'Weekly',
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 6, right: 5, top: 2, bottom: 2),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Repeat On',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: defaultColor,
                                              fontWeight: FontWeight.w300),
                                          textAlign: TextAlign.start,
                                        ),
                                        Padding(
                                            padding:
                                                const EdgeInsets.only(top: 10),
                                            child: Wrap(
                                              spacing: 3.0,
                                              runSpacing: 10.0,
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.center,
                                              children: <Widget>[
                                                Tooltip(
                                                  message: 'Sunday',
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        _webSelectWeekDays(
                                                            WeekDays.sunday);
                                                      });
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      onSurface: Colors.black26,
                                                      side: BorderSide(
                                                          color: borderColor,
                                                          style: BorderStyle
                                                              .solid),
                                                      primary: _days!.contains(
                                                              WeekDays.sunday)
                                                          ? widget.model
                                                              .backgroundColor
                                                          : defaultButtonColor,
                                                      onPrimary: _days!
                                                              .contains(WeekDays
                                                                  .sunday)
                                                          ? Colors.white
                                                          : defaultTextColor,
                                                      shape:
                                                          const CircleBorder(),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              15),
                                                    ),
                                                    child: const Text('S'),
                                                  ),
                                                ),
                                                Tooltip(
                                                  message: 'Monday',
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        _webSelectWeekDays(
                                                            WeekDays.monday);
                                                      });
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      onSurface: Colors.black26,
                                                      side: BorderSide(
                                                          color: borderColor,
                                                          style: BorderStyle
                                                              .solid),
                                                      primary: _days!.contains(
                                                              WeekDays.monday)
                                                          ? widget.model
                                                              .backgroundColor
                                                          : defaultButtonColor,
                                                      onPrimary: _days!
                                                              .contains(WeekDays
                                                                  .monday)
                                                          ? Colors.white
                                                          : defaultTextColor,
                                                      shape:
                                                          const CircleBorder(),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              15),
                                                    ),
                                                    child: const Text('M'),
                                                  ),
                                                ),
                                                Tooltip(
                                                  message: 'Tuesday',
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        _webSelectWeekDays(
                                                            WeekDays.tuesday);
                                                      });
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      onSurface: Colors.black26,
                                                      side: BorderSide(
                                                          color: borderColor,
                                                          style: BorderStyle
                                                              .solid),
                                                      primary: _days!.contains(
                                                              WeekDays.tuesday)
                                                          ? widget.model
                                                              .backgroundColor
                                                          : defaultButtonColor,
                                                      onPrimary: _days!
                                                              .contains(WeekDays
                                                                  .tuesday)
                                                          ? Colors.white
                                                          : defaultTextColor,
                                                      shape:
                                                          const CircleBorder(),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              15),
                                                    ),
                                                    child: const Text('T'),
                                                  ),
                                                ),
                                                Tooltip(
                                                  message: 'Wednesday',
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        _webSelectWeekDays(
                                                            WeekDays.wednesday);
                                                      });
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      onSurface: Colors.black26,
                                                      side: BorderSide(
                                                          color: borderColor,
                                                          style: BorderStyle
                                                              .solid),
                                                      primary: _days!.contains(
                                                              WeekDays
                                                                  .wednesday)
                                                          ? widget.model
                                                              .backgroundColor
                                                          : defaultButtonColor,
                                                      onPrimary: _days!
                                                              .contains(WeekDays
                                                                  .wednesday)
                                                          ? Colors.white
                                                          : defaultTextColor,
                                                      shape:
                                                          const CircleBorder(),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              15),
                                                    ),
                                                    child: const Text('W'),
                                                  ),
                                                ),
                                                Tooltip(
                                                  message: 'Thursday',
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        _webSelectWeekDays(
                                                            WeekDays.thursday);
                                                      });
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      onSurface: Colors.black26,
                                                      side: BorderSide(
                                                          color: borderColor,
                                                          style: BorderStyle
                                                              .solid),
                                                      primary: _days!.contains(
                                                              WeekDays.thursday)
                                                          ? widget.model
                                                              .backgroundColor
                                                          : defaultButtonColor,
                                                      onPrimary: _days!
                                                              .contains(WeekDays
                                                                  .thursday)
                                                          ? Colors.white
                                                          : defaultTextColor,
                                                      shape:
                                                          const CircleBorder(),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              15),
                                                    ),
                                                    child: const Text('T'),
                                                  ),
                                                ),
                                                Tooltip(
                                                  message: 'Friday',
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        _webSelectWeekDays(
                                                            WeekDays.friday);
                                                      });
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      onSurface: Colors.black26,
                                                      side: BorderSide(
                                                          color: borderColor,
                                                          style: BorderStyle
                                                              .solid),
                                                      primary: _days!.contains(
                                                              WeekDays.friday)
                                                          ? widget.model
                                                              .backgroundColor
                                                          : defaultButtonColor,
                                                      onPrimary: _days!
                                                              .contains(WeekDays
                                                                  .friday)
                                                          ? Colors.white
                                                          : defaultTextColor,
                                                      shape:
                                                          const CircleBorder(),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              15),
                                                    ),
                                                    child: const Text('F'),
                                                  ),
                                                ),
                                                Tooltip(
                                                  message: 'Saturday',
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        _webSelectWeekDays(
                                                            WeekDays.saturday);
                                                      });
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      onSurface: Colors.black26,
                                                      side: BorderSide(
                                                          color: borderColor,
                                                          style: BorderStyle
                                                              .solid),
                                                      primary: _days!.contains(
                                                              WeekDays.saturday)
                                                          ? widget.model
                                                              .backgroundColor
                                                          : defaultButtonColor,
                                                      onPrimary: _days!
                                                              .contains(WeekDays
                                                                  .saturday)
                                                          ? Colors.white
                                                          : defaultTextColor,
                                                      shape:
                                                          const CircleBorder(),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              15),
                                                    ),
                                                    child: const Text('S'),
                                                  ),
                                                ),
                                              ],
                                            )),
                                      ],
                                    ),
                                  )),
                            ),
                            Expanded(
                              flex: _selectedRecurrenceType == 'Yearly' ? 4 : 0,
                              child: Visibility(
                                visible: _selectedRecurrenceType == 'Yearly',
                                child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5, right: 5, top: 2, bottom: 2),
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          Text(
                                            'Repeat On',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: defaultColor,
                                                fontWeight: FontWeight.w300),
                                            textAlign: TextAlign.start,
                                          ),
                                          TextField(
                                            mouseCursor:
                                                MaterialStateMouseCursor
                                                    .clickable,
                                            controller: TextEditingController(
                                                text: _monthName),
                                            decoration: InputDecoration(
                                              isDense: true,
                                              suffix: Container(
                                                height: 27,
                                                child: DropdownButton<String>(
                                                    isExpanded: true,
                                                    underline: Container(),
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        color: defaultTextColor,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                    value: _monthName,
                                                    items: dayMonths
                                                        .map((String item) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: item,
                                                        child: Text(item),
                                                      );
                                                    }).toList(),
                                                    onChanged: (String? value) {
                                                      setState(() {
                                                        if (value ==
                                                            'January') {
                                                          _monthName =
                                                              'January';
                                                          _month = 1;
                                                          _recurrenceProperties!
                                                              .month = _month!;
                                                        } else if (value ==
                                                            'February') {
                                                          _monthName =
                                                              'February';
                                                          _month = 2;
                                                          _recurrenceProperties!
                                                              .month = _month!;
                                                        } else if (value ==
                                                            'March') {
                                                          _monthName = 'March';
                                                          _month = 3;
                                                          _recurrenceProperties!
                                                              .month = _month!;
                                                        } else if (value ==
                                                            'April') {
                                                          _monthName = 'April';
                                                          _month = 4;
                                                          _recurrenceProperties!
                                                              .month = _month!;
                                                        } else if (value ==
                                                            'May') {
                                                          _monthName = 'May';
                                                          _month = 5;
                                                          _recurrenceProperties!
                                                              .month = _month!;
                                                        } else if (value ==
                                                            'June') {
                                                          _monthName = 'June';
                                                          _month = 6;
                                                          _recurrenceProperties!
                                                              .month = _month!;
                                                        } else if (value ==
                                                            'July') {
                                                          _monthName = 'July';
                                                          _month = 7;
                                                          _recurrenceProperties!
                                                              .month = _month!;
                                                        } else if (value ==
                                                            'August') {
                                                          _monthName = 'August';
                                                          _month = 8;
                                                          _recurrenceProperties!
                                                              .month = _month!;
                                                        } else if (value ==
                                                            'September') {
                                                          _monthName =
                                                              'September';
                                                          _month = 9;
                                                          _recurrenceProperties!
                                                              .month = _month!;
                                                        } else if (value ==
                                                            'October') {
                                                          _monthName =
                                                              'October';
                                                          _month = 10;
                                                          _recurrenceProperties!
                                                              .month = _month!;
                                                        } else if (value ==
                                                            'November') {
                                                          _monthName =
                                                              'November';
                                                          _month = 11;
                                                          _recurrenceProperties!
                                                              .month = _month!;
                                                        } else if (value ==
                                                            'December') {
                                                          _monthName =
                                                              'December';
                                                          _month = 12;
                                                          _recurrenceProperties!
                                                              .month = _month!;
                                                        }
                                                      });
                                                    }),
                                              ),
                                              focusColor:
                                                  widget.model.backgroundColor,
                                              border:
                                                  const UnderlineInputBorder(),
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: widget.model
                                                              .backgroundColor,
                                                          width: 2.0,
                                                          style: BorderStyle
                                                              .solid)),
                                            ),
                                          ),
                                        ])),
                              ),
                            ),
                            Expanded(
                              flex:
                                  _selectedRecurrenceType == 'Monthly' ? 4 : 0,
                              child: Visibility(
                                visible: _selectedRecurrenceType == 'Monthly',
                                child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5, right: 5, top: 2, bottom: 2),
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            'Repeat On',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: defaultColor,
                                                fontWeight: FontWeight.w300),
                                            textAlign: TextAlign.start,
                                          ),
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.max,
                                              children: <Widget>[
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 10),
                                                    child: IconButton(
                                                      onPressed: () {
                                                        _monthDayIcon();
                                                      },
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 2),
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      icon:
                                                          Icon(_monthDayRadio),
                                                      color: _monthIconColor,
                                                      focusColor: widget.model
                                                          .backgroundColor,
                                                      iconSize: 20,
                                                    )),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 10, top: 10),
                                                  child: Text(
                                                    'Day',
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        color: defaultTextColor,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 5,
                                                              bottom: 5),
                                                      child: TextField(
                                                        controller: TextEditingController
                                                            .fromValue(TextEditingValue(
                                                                text: _dayOfMonth
                                                                    .toString(),
                                                                selection: TextSelection.collapsed(
                                                                    offset: _dayOfMonth
                                                                        .toString()
                                                                        .length))),
                                                        cursorColor: widget
                                                            .model
                                                            .backgroundColor,
                                                        onChanged:
                                                            (String value) {
                                                          if (value
                                                              .isNotEmpty) {
                                                            _dayOfMonth =
                                                                int.parse(
                                                                    value);
                                                            if (_dayOfMonth <=
                                                                1) {
                                                              _dayOfMonth = 1;
                                                            } else if (_dayOfMonth >=
                                                                31) {
                                                              _dayOfMonth = 31;
                                                            }
                                                          } else if (value
                                                              .isEmpty) {
                                                            _dayOfMonth =
                                                                _startDate.day;
                                                          }
                                                          _recurrenceProperties!
                                                              .dayOfWeek = 0;
                                                          _recurrenceProperties!
                                                              .week = 0;
                                                          _recurrenceProperties!
                                                                  .dayOfMonth =
                                                              _dayOfMonth;
                                                          // ignore: unrelated_type_equality_checks
                                                          if (temaApp ==
                                                              Brightness.dark) {
                                                            _weekIconColor =
                                                                Colors.white;
                                                          } else {
                                                            _weekIconColor =
                                                                Colors.black54;
                                                          }
                                                          _monthIconColor = widget
                                                              .model
                                                              .backgroundColor;
                                                          _monthDayRadio = Icons
                                                              .radio_button_checked;
                                                          weekDayRadio = Icons
                                                              .radio_button_unchecked;
                                                        },
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        inputFormatters: <
                                                            TextInputFormatter>[
                                                          FilteringTextInputFormatter
                                                              .digitsOnly
                                                        ],
                                                        maxLines: null,
                                                        style: TextStyle(
                                                            fontSize: 13,
                                                            color:
                                                                defaultTextColor,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                        decoration:
                                                            InputDecoration(
                                                          isDense: true,
                                                          suffix: Container(
                                                            height: 25,
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .end,
                                                              children: <
                                                                  Widget>[
                                                                IconButton(
                                                                  icon: Icon(
                                                                      Icons
                                                                          .arrow_drop_down_outlined,
                                                                      color:
                                                                          defaultColor),
                                                                  onPressed:
                                                                      () {
                                                                    _removeDay();
                                                                  },
                                                                ),
                                                                IconButton(
                                                                  icon: Icon(
                                                                    Icons
                                                                        .arrow_drop_up_outlined,
                                                                    color:
                                                                        defaultColor,
                                                                  ),
                                                                  onPressed:
                                                                      () {
                                                                    _addDay();
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          focusColor: widget
                                                              .model
                                                              .backgroundColor,
                                                          border:
                                                              const UnderlineInputBorder(),
                                                          focusedBorder: UnderlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: widget
                                                                      .model
                                                                      .backgroundColor,
                                                                  width: 2.0,
                                                                  style: BorderStyle
                                                                      .solid)),
                                                        ),
                                                      )),
                                                ),
                                              ]),
                                        ])),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Visibility(
                                  visible: _selectedRecurrenceType != 'Never',
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        left: _padding, top: 2, bottom: 2),
                                    margin: EdgeInsets.only(left: _margin),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text('End',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: defaultColor,
                                                fontWeight: FontWeight.w300),
                                            textAlign: TextAlign.start),
                                        Padding(
                                            padding: EdgeInsets.only(
                                                top: _selectedRecurrenceType ==
                                                        'Monthly'
                                                    ? 9
                                                    : 0),
                                            child: Row(
                                                crossAxisAlignment:
                                                    _selectedRecurrenceType ==
                                                            'Monthly'
                                                        ? CrossAxisAlignment
                                                            .center
                                                        : CrossAxisAlignment
                                                            .start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                mainAxisSize:
                                                    _selectedRecurrenceType ==
                                                            'Monthly'
                                                        ? MainAxisSize.max
                                                        : MainAxisSize.min,
                                                children: <Widget>[
                                                  Expanded(
                                                      flex: 3,
                                                      child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  bottom: 6),
                                                          child: TextField(
                                                            mouseCursor:
                                                                MaterialStateMouseCursor
                                                                    .clickable,
                                                            controller:
                                                                TextEditingController(
                                                                    text:
                                                                        _selectedRecurrenceRange),
                                                            decoration:
                                                                InputDecoration(
                                                              isDense: true,
                                                              suffix: Container(
                                                                height: 27,
                                                                child: DropdownButton<
                                                                        String>(
                                                                    isExpanded:
                                                                        true,
                                                                    underline:
                                                                        Container(),
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            13,
                                                                        color:
                                                                            defaultTextColor,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w400),
                                                                    value:
                                                                        _selectedRecurrenceRange,
                                                                    items: ends.map(
                                                                        (String
                                                                            item) {
                                                                      return DropdownMenuItem<
                                                                          String>(
                                                                        value:
                                                                            item,
                                                                        child: Text(
                                                                            item),
                                                                      );
                                                                    }).toList(),
                                                                    onChanged:
                                                                        (String?
                                                                            value) {
                                                                      setState(
                                                                          () {
                                                                        if (value ==
                                                                            'Never') {
                                                                          _noEndDateRange();
                                                                        } else if (value ==
                                                                            'Count') {
                                                                          _countRange();
                                                                        } else if (value ==
                                                                            'Until') {
                                                                          _endDateRange();
                                                                        }
                                                                      });
                                                                    }),
                                                              ),
                                                              focusColor: widget
                                                                  .model
                                                                  .backgroundColor,
                                                              border:
                                                                  const UnderlineInputBorder(),
                                                              focusedBorder: UnderlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                      color: widget
                                                                          .model
                                                                          .backgroundColor,
                                                                      width:
                                                                          2.0,
                                                                      style: BorderStyle
                                                                          .solid)),
                                                            ),
                                                          ))),
                                                  Expanded(
                                                      flex:
                                                          _selectedRecurrenceRange ==
                                                                  'Count'
                                                              ? 3
                                                              : 0,
                                                      child: Visibility(
                                                        visible:
                                                            _selectedRecurrenceRange ==
                                                                'Count',
                                                        child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 9,
                                                                    bottom: 0),
                                                            child: TextField(
                                                              textAlignVertical:
                                                                  TextAlignVertical
                                                                      .center,
                                                              controller: TextEditingController.fromValue(TextEditingValue(
                                                                  text: _count
                                                                      .toString(),
                                                                  selection: TextSelection.collapsed(
                                                                      offset: _count
                                                                          .toString()
                                                                          .length))),
                                                              cursorColor: widget
                                                                  .model
                                                                  .backgroundColor,
                                                              onChanged: (String
                                                                  value) async {
                                                                if (value
                                                                    .isNotEmpty) {
                                                                  _count =
                                                                      int.parse(
                                                                          value);
                                                                  if (_count ==
                                                                      0) {
                                                                    _count = 1;
                                                                  } else if (_count! >=
                                                                      999) {
                                                                    _count =
                                                                        999;
                                                                  }
                                                                  _recurrenceProperties!
                                                                          .recurrenceRange =
                                                                      RecurrenceRange
                                                                          .count;
                                                                  _selectedRecurrenceRange =
                                                                      'Count';
                                                                  _recurrenceProperties!
                                                                          .recurrenceCount =
                                                                      _count!;
                                                                } else if (value
                                                                    .isEmpty) {
                                                                  _noEndDateRange();
                                                                }
                                                              },
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              inputFormatters: <
                                                                  TextInputFormatter>[
                                                                FilteringTextInputFormatter
                                                                    .digitsOnly
                                                              ],
                                                              maxLines: null,
                                                              style: TextStyle(
                                                                  fontSize: 13,
                                                                  color:
                                                                      defaultTextColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                              decoration:
                                                                  InputDecoration(
                                                                isDense: true,
                                                                contentPadding:
                                                                    EdgeInsets.only(
                                                                        top: _selectedRecurrenceType ==
                                                                                'Monthly'
                                                                            ? 13
                                                                            : 18,
                                                                        bottom:
                                                                            10),
                                                                suffixIconConstraints:
                                                                    const BoxConstraints(
                                                                        maxHeight:
                                                                            30),
                                                                suffixIcon: Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .end,
                                                                  children: <
                                                                      Widget>[
                                                                    IconButton(
                                                                        icon:
                                                                            Icon(
                                                                          Icons
                                                                              .arrow_drop_down,
                                                                          color:
                                                                              defaultColor,
                                                                        ),
                                                                        padding:
                                                                            EdgeInsets
                                                                                .zero,
                                                                        onPressed:
                                                                            _removeCount),
                                                                    IconButton(
                                                                        padding:
                                                                            EdgeInsets
                                                                                .zero,
                                                                        icon: Icon(
                                                                            Icons
                                                                                .arrow_drop_up,
                                                                            color:
                                                                                defaultColor),
                                                                        onPressed:
                                                                            _addCount),
                                                                  ],
                                                                ),
                                                                focusColor: widget
                                                                    .model
                                                                    .backgroundColor,
                                                                border:
                                                                    const UnderlineInputBorder(),
                                                                focusedBorder: UnderlineInputBorder(
                                                                    borderSide: BorderSide(
                                                                        color: widget
                                                                            .model
                                                                            .backgroundColor,
                                                                        width:
                                                                            2.0,
                                                                        style: BorderStyle
                                                                            .solid)),
                                                              ),
                                                            )),
                                                      )),
                                                  Expanded(
                                                      flex:
                                                          _selectedRecurrenceRange ==
                                                                  'Until'
                                                              ? 3
                                                              : 0,
                                                      child: Visibility(
                                                          visible:
                                                              _selectedRecurrenceRange ==
                                                                  'Until',
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    bottom: 0,
                                                                    left: 9),
                                                            child: TextField(
                                                              textAlignVertical:
                                                                  TextAlignVertical
                                                                      .top,
                                                              readOnly: true,
                                                              controller: TextEditingController(
                                                                  text: DateFormat(
                                                                          'MM/dd/yyyy')
                                                                      .format(
                                                                          _selectedDate)),
                                                              onChanged: (String
                                                                  value) {
                                                                _selectedDate =
                                                                    DateTime.parse(
                                                                        value);
                                                              },
                                                              keyboardType:
                                                                  TextInputType
                                                                      .datetime,
                                                              maxLines: null,
                                                              style: TextStyle(
                                                                  fontSize: 13,
                                                                  color:
                                                                      defaultTextColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                              decoration:
                                                                  InputDecoration(
                                                                isDense: true,
                                                                contentPadding: EdgeInsets.only(
                                                                    top: _selectedRecurrenceType ==
                                                                            'Monthly'
                                                                        ? 10
                                                                        : 15,
                                                                    bottom: _selectedRecurrenceType ==
                                                                            'Monthly'
                                                                        ? 10
                                                                        : 13),
                                                                suffixIconConstraints:
                                                                    const BoxConstraints(
                                                                        maxHeight:
                                                                            30),
                                                                suffixIcon:
                                                                    ButtonTheme(
                                                                        minWidth:
                                                                            30.0,
                                                                        child:
                                                                            MaterialButton(
                                                                          elevation:
                                                                              0,
                                                                          focusElevation:
                                                                              0,
                                                                          highlightElevation:
                                                                              0,
                                                                          disabledElevation:
                                                                              0,
                                                                          hoverElevation:
                                                                              0,
                                                                          onPressed:
                                                                              () async {
                                                                            final DateTime? pickedDate = await showDatePicker(
                                                                                context: context,
                                                                                initialDate: _selectedDate,
                                                                                firstDate: _startDate.isBefore(_firstDate) ? _startDate : _firstDate,
                                                                                currentDate: _selectedDate,
                                                                                lastDate: DateTime(2050),
                                                                                builder: (BuildContext context, Widget? child) {
                                                                                  return Theme(
                                                                                    data: ThemeData(brightness: temaApp.brightness, colorScheme: getColorScheme(widget.model, true), primaryColor: widget.model.backgroundColor),
                                                                                    child: child!,
                                                                                  );
                                                                                });
                                                                            if (pickedDate ==
                                                                                null) {
                                                                              return;
                                                                            }
                                                                            setState(() {
                                                                              _selectedDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
                                                                              _recurrenceProperties!.endDate = _selectedDate;
                                                                            });
                                                                          },
                                                                          shape:
                                                                              const CircleBorder(),
                                                                          padding:
                                                                              const EdgeInsets.all(10.0),
                                                                          child:
                                                                              Icon(
                                                                            Icons.date_range,
                                                                            color:
                                                                                defaultColor,
                                                                            size:
                                                                                20,
                                                                          ),
                                                                        )),
                                                                focusColor: widget
                                                                    .model
                                                                    .backgroundColor,
                                                                border:
                                                                    const UnderlineInputBorder(),
                                                                focusedBorder: UnderlineInputBorder(
                                                                    borderSide: BorderSide(
                                                                        color: widget
                                                                            .model
                                                                            .backgroundColor,
                                                                        width:
                                                                            2.0,
                                                                        style: BorderStyle
                                                                            .solid)),
                                                              ),
                                                            ),
                                                          ))),
                                                  Spacer(
                                                      flex: _selectedRecurrenceType ==
                                                              'Daily'
                                                          ? _selectedRecurrenceRange ==
                                                                  'Never'
                                                              ? 8
                                                              : 6
                                                          : _selectedRecurrenceRange ==
                                                                  'Never'
                                                              ? 2
                                                              : 1)
                                                ])),
                                      ],
                                    ),
                                  )),
                            ),
                          ],
                        ),
                      )),
                  Visibility(
                    visible: _selectedRecurrenceType == 'Yearly',
                    child: Container(
                      width: 284,
                      height: 50,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                                child: Row(children: <Widget>[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 12),
                                width: 50,
                                child: IconButton(
                                  onPressed: () {
                                    _monthDayIcon();
                                  },
                                  icon: Icon(_monthDayRadio),
                                  color: _monthIconColor,
                                  focusColor: widget.model.backgroundColor,
                                  iconSize: 20,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text('  Day   ',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: defaultTextColor,
                                        fontWeight: FontWeight.w400)),
                              ),
                              Container(
                                width: 208,
                                height: 28,
                                child: TextField(
                                  controller: TextEditingController.fromValue(
                                      TextEditingValue(
                                          text: _dayOfMonth.toString(),
                                          selection: TextSelection.collapsed(
                                              offset: _dayOfMonth
                                                  .toString()
                                                  .length))),
                                  cursorColor: widget.model.backgroundColor,
                                  onChanged: (String value) {
                                    if (value.isNotEmpty) {
                                      _dayOfMonth = int.parse(value);
                                      if (_dayOfMonth == 0) {
                                        _dayOfMonth = _startDate.day;
                                      } else if (_dayOfMonth >= 31) {
                                        _dayOfMonth = 31;
                                      }
                                    } else if (value.isEmpty) {
                                      _dayOfMonth = _startDate.day;
                                    }
                                    _recurrenceProperties!.dayOfWeek = 0;
                                    _recurrenceProperties!.week = 0;
                                    _recurrenceProperties!.dayOfMonth =
                                        _dayOfMonth;
                                    _weekIconColor =
                                        temaApp.brightness == Brightness.dark
                                            ? Colors.white
                                            : Colors.black54;
                                    _monthIconColor =
                                        widget.model.backgroundColor;
                                    _monthDayRadio = Icons.radio_button_checked;
                                    weekDayRadio = Icons.radio_button_unchecked;
                                  },
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  maxLines: null,
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: defaultTextColor,
                                      fontWeight: FontWeight.w400),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    suffix: Container(
                                      height: 25,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: <Widget>[
                                          IconButton(
                                              icon: Icon(
                                                  Icons
                                                      .arrow_drop_down_outlined,
                                                  color: defaultColor),
                                              onPressed: _removeDay),
                                          IconButton(
                                              icon: Icon(
                                                Icons.arrow_drop_up_outlined,
                                                color: defaultColor,
                                              ),
                                              onPressed: _addDay),
                                        ],
                                      ),
                                    ),
                                    focusColor: widget.model.backgroundColor,
                                    border: const UnderlineInputBorder(),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: widget.model.backgroundColor,
                                            width: 2.0,
                                            style: BorderStyle.solid)),
                                  ),
                                ),
                              ),
                            ])),
                          ]),
                    ),
                  ),
                  Visibility(
                      visible: _selectedRecurrenceType == 'Monthly' ||
                          _selectedRecurrenceType == 'Yearly',
                      child: Container(
                        padding: const EdgeInsets.only(top: 10),
                        width: 284,
                        height: 40,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                width: 50,
                                child: IconButton(
                                  onPressed: () {
                                    _monthWeekIcon();
                                  },
                                  icon: Icon(weekDayRadio),
                                  color: _weekIconColor,
                                  iconSize: 20,
                                ),
                              ),
                              Row(
                                children: <Widget>[
                                  Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    width: 102,
                                    child: TextField(
                                      mouseCursor:
                                          MaterialStateMouseCursor.clickable,
                                      controller: TextEditingController(
                                          text: _weekNumberText),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        suffix: Container(
                                          height: 25,
                                          child: DropdownButton<String>(
                                              isExpanded: true,
                                              value: _weekNumberText,
                                              underline: Container(),
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: defaultTextColor,
                                                  fontWeight: FontWeight.w400),
                                              items: daysPosition
                                                  .map((String item) {
                                                return DropdownMenuItem<String>(
                                                  value: item,
                                                  child: Text(item),
                                                );
                                              }).toList(),
                                              onChanged: (String? value) {
                                                setState(() {
                                                  if (value == 'First') {
                                                    _weekNumberText = 'First';
                                                    _weekNumber = 1;
                                                    _recurrenceProperties!
                                                        .week = _weekNumber;
                                                    _monthWeekIcon();
                                                  } else if (value ==
                                                      'Second') {
                                                    _weekNumberText = 'Second';
                                                    _weekNumber = 2;
                                                    _recurrenceProperties!
                                                        .week = _weekNumber;
                                                    _monthWeekIcon();
                                                  } else if (value == 'Third') {
                                                    _weekNumberText = 'Third';
                                                    _weekNumber = 3;
                                                    _recurrenceProperties!
                                                        .week = _weekNumber;
                                                    _monthWeekIcon();
                                                  } else if (value ==
                                                      'Fourth') {
                                                    _weekNumberText = 'Fourth';
                                                    _weekNumber = 4;
                                                    _recurrenceProperties!
                                                        .week = _weekNumber;
                                                    _monthWeekIcon();
                                                  } else if (value == 'Last') {
                                                    _weekNumberText = 'Last';
                                                    _weekNumber = -1;
                                                    _recurrenceProperties!
                                                        .week = _weekNumber;
                                                    _monthWeekIcon();
                                                  }
                                                });
                                              }),
                                        ),
                                        focusColor:
                                            widget.model.backgroundColor,
                                        border: const UnderlineInputBorder(),
                                        focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: widget
                                                    .model.backgroundColor,
                                                width: 2.0,
                                                style: BorderStyle.solid)),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 127,
                                    margin: const EdgeInsets.only(left: 10),
                                    child: TextField(
                                      mouseCursor:
                                          MaterialStateMouseCursor.clickable,
                                      controller: TextEditingController(
                                          text: _dayOfWeekText),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        suffix: Container(
                                          height: 25,
                                          child: DropdownButton<String>(
                                              isExpanded: true,
                                              value: _dayOfWeekText,
                                              underline: Container(),
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: defaultTextColor,
                                                  fontWeight: FontWeight.w400),
                                              items: weekDay.map((String item) {
                                                return DropdownMenuItem<String>(
                                                  value: item,
                                                  child: Text(item),
                                                );
                                              }).toList(),
                                              onChanged: (String? value) {
                                                setState(() {
                                                  if (value == 'Sunday') {
                                                    _dayOfWeekText = 'Sunday';
                                                    _dayOfWeek = 7;
                                                    _recurrenceProperties!
                                                        .dayOfWeek = _dayOfWeek;
                                                    _monthWeekIcon();
                                                  } else if (value ==
                                                      'Monday') {
                                                    _dayOfWeekText = 'Monday';
                                                    _dayOfWeek = 1;
                                                    _recurrenceProperties!
                                                        .dayOfWeek = _dayOfWeek;
                                                    _monthWeekIcon();
                                                  } else if (value ==
                                                      'Tuesday') {
                                                    _dayOfWeekText = 'Tuesday';
                                                    _dayOfWeek = 2;
                                                    _recurrenceProperties!
                                                        .dayOfWeek = _dayOfWeek;
                                                    _monthWeekIcon();
                                                  } else if (value ==
                                                      'Wednesday') {
                                                    _dayOfWeekText =
                                                        'Wednesday';
                                                    _dayOfWeek = 3;
                                                    _recurrenceProperties!
                                                        .dayOfWeek = _dayOfWeek;
                                                    _monthWeekIcon();
                                                  } else if (value ==
                                                      'Thursday') {
                                                    _dayOfWeekText = 'Thursday';
                                                    _dayOfWeek = 4;
                                                    _recurrenceProperties!
                                                        .dayOfWeek = _dayOfWeek;
                                                    _monthWeekIcon();
                                                  } else if (value ==
                                                      'Friday') {
                                                    _dayOfWeekText = 'Friday';
                                                    _dayOfWeek = 5;
                                                    _recurrenceProperties!
                                                        .dayOfWeek = _dayOfWeek;
                                                    _monthWeekIcon();
                                                  } else if (value ==
                                                      'Saturday') {
                                                    _dayOfWeekText = 'Saturday';
                                                    _dayOfWeek = 6;
                                                    _recurrenceProperties!
                                                        .dayOfWeek = _dayOfWeek;
                                                    _monthWeekIcon();
                                                  }
                                                });
                                              }),
                                        ),
                                        focusColor:
                                            widget.model.backgroundColor,
                                        border: const UnderlineInputBorder(),
                                        focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: widget
                                                    .model.backgroundColor,
                                                width: 2.0,
                                                style: BorderStyle.solid)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ]),
                      )),
                  Container(
                    height: 5,
                  ),
                  if (widget.events.resources == null ||
                      widget.events.resources!.isEmpty)
                    Container()
                  else
                    Container(
                        child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 2, horizontal: 20),
                      title: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Employees',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: defaultColor,
                                  fontWeight: FontWeight.w300),
                              textAlign: TextAlign.start,
                            ),
                            Container(
                              width: 600,
                              height: 50,
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: defaultColor.withOpacity(0.4),
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              child: _getResourceEditor(TextStyle(
                                  fontSize: 13,
                                  color: defaultColor,
                                  fontWeight: FontWeight.w400)),
                            )
                          ]),
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
                                    _selectedResources,
                                    widget.events.resources);
                              },
                            );
                          },
                        ).then((dynamic value) => setState(() {
                              /// update the color picker changes
                            }));
                      },
                    )),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Description',
                          style: TextStyle(
                              fontSize: 12,
                              color: defaultColor,
                              fontWeight: FontWeight.w300),
                          textAlign: TextAlign.start,
                        ),
                        Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: TextField(
                              controller: TextEditingController(text: _notes),
                              cursorColor: widget.model.backgroundColor,
                              onChanged: (String value) {
                                _notes = value;
                              },
                              keyboardType: TextInputType.multiline,
                              maxLines: widget.model.isWebFullView ? 1 : null,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: defaultTextColor,
                                  fontWeight: FontWeight.w400),
                              decoration: InputDecoration(
                                isDense: true,
                                focusColor: widget.model.backgroundColor,
                                border: const UnderlineInputBorder(),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: widget.model.backgroundColor,
                                        width: 2.0,
                                        style: BorderStyle.solid)),
                              ),
                            )),
                      ],
                    ),
                  ),
                  Container(
                      child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 2, horizontal: 20),
                          title: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: defaultColor.withOpacity(0.4),
                                  width: 1.0,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                  child: RawMaterialButton(
                                    padding: const EdgeInsets.only(left: 5),
                                    onPressed: () {
                                      showDialog<Widget>(
                                        context: context,
                                        barrierDismissible: true,
                                        builder: (BuildContext context) {
                                          return CalendarColorPicker(
                                            widget.colorCollection,
                                            _selectedColorIndex,
                                            widget.colorCollection,
                                            widget.model,
                                            onChanged:
                                                (PickerChangedDetails details) {
                                              _selectedColorIndex =
                                                  details.index;
                                            },
                                          );
                                        },
                                      ).then((dynamic value) => setState(() {
                                            /// update the color picker changes
                                          }));
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(
                                          Icons.lens,
                                          size: 20,
                                          color: HexColor.fromHex(widget
                                              .colorCollection[
                                                  _selectedColorIndex]
                                              .backgroundColor),
                                        ),
                                        Expanded(
                                          flex: 9,
                                          child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 5),
                                              child: Text(
                                                widget
                                                    .colorCollection[
                                                        _selectedColorIndex]
                                                    .tipoconsulta,
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    color: defaultTextColor,
                                                    fontWeight:
                                                        FontWeight.w400),
                                              )),
                                        ),
                                        const Icon(
                                          Icons.arrow_drop_down,
                                          size: 24,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))),
                ],
              ),
            ),
            Container(
                margin: const EdgeInsets.symmetric(vertical: 3),
                child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: RawMaterialButton(
                          onPressed: () {
                            if (widget.newAppointment != null) {
                              widget.events.appointments!.removeAt(widget
                                  .events.appointments!
                                  .indexOf(widget.newAppointment));
                              widget.events.notifyListeners(
                                  CalendarDataSourceAction.remove,
                                  <Appointment>[widget.newAppointment!]);
                            }
                            Navigator.pop(context);
                          },
                          child: Text(
                            'CANCEL',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: defaultTextColor),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: RawMaterialButton(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                          fillColor: widget.model.backgroundColor,
                          onPressed: () {
                            if ((widget.selectedAppointment.recurrenceRule !=
                                        null &&
                                    widget.selectedAppointment.recurrenceRule!
                                        .isNotEmpty) ||
                                widget.selectedAppointment.recurrenceId !=
                                    null) {
                              if (!_canAddRecurrenceAppointment(
                                  widget.visibleDates,
                                  widget.events,
                                  widget.selectedAppointment,
                                  _startDate)) {
                                showDialog<Widget>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return WillPopScope(
                                          onWillPop: () async {
                                            return true;
                                          },
                                          child: Theme(
                                            data: temaApp,
                                            child: AlertDialog(
                                                title: const Text('Alert'),
                                                content: const Text(
                                                    'Two occurrences of the same event cannot occur on the same day'),
                                                actions: <Widget>[
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: const Text('OK'),
                                                  ),
                                                ]),
                                          ));
                                    });
                                return;
                              }
                            }

                            /// Add conditional code here recurrence can add re
                            if (widget.selectedAppointment.appointmentType !=
                                    AppointmentType.normal &&
                                widget.selectedAppointment.recurrenceId ==
                                    null) {
                              if (widget.selectedAppointment
                                      .recurrenceExceptionDates ==
                                  null) {
                                widget.events.appointments!.removeAt(widget
                                    .events.appointments!
                                    .indexOf(widget.selectedAppointment));
                                widget.events.notifyListeners(
                                    CalendarDataSourceAction.remove,
                                    <Appointment>[widget.selectedAppointment]);
                                final Appointment newAppointment = Appointment(
                                  startTime: _startDate,
                                  endTime: _endDate,
                                  color: HexColor.fromHex(widget
                                      .colorCollection[_selectedColorIndex]
                                      .backgroundColor),
                                  notes: _notes,
                                  isAllDay: _isAllDay,
                                  location: _location,
                                  subject:
                                      _subject == '' ? '(No title)' : _subject,
                                  resourceIds: _resourceIds,
                                  recurrenceExceptionDates: null,
                                  id: widget.selectedAppointment.id,
                                  recurrenceId: null,
                                  recurrenceRule: _recurrenceProperties ==
                                              null ||
                                          _selectedRecurrenceType == 'Never' ||
                                          widget.selectedAppointment
                                                  .recurrenceId !=
                                              null
                                      ? null
                                      : SfCalendar.generateRRule(
                                          _recurrenceProperties!,
                                          _startDate,
                                          _endDate),
                                );
                                widget.events.appointments!.add(newAppointment);
                                widget.events.notifyListeners(
                                    CalendarDataSourceAction.add,
                                    <Appointment>[newAppointment]);
                                Navigator.pop(context);
                              } else {
                                final Appointment recurrenceAppointment =
                                    Appointment(
                                  startTime: _startDate,
                                  endTime: _endDate,
                                  color: HexColor.fromHex(widget
                                      .colorCollection[_selectedColorIndex]
                                      .backgroundColor),
                                  notes: _notes,
                                  isAllDay: _isAllDay,
                                  location: _location,
                                  subject:
                                      _subject == '' ? '(No title)' : _subject,
                                  resourceIds: _resourceIds,
                                  id: widget.selectedAppointment.id,
                                  recurrenceId: null,
                                  recurrenceExceptionDates: null,
                                  recurrenceRule: _recurrenceProperties ==
                                              null ||
                                          _selectedRecurrenceType == 'Never' ||
                                          widget.selectedAppointment
                                                  .recurrenceId !=
                                              null
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
                                              child: _editExceptionSeries(
                                                  context,
                                                  widget.model,
                                                  widget.selectedAppointment,
                                                  recurrenceAppointment,
                                                  widget.events)));
                                    });
                              }
                            } else if (widget
                                    .selectedAppointment.recurrenceId !=
                                null) {
                              final Appointment? parentAppointment =
                                  widget.events.getPatternAppointment(
                                          widget.selectedAppointment, '')
                                      as Appointment?;
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
                              widget.events.appointments!
                                  .add(parentAppointment);
                              widget.events.notifyListeners(
                                  CalendarDataSourceAction.add,
                                  <Appointment>[parentAppointment]);
                              if (widget.newAppointment != null) {
                                if (widget.events.appointments!.isNotEmpty &&
                                    widget.events.appointments!
                                        .contains(widget.selectedAppointment)) {
                                  widget.events.appointments!.removeAt(widget
                                      .events.appointments!
                                      .indexOf(widget.selectedAppointment));
                                  widget.events.notifyListeners(
                                      CalendarDataSourceAction.remove,
                                      <Appointment>[
                                        widget.selectedAppointment
                                      ]);
                                }
                                if (widget.appointment.isNotEmpty &&
                                    widget.appointment
                                        .contains(widget.newAppointment)) {
                                  widget.appointment.removeAt(widget.appointment
                                      .indexOf(widget.newAppointment!));
                                }

                                if (widget.newAppointment != null &&
                                    widget.events.appointments!.isNotEmpty &&
                                    widget.events.appointments!
                                        .contains(widget.newAppointment)) {
                                  widget.events.appointments!.removeAt(widget
                                      .events.appointments!
                                      .indexOf(widget.newAppointment));
                                  widget.events.notifyListeners(
                                      CalendarDataSourceAction.remove,
                                      <Appointment>[widget.newAppointment!]);
                                }
                              }
                              widget.appointment.add(Appointment(
                                startTime: _startDate,
                                endTime: _endDate,
                                color: HexColor.fromHex(widget
                                    .colorCollection[_selectedColorIndex]
                                    .backgroundColor),
                                notes: _notes,
                                isAllDay: _isAllDay,
                                location: _location,
                                subject:
                                    _subject == '' ? '(No title)' : _subject,
                                resourceIds: _resourceIds,
                                id: widget.selectedAppointment.id,
                                recurrenceId:
                                    widget.selectedAppointment.recurrenceId,
                                recurrenceRule: null,
                              ));
                              widget.events.appointments!
                                  .add(widget.appointment[0]);
                              widget.events.notifyListeners(
                                  CalendarDataSourceAction.add,
                                  widget.appointment);
                              Navigator.pop(context);
                            } else {
                              if (widget.newAppointment != null) {
                                if (widget.events.appointments!.isNotEmpty &&
                                    widget.events.appointments!
                                        .contains(widget.selectedAppointment)) {
                                  widget.events.appointments!.removeAt(widget
                                      .events.appointments!
                                      .indexOf(widget.selectedAppointment));
                                  widget.events.notifyListeners(
                                      CalendarDataSourceAction.remove,
                                      <Appointment>[
                                        widget.selectedAppointment
                                      ]);
                                }
                                if (widget.appointment.isNotEmpty &&
                                    widget.appointment
                                        .contains(widget.newAppointment)) {
                                  widget.appointment.removeAt(widget.appointment
                                      .indexOf(widget.newAppointment!));
                                }

                                if (widget.newAppointment != null &&
                                    widget.events.appointments!.isNotEmpty &&
                                    widget.events.appointments!
                                        .contains(widget.newAppointment)) {
                                  widget.events.appointments!.removeAt(widget
                                      .events.appointments!
                                      .indexOf(widget.newAppointment));
                                  widget.events.notifyListeners(
                                      CalendarDataSourceAction.remove,
                                      <Appointment>[widget.newAppointment!]);
                                }
                              }
                              widget.appointment.add(Appointment(
                                startTime: _startDate,
                                endTime: _endDate,
                                color: HexColor.fromHex(widget
                                    .colorCollection[_selectedColorIndex]
                                    .backgroundColor),
                                notes: _notes,
                                isAllDay: _isAllDay,
                                location: _location,
                                subject:
                                    _subject == '' ? '(No title)' : _subject,
                                resourceIds: _resourceIds,
                                id: widget.selectedAppointment.id,
                                recurrenceId:
                                    widget.selectedAppointment.recurrenceId,
                                recurrenceRule: _recurrenceProperties == null ||
                                        _selectedRecurrenceType == 'Never' ||
                                        widget.selectedAppointment
                                                .recurrenceId !=
                                            null
                                    ? null
                                    : SfCalendar.generateRRule(
                                        _recurrenceProperties!,
                                        _startDate,
                                        _endDate),
                              ));
                              widget.events.appointments!
                                  .add(widget.appointment[0]);
                              widget.events.notifyListeners(
                                  CalendarDataSourceAction.add,
                                  widget.appointment);
                              Navigator.pop(context);
                            }
                          },
                          child: const Text(
                            'SAVE',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

bool _canAddRecurrenceAppointment(
    List<DateTime> visibleDates,
    CalendarDataSource dataSource,
    Appointment occurrenceAppointment,
    DateTime startTime) {
  final Appointment parentAppointment = dataSource.getPatternAppointment(
      occurrenceAppointment, '')! as Appointment;
  final List<DateTime> recurrenceDates =
      SfCalendar.getRecurrenceDateTimeCollection(
          parentAppointment.recurrenceRule ?? '', parentAppointment.startTime,
          specificStartDate: visibleDates[0],
          specificEndDate: visibleDates[visibleDates.length - 1]);

  for (int i = 0; i < dataSource.appointments!.length; i++) {
    final Appointment calendarApp = dataSource.appointments![i] as Appointment;
    if (calendarApp.recurrenceId != null &&
        calendarApp.recurrenceId == parentAppointment.id) {
      recurrenceDates.add(calendarApp.startTime);
    }
  }

  if (parentAppointment.recurrenceExceptionDates != null) {
    for (int i = 0;
        i < parentAppointment.recurrenceExceptionDates!.length;
        i++) {
      recurrenceDates.remove(parentAppointment.recurrenceExceptionDates![i]);
    }
  }

  recurrenceDates.sort();
  bool canAddRecurrence =
      isSameDate(occurrenceAppointment.startTime, startTime);
  if (!_isDateInDateCollection(recurrenceDates, startTime)) {
    final int currentRecurrenceIndex =
        recurrenceDates.indexOf(occurrenceAppointment.startTime);
    if (currentRecurrenceIndex == 0 ||
        currentRecurrenceIndex == recurrenceDates.length - 1) {
      canAddRecurrence = true;
    } else if (currentRecurrenceIndex < 0) {
      canAddRecurrence = false;
    } else {
      final DateTime previousRecurrence =
          recurrenceDates[currentRecurrenceIndex - 1];
      final DateTime nextRecurrence =
          recurrenceDates[currentRecurrenceIndex + 1];
      canAddRecurrence = (isDateWithInDateRange(
                  previousRecurrence, nextRecurrence, startTime) &&
              !isSameDate(previousRecurrence, startTime) &&
              !isSameDate(nextRecurrence, startTime)) ||
          canAddRecurrence;
    }
  }

  return canAddRecurrence;
}

bool _isDateInDateCollection(List<DateTime>? dates, DateTime date) {
  if (dates == null || dates.isEmpty) {
    return false;
  }

  for (final DateTime currentDate in dates) {
    if (isSameDate(currentDate, date)) {
      return true;
    }
  }

  return false;
}
