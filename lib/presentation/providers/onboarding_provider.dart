import 'package:flutter/material.dart';

class OnboardingProvider extends ChangeNotifier {
  int _currentPage = 0;
  int get currentPage => _currentPage;

  final PageController pageController = PageController();

  void setPage(int index) {
    _currentPage = index;
    notifyListeners();
  }

  void nextPage(VoidCallback onComplete) {
    if (_currentPage < 1) {
      _currentPage++;
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      notifyListeners();
    } else {
      onComplete();
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
