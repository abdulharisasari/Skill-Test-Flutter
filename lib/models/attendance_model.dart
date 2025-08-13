class AttendanceModel {
  final String email;
  final String date;
  final String time;
  final String location;
  final String coordinates;
  final String? selfiePath;

  AttendanceModel({
    required this.email,
    required this.date,
    required this.time,
    required this.location,
    required this.coordinates,
    this.selfiePath,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'date': date,
        'time': time,
        'location': location,
        'coordinates': coordinates,
        'selfiePath': selfiePath,
      };

  factory AttendanceModel.fromJson(Map<String, dynamic> json) => AttendanceModel(
        email: json['email'],
        date: json['date'],
        time: json['time'],
        location: json['location'],
        coordinates: json['coordinates'],
        selfiePath: json['selfiePath'],
      );
}
