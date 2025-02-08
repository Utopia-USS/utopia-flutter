// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'localizations.dart';

// **************************************************************************
// UtopiaLocalizationGenerator
// **************************************************************************

const appLocalizationsData = UtopiaLocalizationData<AppLocalizationsData>({
  'fr': AppLocalizationsData(
    onlyEnglish: 'English-only',
    multiline: 'C\'est\n\nun\n\nexemple multiligne.',
    plurals: AppLocalizationsDataPlurals(
      man_201422728: 'hommes',
      man_116447630: 'homme',
      man_17408168: 'hommes',
    ),
    templated: AppLocalizationsDataTemplated(
      contact_537753378: 'Mme {{last_name}}',
      contact_588305750: 'M. {{last_name}}',
      hello: 'Bonjour {{first_name}}!',
      date: AppLocalizationsDataTemplatedDate(
        pattern: 'Aujourd\'hui : {{date:DateTime[EEE, M/d/y]}}',
        simple: 'Aujourd\'hui : {{date:DateTime}}',
      ),
      numbers: AppLocalizationsDataTemplatedNumbers(
        formatted: 'Le prix est de {{price:double[compactCurrency]}}',
        simple: 'Le prix est de {{price:double}}€',
        count: 'Il y a {{count:int}} éléments.',
      ),
    ),
    dates: AppLocalizationsDataDates(
      month: AppLocalizationsDataDatesMonth(
        april: 'avril',
        march: 'février',
        february: 'février',
        january: 'Janvier',
      ),
      weekday: AppLocalizationsDataDatesWeekday(
        sunday: 'dimanche',
        saturday: 'Samedi',
        friday: 'vendredi',
        thursday: 'Jeudi',
        wednesday: 'Mercredi',
        tuesday: 'Mardi',
        monday: 'LUNDI',
      ),
    ),
  ),
  'en': AppLocalizationsData(
    onlyEnglish: 'English-only',
    multiline: 'This is\n\na\n\nmultiline example.',
    plurals: AppLocalizationsDataPlurals(
      man_201422728: 'men',
      man_116447630: 'man',
      man_17408168: 'man',
    ),
    templated: AppLocalizationsDataTemplated(
      contact_537753378: 'Mrs {{last_name}}!',
      contact_588305750: 'Mr {{last_name}}!',
      hello: 'Hello {{first_name}}!',
      date: AppLocalizationsDataTemplatedDate(
        pattern: 'Today : {{date:DateTime[EEE, M/d/y]}}',
        simple: 'Today : {{date:DateTime}}',
      ),
      numbers: AppLocalizationsDataTemplatedNumbers(
        formatted: 'The price is {{price:double[compactCurrency]}}',
        simple: 'The price is {{price:double}}\$',
        count: 'There are {{count:int}}\ items.',
      ),
    ),
    dates: AppLocalizationsDataDates(
      month: AppLocalizationsDataDatesMonth(
        april: 'april',
        march: 'march',
        february: 'february',
        january: 'january',
      ),
      weekday: AppLocalizationsDataDatesWeekday(
        sunday: 'sunday',
        saturday: 'saturday',
        friday: 'friday',
        thursday: 'thursday',
        wednesday: 'wednesday',
        tuesday: 'tuesday',
        monday: 'MONDAY',
      ),
    ),
  ),
  'zh-Hans-CN': AppLocalizationsData(
    onlyEnglish: 'English-only',
    multiline: '这是\n\n一个\n\n多行示例。',
    plurals: AppLocalizationsDataPlurals(
      man_201422728: '男人',
      man_116447630: '男人',
      man_17408168: '男人',
    ),
    templated: AppLocalizationsDataTemplated(
      contact_537753378: '夫人{{last_name}}',
      contact_588305750: '先生{{last_name}}',
      hello: '你好{{first_name}}!',
      date: AppLocalizationsDataTemplatedDate(
        pattern: '今日 : {{date:DateTime[EEE, M/d/y]}}',
        simple: '今日 : {{date:DateTime}}',
      ),
      numbers: AppLocalizationsDataTemplatedNumbers(
        formatted: '価格は{{price:double[compactCurrency]}}です',
        simple: '価格は{{price:double}}¥です',
        count: '{{count:int}}個のアイテムがあります',
      ),
    ),
    dates: AppLocalizationsDataDates(
      month: AppLocalizationsDataDatesMonth(
        april: '四月',
        march: '游行',
        february: '二月',
        january: '一月',
      ),
      weekday: AppLocalizationsDataDatesWeekday(
        sunday: '星期日',
        saturday: '星期六',
        friday: '星期五',
        thursday: '星期四',
        wednesday: '星期三',
        tuesday: '星期二',
        monday: '星期一',
      ),
    ),
  ),
});

