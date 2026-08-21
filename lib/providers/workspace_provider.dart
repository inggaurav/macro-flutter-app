import 'package:flutter/foundation.dart';

enum WorkspaceTab {
  dashboard,
  inbox,
  chat,
  docs,
  tasks,
  crm,
  aiMemory,
  calls,
  settings,
  profile,
}

class WorkspaceProvider extends ChangeNotifier {
  WorkspaceTab _activeTab = WorkspaceTab.dashboard;
  bool _isCopilotDrawerOpen = false;
  String? _selectedDocId;

  // Getters
  WorkspaceTab get activeTab => _activeTab;
  bool get isCopilotDrawerOpen => _isCopilotDrawerOpen;
  bool get isCopilotOpen => _isCopilotDrawerOpen;
  String? get selectedDocId => _selectedDocId;

  void setTab(WorkspaceTab tab) {
    _activeTab = tab;
    notifyListeners();
  }

  void setActiveTab(String tabName) {
    final tab = WorkspaceTab.values.firstWhere(
      (t) => t.name == tabName,
      orElse: () => WorkspaceTab.dashboard,
    );
    setTab(tab);
  }

  void toggleCopilotDrawer() {
    _isCopilotDrawerOpen = !_isCopilotDrawerOpen;
    notifyListeners();
  }

  void selectDoc(String docId) {
    _selectedDocId = docId;
    notifyListeners();
  }
}
