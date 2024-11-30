import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wooda_client/src/models/detail_page_model.dart';

class DetailPage extends StatelessWidget {
  final DetailPageModel model; // 모델로 받기
  final Map<String, dynamic> schedule;
  final void Function(Map<String, dynamic>) onUpdate; // 수정 시 호출
  final void Function() onDelete; // 삭제 시 호출

  const DetailPage({
    Key? key,
    required this.model,
    required this.onDelete,
    required this.onUpdate,
    required this.schedule,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat('yyyy년 MM월 dd일, EEEE', 'ko_KR').format(model.date);

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
          ),
          iconSize: 23,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              color: Colors.black,

            ),
            iconSize: 25,
            onSelected: (String value) {
              if (value == 'edit') {
                onUpdate(schedule); // 수정 기능 호출
              } else if (value == 'delete') {
                onDelete(); // 삭제 기능 호출
                Navigator.pop(context); // 삭제 후 이전 화면으로 이동
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text('수정'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('삭제'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // 날짜 영역
          Container(
            width: double.infinity,
            color: Colors.white, // 날짜 배경 흰색 고정
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              formattedDate,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                // 배경 이미지
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/background_01.png', // 배경 이미지 경로
                    fit: BoxFit.fill, // 화면 크기에 맞춤
                  ),
                ),
                // 내용
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
                      children: [
                        // 제목
                        Text(
                          model.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black, // 제목 검은색
                          ),
                        ),
                        const SizedBox(height: 12),
                        // 내용
                        Text(
                          model.description,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey, // 내용 회색
                            height: 1.5, // 줄 간격
                          ),
                        ),
                        const SizedBox(height: 24),
                        // 사진 표시
                        if (model.image != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              model.image!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 400,
                            ),
                          )
                        else
                          Container(
                            height: 400, // 사진 높이와 동일
                            width: double.infinity,
                            color: Colors.transparent, // 투명 배경
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}