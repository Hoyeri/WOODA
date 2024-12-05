import 'package:flutter/material.dart';

class CommentPage extends StatefulWidget {
  final List<Map<String, dynamic>> initialComments; // 초기 댓글 리스트
  final Function(List<Map<String, dynamic>>) onCommentsUpdated; // 업데이트된 댓글 반환

  const CommentPage({
    super.key,
    required this.initialComments,
    required this.onCommentsUpdated,
  });

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  late List<Map<String, dynamic>> comments; // 댓글 리스트
  final TextEditingController _controller = TextEditingController();
  final Map<String, bool> isRepliesVisible = {}; // 댓글 ID별 답글 가시성

  @override
  void initState() {
    super.initState();
    comments = List.from(widget.initialComments);
  }

  void addComment(String content, [String? parentId]) {
    setState(() {
      final newComment = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'author': '사용자${comments.length + 1}', // 임의 사용자 이름
        'content': content,
        'parentId': parentId, // 부모 댓글 ID (답글인 경우)
      };
      comments.add(newComment);

      if (parentId != null) {
        isRepliesVisible[parentId] = true;
      }
    });
    widget.onCommentsUpdated(comments); // 업데이트된 댓글 리스트 반환
  }

  void _showReplyDialog(String parentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("답글 달기"),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: "답글 내용을 입력하세요"),
          ),
          actions: [
            TextButton(
              child: const Text("취소"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text("추가"),
              onPressed: () {
                addComment(_controller.text, parentId);
                _controller.clear();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const Text(
                "댓글",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: comments.isEmpty
                    ? const Center(
                  child: Text(
                    "아직 작성된 댓글이 없어요.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
                  : ListView.builder(
                    controller: scrollController,
                    itemCount: comments.where((c) => c['parentId'] == null).length,
                    itemBuilder: (context, index) {
                      final comment = comments
                          .where((c) => c['parentId'] == null)
                          .toList()[index];
                      final replies = comments
                          .where((c) => c['parentId'] == comment['id'])
                          .toList();
                      final isVisible = isRepliesVisible[comment['id']] ?? false;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: const CircleAvatar(
                              backgroundImage: AssetImage('assets/images/profile_default.png'),
                            ),
                            title: Text(comment['author'] ?? "익명"),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(comment['content'] ?? ""),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => _showReplyDialog(comment['id']),
                                      child: const Text(
                                        "답글 달기",
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    if (replies.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0), // "답글 달기"와 "답글 보기" 사이 간격
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              isRepliesVisible[comment['id']] = !isVisible;
                                            });
                                          },
                                          child: Text(
                                            isVisible ? "답글 닫기" : "답글 보기",
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (isVisible)
                            Padding(
                              padding: const EdgeInsets.only(left: 40),
                              child: Column(
                                children: replies.map((reply) {
                                  return ListTile(
                                    leading: const CircleAvatar(
                                      backgroundImage: AssetImage(
                                          'assets/images/profile_default.png'),
                                    ),
                                    title: Text(reply['author'] ?? "익명"),
                                    subtitle: Text(reply['content'] ?? ""),
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            hintText: "댓글 입력...",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.blue),
                        onPressed: () {
                          addComment(_controller.text);
                          _controller.clear();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }
