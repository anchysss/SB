import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CommentCard extends StatelessWidget {
  final Map<String, dynamic> comment;
  final String userId;
  final bool isEditing;
  final bool isReplying;
  final TextEditingController editController;
  final TextEditingController replyController;
  final VoidCallback onLike;
  final VoidCallback onEdit;
  final VoidCallback onSubmitEdit;
  final VoidCallback onReply;
  final VoidCallback onSendReply;

  const CommentCard({
    Key? key,
    required this.comment,
    required this.userId,
    required this.isEditing,
    required this.isReplying,
    required this.editController,
    required this.replyController,
    required this.onLike,
    required this.onEdit,
    required this.onSubmitEdit,
    required this.onReply,
    required this.onSendReply,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isOwner = comment['user_id'] == userId;
    final replies = comment['replies'] ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(comment['user_id'] ?? 'Anonymous',
              style: const TextStyle(fontWeight: FontWeight.bold)),

          const SizedBox(height: 4),

          if (isEditing)
            TextField(
              controller: editController..text = comment['comment_text'],
              decoration: InputDecoration(
                hintText: 'Edit comment...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: onSubmitEdit,
                ),
              ),
            )
          else
            Text(comment['comment_text'] ?? ''),

          const SizedBox(height: 4),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('yyyy-MM-dd HH:mm').format(
                  DateTime.parse(comment['timestamp'] ?? DateTime.now().toIso8601String()),
                ),
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.favorite_border, color: Colors.pink),
                    onPressed: onLike,
                  ),
                  Text('${comment['likes'] ?? 0}'),

                  if (isOwner)
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.brown),
                      onPressed: onEdit,
                    ),

                  IconButton(
                    icon: const Icon(Icons.reply, color: Colors.brown),
                    onPressed: onReply,
                  ),
                ],
              ),
            ],
          ),

          if (isReplying)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextField(
                controller: replyController,
                decoration: InputDecoration(
                  hintText: 'Reply...',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: onSendReply,
                  ),
                ),
              ),
            ),

          for (var reply in replies)
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 8),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.pink.shade100.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reply['user_id'] ?? 'Anonymous',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(reply['comment_text'] ?? ''),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('yyyy-MM-dd HH:mm').format(
                        DateTime.parse(reply['timestamp'] ?? DateTime.now().toIso8601String()),
                      ),
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
