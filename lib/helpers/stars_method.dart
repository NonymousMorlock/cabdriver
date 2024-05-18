import 'package:cabdriver/widgets/stars.dart';

StarsWidget stars({required int votes, required double rating}) {
  if (votes == 0) {
    return const StarsWidget(numberOfStars: 0);
  } else {
    final finalRate = rating / votes;
    return StarsWidget(numberOfStars: finalRate.floor());
  }
}
