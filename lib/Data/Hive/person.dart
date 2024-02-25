// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:hive/hive.dart';

part 'person.g.dart';

@HiveType(typeId: 1)
class Person {
  @HiveField(0)
  String name;

  @HiveField(1)
  String email;

  @HiveField(2)
  String profileUrl;
  Person({
    required this.name,
    required this.email,
    required this.profileUrl,
  });
}
