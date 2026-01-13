import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CountryData {
  final int id;
  final String iso2;
  final String name;
  final String nativeName;
  final Map<String, String> translations;
  final String flagEmoji;

  CountryData({
    required this.id,
    required this.iso2,
    required this.name,
    required this.nativeName,
    required this.translations,
    required this.flagEmoji,
  });

  factory CountryData.fromJson(Map<String, dynamic> json) {
    return CountryData(
      id: json['id'],
      iso2: json['iso2'],
      name: json['name'],
      nativeName: json['nativeName'],
      translations: Map<String, String>.from(json['translations']),
      flagEmoji: json['flagEmoji'],
    );
  }
}

class StaticDataRepository {
  Future<List<CountryData>> loadCountries() async {
    final String response = await rootBundle.loadString(
      'assets/data/countries.json',
    );
    final List<dynamic> data = json.decode(response);
    return data.map((json) => CountryData.fromJson(json)).toList();
  }
}

final staticDataRepositoryProvider = Provider<StaticDataRepository>((ref) {
  return StaticDataRepository();
});

final countriesProvider = FutureProvider<List<CountryData>>((ref) async {
  final repo = ref.watch(staticDataRepositoryProvider);
  return await repo.loadCountries();
});