class AppLocalizationsData {
  const AppLocalizationsData({
    required this.onlyEnglish,
    required this.multiline,
    required this.plurals,
    required this.templated,
    required this.dates,
  });

  final String onlyEnglish;
  final String multiline;
  final AppLocalizationsDataPlurals plurals;
  final AppLocalizationsDataTemplated templated;
  final AppLocalizationsDataDates dates;
  factory AppLocalizationsData.fromJson(Map<String, Object?> map) =>
      AppLocalizationsData(
        onlyEnglish: map['onlyEnglish']! as String,
        multiline: map['multiline']! as String,
        plurals: AppLocalizationsDataPlurals.fromJson(
            map['plurals']! as Map<String, Object?>),
        templated: AppLocalizationsDataTemplated.fromJson(
            map['templated']! as Map<String, Object?>),
        dates: AppLocalizationsDataDates.fromJson(
            map['dates']! as Map<String, Object?>),
      );
  Map<String, Object?> toJson() => {
        'onlyEnglish': onlyEnglish,
        'multiline': multiline,
        'plurals': plurals.toJson(),
        'templated': templated.toJson(),
        'dates': dates.toJson(),
      };

  AppLocalizationsData copyWith({
    String? onlyEnglish,
    String? multiline,
    AppLocalizationsDataPlurals? plurals,
    AppLocalizationsDataTemplated? templated,
    AppLocalizationsDataDates? dates,
  }) =>
      AppLocalizationsData(
        onlyEnglish: onlyEnglish ?? this.onlyEnglish,
        multiline: multiline ?? this.multiline,
        plurals: plurals ?? this.plurals,
        templated: templated ?? this.templated,
        dates: dates ?? this.dates,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppLocalizationsData &&
          onlyEnglish == other.onlyEnglish &&
          multiline == other.multiline &&
          plurals == other.plurals &&
          templated == other.templated &&
          dates == other.dates);
  @override
  int get hashCode =>
      runtimeType.hashCode ^
      onlyEnglish.hashCode ^
      multiline.hashCode ^
      plurals.hashCode ^
      templated.hashCode ^
      dates.hashCode;
}

class AppLocalizationsDataPlurals {
  const AppLocalizationsDataPlurals({
    required String man_201422728,
    required String man_116447630,
    required String man_17408168,
  })  : _man_201422728 = man_201422728,
        _man_116447630 = man_116447630,
        _man_17408168 = man_17408168;

  final String _man_201422728;
  final String _man_116447630;
  final String _man_17408168;

  String man(
    Object? _value,
  ) {
    var label = switch (_value) {
      Plural.multiple => _man_201422728,
      Plural.one => _man_116447630,
      Plural.zero => _man_17408168,
      _ => throw Exception("No case available for ${_value}"),
    };
    return label;
  }

  factory AppLocalizationsDataPlurals.fromJson(Map<String, Object?> map) =>
      AppLocalizationsDataPlurals(
        man_201422728: map['man_201422728']! as String,
        man_116447630: map['man_116447630']! as String,
        man_17408168: map['man_17408168']! as String,
      );
  Map<String, Object?> toJson() => {
        'man_201422728': _man_201422728,
        'man_116447630': _man_116447630,
        'man_17408168': _man_17408168,
      };

