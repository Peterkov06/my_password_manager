class ServiceCard 
{
  final String serviceName;
  final String userName;
  final String currentPassword;
  List<String> previousPass = [];

  ServiceCard({required this.serviceName, required this.userName, required this.currentPassword});
}