
import 'package:flutter/material.dart';
import 'package:medicpro/src/models/model.dart';
import 'package:medicpro/src/themes/theme.dart';
import 'package:medicpro/src/utils/variables.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

List<CalendarResource> getSelectedResources(
    List<Object>? resourceIds, List<CalendarResource>? resourceCollection) {
  final List<CalendarResource> _selectedResources = <CalendarResource>[];
  if (resourceIds == null ||
      resourceIds.isEmpty ||
      resourceCollection == null ||
      resourceCollection.isEmpty) {
    return _selectedResources;
  }

  for (int i = 0; i < resourceIds.length; i++) {
    final CalendarResource resourceName =
        getResourceFromId(resourceIds[i], resourceCollection);
    _selectedResources.add(resourceName);
  }

  return _selectedResources;
}


/// Returns the resource from the id passed.
CalendarResource getResourceFromId(
    Object resourceId, List<CalendarResource> resourceCollection) {
  return resourceCollection
      .firstWhere((CalendarResource resource) => resource.id == resourceId);
}

/// Returns the available resource, by filtering the resource collection from
/// the selected resource collection.
List<CalendarResource> getUnSelectedResources(
    List<CalendarResource>? selectedResources,
    List<CalendarResource>? resourceCollection) {
  if (selectedResources == null ||
      selectedResources.isEmpty ||
      resourceCollection == null ||
      resourceCollection.isEmpty) {
    return resourceCollection ?? <CalendarResource>[];
  }

  final List<CalendarResource> collection = resourceCollection.sublist(0);
  for (int i = 0; i < resourceCollection.length; i++) {
    final CalendarResource resource = resourceCollection[i];
    for (int j = 0; j < selectedResources.length; j++) {
      final CalendarResource selectedResource = selectedResources[j];
      if (resource.id == selectedResource.id) {
        collection.remove(resource);
      }
    }
  }

  return collection;
}


/// Returns color scheme based on dark and light theme.
ColorScheme getColorScheme(SampleModel model, bool isDatePicker) {
  /// For time picker used the default surface color based for corresponding
  /// theme, so that the picker background color doesn't cover with the model's
  /// background color.
  if (temaApp.brightness == Brightness.dark) {
    return ColorScheme.dark(
      primary: model.backgroundColor,
      secondary: model.backgroundColor,
      surface: isDatePicker ? model.backgroundColor : Colors.grey[850]!,
    );
  }

  return ColorScheme.light(
    primary: model.backgroundColor,
    secondary: model.backgroundColor,
    surface: isDatePicker ? model.backgroundColor : Colors.white,
  );
}


/// Signature for callback which reports the picker value changed
typedef PickerChanged = void Function(PickerChangedDetails pickerChangedDetails);

/// Details for the [_PickerChanged].
class PickerChangedDetails {
  PickerChangedDetails(
      {this.index = -1,
      this.resourceId,
      this.selectedRule = SelectRule.doesNotRepeat});

  final int index;

  final Object? resourceId;

  final SelectRule? selectedRule;
}