  AppLocalizationsDataPlurals copyWith({
    String? man_201422728,
    String? man_116447630,
    String? man_17408168,
  }) =>
      AppLocalizationsDataPlurals(
        man_201422728: man_201422728 ?? _man_201422728,
        man_116447630: man_116447630 ?? _man_116447630,
        man_17408168: man_17408168 ?? _man_17408168,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppLocalizationsDataPlurals &&
          _man_201422728 == other._man_201422728 &&
          _man_116447630 == other._man_116447630 &&
          _man_17408168 == other._man_17408168);
  @override
  int get hashCode =>
      runtimeType.hashCode ^
      _man_201422728.hashCode ^
      _man_116447630.hashCode ^
      _man_17408168.hashCode;
}

class AppLocalizationsDataTemplated {
  const AppLocalizationsDataTemplated({
    required String contact_537753378,
    required String contact_588305750,
    required String hello,
    required this.date,
    required this.numbers,
  })  : _contact_537753378 = contact_537753378,
        _contact_588305750 = contact_588305750,
        _hello = hello;

  final String _contact_537753378;
  final String _contact_588305750;
  final String _hello;
  final AppLocalizationsDataTemplatedDate date;
  final AppLocalizationsDataTemplatedNumbers numbers;

  String contact(
    Object? _value, {
    required String lastName,
    String? locale,
  }) {
    var label = switch (_value) {
      Gender.female => _contact_537753378,
      Gender.male => _contact_588305750,
      _ => throw Exception("No case available for ${_value}"),
    };
    label = label.insertTemplateValues(
      {
        'last_name': lastName,
      },
      locale: locale,
    );
    return label;
  }

  String hello({
    required String firstName,
    String? locale,
  }) {
    var label = _hello;
    label = label.insertTemplateValues(
      {
        'first_name': firstName,
      },
      locale: locale,
    );
    return label;
  }

  factory AppLocalizationsDataTemplated.fromJson(Map<String, Object?> map) =>
      AppLocalizationsDataTemplated(
        contact_537753378: map['contact_537753378']! as String,
        contact_588305750: map['contact_588305750']! as String,
        hello: map['hello']! as String,
        date: AppLocalizationsDataTemplatedDate.fromJson(
            map['date']! as Map<String, Object?>),
        numbers: AppLocalizationsDataTemplatedNumbers.fromJson(
            map['numbers']! as Map<String, Object?>),
      );
  Map<String, Object?> toJson() => {
        'contact_537753378': _contact_537753378,
        'contact_588305750': _contact_588305750,
        'hello': _hello,
        'date': date.toJson(),
        'numbers': numbers.toJson(),
      };

  AppLocalizationsDataTemplated copyWith({
    String? contact_537753378,
    String? contact_588305750,
    String? hello,
    AppLocalizationsDataTemplatedDate? date,
    AppLocalizationsDataTemplatedNumbers? numbers,
  }) =>
      AppLocalizationsDataTemplated(
        contact_537753378: contact_537753378 ?? _contact_537753378,
        contact_588305750: contact_588305750 ?? _contact_588305750,
        hello: hello ?? _hello,
        date: date ?? this.date,
        numbers: numbers ?? this.numbers,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppLocalizationsDataTemplated &&
          _contact_537753378 == other._contact_537753378 &&
          _contact_588305750 == other._contact_588305750 &&
          _hello == other._hello &&
          date == other.date &&
          numbers == other.numbers);
  @override
  int get hashCode =>
      runtimeType.hashCode ^
      _contact_537753378.hashCode ^
      _contact_588305750.hashCode ^
      _hello.hashCode ^
      date.hashCode ^
      numbers.hashCode;
}

class AppLocalizationsDataTemplatedDate {
  const AppLocalizationsDataTemplatedDate({
    required String pattern,
    required String simple,
  })  : _pattern = pattern,
        _simple = simple;

