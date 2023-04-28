class Option {
  final String option;
  final String value;

  Option({required this.option, required this.value});

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      option: json['option'] ?? '',
      value: json['value'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'option': option,
      'value': value,
    };
  }
}
