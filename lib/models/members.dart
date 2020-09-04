class Members {
  final String memberid;
  final String membername;
  final String role;

  Members({this.memberid, this.membername, this.role});
  Map<String, dynamic> toJson() =>
      {
        'memberid': memberid,
        'membername': membername,
        'role': role,
      };

  Members.fromJson(Map<String, dynamic> json)
      : memberid = json['memberid'],
        membername = json['membername'],
        role = json['role'];
}