  final String _pattern;
  final String _simple;

  String pattern({
    required DateTime date,
    String? locale,
  }) {
    var label = _pattern;
    label = label.insertTemplateValues(
      {
        'date': date,
      },
      locale: locale,
    );
    return label;
  }

  String simple({
    required DateTime date,
    String? locale,
  }) {
    var label = _simple;
    label = label.insertTemplateValues(
      {
        'date': date,
      },
      locale: locale,
    );
    return label;
  }

  factory AppLocalizationsDataTemplatedDate.fromJson(
          Map<String, Object?> map) =>
      AppLocalizationsDataTemplatedDate(
        pattern: map['pattern']! as String,
        simple: map['simple']! as String,
      );
  Map<String, Object?> toJson() => {
        'pattern': _pattern,
        'simple': _simple,
      };

  AppLocalizationsDataTemplatedDate copyWith({
    String? pattern,
    String? simple,
  }) =>
      AppLocalizationsDataTemplatedDate(
        pattern: pattern ?? _pattern,
        simple: simple ?? _simple,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppLocalizationsDataTemplatedDate &&
          _pattern == other._pattern &&
          _simple == other._simple);
  @override
  int get hashCode =>
      runtimeType.hashCode ^ _pattern.hashCode ^ _simple.hashCode;
}

class AppLocalizationsDataTemplatedNumbers {
  const AppLocalizationsDataTemplatedNumbers({
    required String formatted,
    required String simple,
    required String count,
  })  : _formatted = formatted,
        _simple = simple,
        _count = count;

  final String _formatted;
  final String _simple;
  final String _count;

  String formatted({
    required double price,
    String? locale,
  }) {
    var label = _formatted;
    label = label.insertTemplateValues(
      {
        'price': price,
      },
      locale: locale,
    );
    return label;
  }

  String simple({
    required double price,
    String? locale,
  }) {
    var label = _simple;
    label = label.insertTemplateValues(
      {
        'price': price,
      },
      locale: locale,
    );
    return label;
  }

  String count({
    required int count,
    String? locale,
  }) {
    var label = _count;
    label = label.insertTemplateValues(
      {
        'count': count,
      },
      locale: locale,
    );
    return label;
  }

  factory AppLocalizationsDataTemplatedNumbers.fromJson(
          Map<String, Object?> map) =>
      AppLocalizationsDataTemplatedNumbers(
        formatted: map['formatted']! as String,
        simple: map['simple']! as String,
        count: map['count']! as String,
      );
  Map<String, Object?> toJson() => {
        'formatted': _formatted,
        'simple': _simple,
        'count': _count,
      };

  AppLocalizationsDataTemplatedNumbers copyWith({
    String? formatted,
    String? simple,
    String? count,
  }) =>
      AppLocalizationsDataTemplatedNumbers(
        formatted: formatted ?? _formatted,
        simple: simple ?? _simple,
        count: count ?? _count,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppLocalizationsDataTemplatedNumbers &&
          _formatted == other._formatted &&
          _simple == other._simple &&
          _count == other._count);
  @override
  int get hashCode =>
      runtimeType.hashCode ^
      _formatted.hashCode ^
      _simple.hashCode ^
      _count.hashCode;
}

class AppLocalizationsDataDates {
  const AppLocalizationsDataDates({
    required this.month,
    required this.weekday,
  });

  final AppLocalizationsDataDatesMonth month;
  final AppLocalizationsDataDatesWeekday weekday;
  factory AppLocalizationsDataDates.fromJson(Map<String, Object?> map) =>
      AppLocalizationsDataDates(
        month: AppLocalizationsDataDatesMonth.fromJson(
            map['month']! as Map<String, Object?>),
        weekday: AppLocalizationsDataDatesWeekday.fromJson(
            map['weekday']! as Map<String, Object?>),
      );
  Map<String, Object?> toJson() => {
        'month': month.toJson(),
        'weekday': weekday.toJson(),
      };

