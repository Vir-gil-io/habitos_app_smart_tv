enum TvSessionType { none, paired, authenticated }

class TvSession {
  final TvSessionType type;
  final String? deviceSecret;

  const TvSession({required this.type, this.deviceSecret});

  static const none = TvSession(type: TvSessionType.none);
}