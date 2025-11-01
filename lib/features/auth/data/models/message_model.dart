class MessageModel {
  final String message;

  MessageModel({required this.message});

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        message: json['message']?.toString() ?? '',
      );
}
