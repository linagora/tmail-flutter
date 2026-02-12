import 'package:cupertino_stepper/cupertino_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

/// A platform aware replacement for the material Stepper widget
class PlatformStepper extends StatelessWidget {
  final Key? widgetKey;
  final List<Step> steps;
  final ScrollPhysics? physics;
  final StepperType type;
  final int currentStep;
  final void Function(int)? onStepTapped;
  final void Function()? onStepContinue;
  final void Function()? onStepCancel;

  /// The callback for creating custom controls.
  ///
  /// If null, the default controls from the current theme will be used.
  ///
  /// This callback which takes in a context and a [ControlsDetails] object, which
  /// contains step information and two functions: [onStepContinue] and [onStepCancel].
  /// These can be used to control the stepper. For example, reading the
  /// [ControlsDetails.currentStep] value within the callback can change the text
  /// of the continue or cancel button depending on which step users are at.
  ///
  /// {@tool dartpad}
  /// Creates a stepper control with custom buttons.
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   return Stepper(
  ///     controlsBuilder:
  ///       (BuildContext context, ControlsDetails details) {
  ///          return Row(
  ///            children: <Widget>[
  ///              TextButton(
  ///                onPressed: details.onStepContinue,
  ///                child: Text('Continue to Step ${details.stepIndex + 1}'),
  ///              ),
  ///              TextButton(
  ///                onPressed: details.onStepCancel,
  ///                child: Text('Back to Step ${details.stepIndex - 1}'),
  ///              ),
  ///            ],
  ///          );
  ///       },
  ///     steps: const <Step>[
  ///       Step(
  ///         title: Text('A'),
  ///         content: SizedBox(
  ///           width: 100.0,
  ///           height: 100.0,
  ///         ),
  ///       ),
  ///       Step(
  ///         title: Text('B'),
  ///         content: SizedBox(
  ///           width: 100.0,
  ///           height: 100.0,
  ///         ),
  ///       ),
  ///     ],
  ///   );
  /// }
  /// ```
  /// ** See code in examples/api/lib/material/stepper/stepper.controls_builder.0.dart **
  /// {@end-tool}
  final ControlsWidgetBuilder? controlsBuilder;

  const PlatformStepper(
      {Key? key,
      this.widgetKey,
      required this.steps,
      this.physics,
      this.type = StepperType.vertical,
      this.currentStep = 0,
      this.onStepTapped,
      this.onStepContinue,
      this.onStepCancel,
      this.controlsBuilder})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      material: (context, platform) => Stepper(
        key: widgetKey,
        steps: steps,
        physics: physics,
        type: type,
        currentStep: currentStep,
        onStepTapped: onStepTapped,
        onStepCancel: onStepCancel,
        onStepContinue: onStepContinue,
        controlsBuilder: controlsBuilder,
      ),
      cupertino: (context, platform) => CupertinoStepper(
        key: widgetKey,
        steps: steps,
        physics: physics,
        type: type,
        currentStep: currentStep,
        onStepTapped: onStepTapped,
        onStepCancel: onStepCancel,
        onStepContinue: onStepContinue,
        controlsBuilder: controlsBuilder,
      ),
    );
  }
}
