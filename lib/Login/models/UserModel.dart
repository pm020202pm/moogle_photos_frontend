
class UserModel{
  int id;
  String name;
  String email;
  List<String> accounts = [];
  String photoUrl;
  String sharedFolderId;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.photoUrl,
    this.sharedFolderId = '',
    this.accounts= const ['','','',''],
  });


  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['user_id']??-1,
      name: json['name']??'',
      email: json['email']??'',
      photoUrl: json['photo_url']??'',
      sharedFolderId: json['shared_folder_id']??'',
      accounts: [json['account1']??'', json['account2']??'', json['account3']??'', json['account4']??''],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': id,
      'name': name,
      'email': email,
      'photo_url': photoUrl,
      'shared_folder_id': sharedFolderId,
      'accounts': accounts,
    };
  }
}
