import 'package:meta/meta.dart';

class DialogAction {
  final String title;
  final void Function() onPressed;

  DialogAction({
    @required this.title,
    @required this.onPressed,
  });
}
