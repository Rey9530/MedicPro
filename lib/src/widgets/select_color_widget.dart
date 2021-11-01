
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:medicpro/src/models/model.dart';
import 'package:medicpro/src/models/models.dart';
import 'package:medicpro/src/providers/providers.dart';
import 'package:medicpro/src/themes/theme.dart';
import 'package:medicpro/src/utils/funciones.dart';
/// The color picker element for the appointment editor with the available
/// color collection, and returns the selection color index
class CalendarColorPicker extends StatefulWidget {
  const CalendarColorPicker(this.colorCollection, this.selectedColorIndex,
      this.colorNames, this.model,
      {required this.onChanged});

  final List<TiposConsultas> colorCollection;

  final int selectedColorIndex;

  final List<TiposConsultas> colorNames;

  final SampleModel model;

  final PickerChanged onChanged;

  @override
  State<StatefulWidget> createState() => CalendarColorPickerState();
}

class CalendarColorPickerState extends State<CalendarColorPicker> {
  int _selectedColorIndex = -1;

  @override
  void initState() {
    _selectedColorIndex = widget.selectedColorIndex;
    super.initState();
  }

  @override
  void didUpdateWidget(CalendarColorPicker oldWidget) {
    _selectedColorIndex = widget.selectedColorIndex;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: temaApp,
      child: AlertDialog(
        content: Container(
            width: kIsWeb ? 500 : double.maxFinite,
            height: (widget.colorCollection.length * 50).toDouble(),
            child: ListView.builder(
              padding: const EdgeInsets.all(0),
              itemCount: widget.colorCollection.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                    height: 50,
                    child: ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10),
                      leading: Icon(
                          index == _selectedColorIndex
                              ? Icons.lens
                              : Icons.trip_origin,
                          color: HexColor.fromHex(
                              widget.colorCollection[index].backgroundColor)),
                      title: Text(widget.colorCollection[index].tipoconsulta),
                      onTap: () {
                        setState(() {
                          _selectedColorIndex = index;
                          widget.onChanged(PickerChangedDetails(index: index));
                        });

                        // ignore: always_specify_types
                        Future.delayed(const Duration(milliseconds: 200), () {
                          // When task is over, close the dialog
                          Navigator.pop(context);
                        });
                      },
                    ));
              },
            )),
      ),
    );
  }
}