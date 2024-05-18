import 'package:cabdriver/widgets/stars.dart';

StarsWidget stars({int votes, double rating}) {
  if (votes == 0) {
    return const StarsWidget(
      numberOfStars: 0,
    );
  } else {
    final finalRate = rating / votes;
    return StarsWidget(
      numberOfStars: finalRate.floor(),
    );
  }
}
