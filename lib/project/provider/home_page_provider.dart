import 'package:flutter/cupertino.dart';
import 'package:magic_english_project/project/database/database.dart';
import 'package:magic_english_project/project/dto/category_english.dart';
import 'package:magic_english_project/project/dto/overview_model.dart';

class HomePageProvider extends ChangeNotifier {
  final Database _db = Database();

  CategoryEnglish? categoryEnglish;

  OverviewModel? _overviewData;
  OverviewModel? get overviewData => _overviewData;

  bool isLoading = false;

  Future<void> initData() async {
    isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _db.getUserCategoryEnglish(),
        _db.getOverviewData(),
      ]);

      categoryEnglish = results[0] as CategoryEnglish;
      _overviewData = results[1] as OverviewModel;
    } catch (e) {
      debugPrint("Lỗi Provider (initData): $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void increaseAdj() {
    if (categoryEnglish != null) {
      categoryEnglish!.adj = (categoryEnglish!.adj ?? 0) + 1;
      categoryEnglish!.totalVocab = (categoryEnglish!.totalVocab ?? 0) + 1;
      notifyListeners();
    }
  }

  void increaseNoun() {
    if (categoryEnglish != null) {
      categoryEnglish!.noun = (categoryEnglish!.noun ?? 0) + 1;
      categoryEnglish!.totalVocab = (categoryEnglish!.totalVocab ?? 0) + 1;
      notifyListeners();
    }
  }

  void increaseAdv() {
    if (categoryEnglish != null) {
      categoryEnglish!.adv = (categoryEnglish!.adv ?? 0) + 1;
      categoryEnglish!.totalVocab = (categoryEnglish!.totalVocab ?? 0) + 1;
      notifyListeners();
    }
  }

  void increaseVerb() {
    if (categoryEnglish != null) {
      categoryEnglish!.verb = (categoryEnglish!.verb ?? 0) + 1;
      categoryEnglish!.totalVocab = (categoryEnglish!.totalVocab ?? 0) + 1;
      notifyListeners();
    }
  }

  void increaseLevel(String level) {
    if (categoryEnglish == null) return;
    switch (level) {
      case 'A1': categoryEnglish!.A1 = (categoryEnglish!.A1 ?? 0) + 1; break;
      case 'A2': categoryEnglish!.A2 = (categoryEnglish!.A2 ?? 0) + 1; break;
      case 'B1': categoryEnglish!.B1 = (categoryEnglish!.B1 ?? 0) + 1; break;
      case 'B2': categoryEnglish!.B2 = (categoryEnglish!.B2 ?? 0) + 1; break;
      case 'C1': categoryEnglish!.C1 = (categoryEnglish!.C1 ?? 0) + 1; break;
      case 'C2': categoryEnglish!.C2 = (categoryEnglish!.C2 ?? 0) + 1; break;
    }
    notifyListeners();
  }
}