  AppLocalizationsDataDates copyWith({
    AppLocalizationsDataDatesMonth? month,
    AppLocalizationsDataDatesWeekday? weekday,
  }) =>
      AppLocalizationsDataDates(
        month: month ?? this.month,
        weekday: weekday ?? this.weekday,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppLocalizationsDataDates &&
          month == other.month &&
          weekday == other.weekday);
  @override
  int get hashCode => runtimeType.hashCode ^ month.hashCode ^ weekday.hashCode;
}

class AppLocalizationsDataDatesMonth {
  const AppLocalizationsDataDatesMonth({
    required this.april,
    required this.march,
    required this.february,
    required this.january,
  });

  final String april;
  final String march;
  final String february;
  final String january;
  factory AppLocalizationsDataDatesMonth.fromJson(Map<String, Object?> map) =>
      AppLocalizationsDataDatesMonth(
        april: map['april']! as String,
        march: map['march']! as String,
        february: map['february']! as String,
        january: map['january']! as String,
      );
  Map<String, Object?> toJson() => {
        'april': april,
        'march': march,
        'february': february,
        'january': january,
      };

  AppLocalizationsDataDatesMonth copyWith({
    String? april,
    String? march,
    String? february,
    String? january,
  }) =>
      AppLocalizationsDataDatesMonth(
        april: april ?? this.april,
        march: march ?? this.march,
        february: february ?? this.february,
        january: january ?? this.january,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppLocalizationsDataDatesMonth &&
          april == other.april &&
          march == other.march &&
          february == other.february &&
          january == other.january);
  @override
  int get hashCode =>
      runtimeType.hashCode ^
      april.hashCode ^
      march.hashCode ^
      february.hashCode ^
      january.hashCode;
}

class AppLocalizationsDataDatesWeekday {
  const AppLocalizationsDataDatesWeekday({
    required this.sunday,
    required this.saturday,
    required this.friday,
    required this.thursday,
    required this.wednesday,
    required this.tuesday,
    required this.monday,
  });

  final String sunday;
  final String saturday;
  final String friday;
  final String thursday;
  final String wednesday;
  final String tuesday;
  final String monday;
  factory AppLocalizationsDataDatesWeekday.fromJson(Map<String, Object?> map) =>
      AppLocalizationsDataDatesWeekday(
        sunday: map['sunday']! as String,
        saturday: map['saturday']! as String,
        friday: map['friday']! as String,
        thursday: map['thursday']! as String,
        wednesday: map['wednesday']! as String,
        tuesday: map['tuesday']! as String,
        monday: map['monday']! as String,
      );
  Map<String, Object?> toJson() => {
        'sunday': sunday,
        'saturday': saturday,
        'friday': friday,
        'thursday': thursday,
        'wednesday': wednesday,
        'tuesday': tuesday,
        'monday': monday,
      };

  AppLocalizationsDataDatesWeekday copyWith({
    String? sunday,
    String? saturday,
    String? friday,
    String? thursday,
    String? wednesday,
    String? tuesday,
    String? monday,
  }) =>
      AppLocalizationsDataDatesWeekday(
        sunday: sunday ?? this.sunday,
        saturday: saturday ?? this.saturday,
        friday: friday ?? this.friday,
        thursday: thursday ?? this.thursday,
        wednesday: wednesday ?? this.wednesday,
        tuesday: tuesday ?? this.tuesday,
        monday: monday ?? this.monday,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppLocalizationsDataDatesWeekday &&
          sunday == other.sunday &&
          saturday == other.saturday &&
          friday == other.friday &&
          thursday == other.thursday &&
          wednesday == other.wednesday &&
          tuesday == other.tuesday &&
          monday == other.monday);
  @override
  int get hashCode =>
      runtimeType.hashCode ^
      sunday.hashCode ^
      saturday.hashCode ^
      friday.hashCode ^
      thursday.hashCode ^
      wednesday.hashCode ^
      tuesday.hashCode ^
      monday.hashCode;
}
