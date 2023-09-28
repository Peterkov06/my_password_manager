import 'package:hive/hive.dart';

part 'ServiceCard.g.dart';

@HiveType(typeId: 0)
class ServiceCard 
{
  @HiveField(0)
  final String serviceName;

  @HiveField(1)
  final String userName;

  @HiveField(2)
  final String currentPassword;

  @HiveField(3)
  List<String> previousPass = [];

  ServiceCard({required this.serviceName, required this.userName, required this.currentPassword});
}