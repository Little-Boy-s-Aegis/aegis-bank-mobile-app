class SecurityStatus {
  final bool sqliEnabled;
  final bool xssEnabled;
  final bool idorEnabled;
  final bool paramTamperingEnabled;
  final bool bruteForceEnabled;

  SecurityStatus({
    required this.sqliEnabled,
    required this.xssEnabled,
    required this.idorEnabled,
    required this.paramTamperingEnabled,
    required this.bruteForceEnabled,
  });

  factory SecurityStatus.fromJson(Map<String, dynamic> json) {
    return SecurityStatus(
      sqliEnabled: json['sqliEnabled'] as bool,
      xssEnabled: json['xssEnabled'] as bool,
      idorEnabled: json['idorEnabled'] as bool,
      paramTamperingEnabled: json['paramTamperingEnabled'] as bool,
      bruteForceEnabled: json['bruteForceEnabled'] as bool,
    );
  }
}
