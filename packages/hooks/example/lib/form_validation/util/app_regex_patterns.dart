class RegexPattern {
  static final RegExp emailExp = RegExp(
    r"^([a-zA-Z0-9_\-])([a-zA-Z0-9_\-.]*)@(\[((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])\.){3}|((([a-zA-Z0-9\-]+)\.)+))([a-zA-Z]{2,}|(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])])$",
  );
  static final RegExp passwordExp = RegExp(r"(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*\W)");
}
