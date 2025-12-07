import 'package:flutter/material.dart';
import 'package:test_project/project/base/basescreen.dart';
import 'package:test_project/project/pointanderror/historypoint.dart';
import 'package:test_project/project/notebooks/notebooks_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      appBar: AppBar(
        title: const Text('Bảng điều khiển tiến độ'),
        centerTitle: false,
        elevation: 0,
      ),
      needBottom: true,
      activeIndex: 0,
      bottomActions: [
        () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage())),
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotebooksPage())),
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryPoint())),
        () {},
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text('Bảng điều khiển tiến độ', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Số từ vựng đã học', style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 8),
                        Text('200', style: Theme.of(context).textTheme.headlineLarge),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              CircleAvatar(radius: 32, backgroundColor: Theme.of(context).primaryColor, child: Text('200', style: Theme.of(context).textTheme.labelLarge)),
            ],
          ),

          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.pie_chart),
                      const SizedBox(width: 8),
                      Text('Phân loại theo từ loại', style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Placeholder for donut chart
                  SizedBox(
                    height: 120,
                    child: Center(child: Text('Donut chart placeholder')),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(children: [const Icon(Icons.bar_chart), const SizedBox(width: 8), Text('Phân loại theo cấp độ', style: Theme.of(context).textTheme.bodyLarge)]),
                  const SizedBox(height: 12),
                  SizedBox(height: 120, child: Center(child: Text('Bar chart placeholder'))),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}
