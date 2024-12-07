import 'package:flutter/material.dart';
import 'package:wooda_client/src/services/items_service.dart';

class CommentPage extends StatefulWidget {
  final int itemId; // 아이템 ID
  final ItemsService itemsService; // 댓글 관련 서비스

  const CommentPage({
    super.key,
    required this.itemId,
    required this.itemsService,
  });

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final TextEditingController _controller = TextEditingController();
  final Map<String, bool> isRepliesVisible = {}; // 댓글 ID별 답글 가시성
  List<Map<String, dynamic>> _comments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchComments(); // 초기 댓글 로드
  }

  Future<void> _fetchComments() async {
    try {
      final comments = await widget.itemsService.getComments(widget.itemId);
      setState(() {
        // 반환된 comments를 Map<String, dynamic> 형식으로 변환
        _comments = comments.map((comment) => comment as Map<String, dynamic>).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("댓글 불러오기 실패: $e")),
      );
    }
  }

  Future<void> _addComment(String content, [String? parentId]) async {
    if (content.trim().isEmpty) return;

    try {
      await widget.itemsService.addComment(widget.itemId, content);
      _controller.clear();
      await _fetchComments(); // 댓글 추가 후 목록 갱신
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("댓글 추가 실패: $e")),
      );
    }
  }

  Future<void> _deleteComment(int commentId) async {
    try {
      await widget.itemsService.deleteComment(commentId);
      await _fetchComments(); // 댓글 삭제 후 목록 갱신
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("댓글 삭제 실패: $e")),
      );
    }
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
              onPressed: () async {
                await _addComment(_controller.text, parentId);
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
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _comments.isEmpty
                    ? const Center(
                  child: Text(
                    "아직 작성된 댓글이 없어요.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
                    : ListView.builder(
                  controller: scrollController,
                  itemCount:
                  _comments.where((c) => c['parentId'] == null).length,
                  itemBuilder: (context, index) {
                    final comment = _comments
                        .where((c) => c['parentId'] == null)
                        .toList()[index];
                    final replies = _comments
                        .where((c) => c['parentId'] == comment['id'])
                        .toList();
                    final isVisible =
                        isRepliesVisible[comment['id']] ?? false;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: const CircleAvatar(
                            backgroundImage: AssetImage(
                                'assets/images/profile_default.png'),
                          ),
                          title: Text(comment['author'] ?? "익명"),
                          subtitle: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(comment['content'] ?? ""),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () =>
                                        _showReplyDialog(comment['id']),
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
                                      padding: const EdgeInsets.only(
                                          left: 8.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            isRepliesVisible[
                                            comment['id']] =
                                            !isVisible;
                                          });
                                        },
                                        child: Text(
                                          isVisible
                                              ? "답글 닫기"
                                              : "답글 보기",
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
                            padding:
                            const EdgeInsets.only(left: 40),
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
                      onPressed: () => _addComment(_controller.text),
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
