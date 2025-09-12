// Block types
enum BlockType {
  paragraph,
  heading1,
  heading2,
  heading3,
  quote,
  code,
  image,
  video,
  divider,
}

// Block data model
class EditorBlock {
  final String id;
  final BlockType type;
  String content;
  Map<String, dynamic> metadata;

  EditorBlock({
    required this.id,
    required this.type,
    this.content = '',
    Map<String, dynamic>? metadata,
  }) : metadata = metadata ?? {};

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'content': content,
    'metadata': metadata,
  };

  factory EditorBlock.fromJson(Map<String, dynamic> json) => EditorBlock(
    id: json['id'],
    type: BlockType.values.firstWhere((e) => e.name == json['type']),
    content: json['content'] ?? '',
    metadata: json['metadata'] ?? {},
  );
}
