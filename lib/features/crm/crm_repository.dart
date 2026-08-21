import '../../models/models.dart';

abstract interface class CrmRepository {
  Future<List<CrmDeal>> fetchDeals();
  Future<void> updateDealStage(String dealId, DealStage stage);
}

class MockCrmRepository implements CrmRepository {
  final List<CrmDeal> _deals = [
    CrmDeal(
      id: 'cd1',
      title: 'Vortex.io Enterprise License & MCP Swarm',
      companyName: 'Vortex Systems',
      value: 120000.0,
      stage: DealStage.proposal,
      contactName: 'Sarah Jenkins',
      contactEmail: 'sarah@vortex.io',
      lastInteraction: '2 hours ago',
      tags: ['Enterprise', 'Q3 Pipeline'],
    ),
    CrmDeal(
      id: 'cd2',
      title: 'Acme Global Workspace Expansion',
      companyName: 'Acme Corp',
      value: 85000.0,
      stage: DealStage.negotiation,
      contactName: 'Mark Sterling',
      contactEmail: 'm.sterling@acme.com',
      lastInteraction: 'Yesterday',
      tags: ['Expansion'],
    ),
  ];

  @override
  Future<List<CrmDeal>> fetchDeals() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _deals;
  }

  @override
  Future<void> updateDealStage(String dealId, DealStage stage) async {
    final idx = _deals.indexWhere((d) => d.id == dealId);
    if (idx != -1) {
      _deals[idx].stage = stage;
    }
  }
}

class MacroCrmRepository implements CrmRepository {
  @override
  Future<List<CrmDeal>> fetchDeals() async {
    throw UnimplementedError('Macro API CRM endpoints not yet configured.');
  }

  @override
  Future<void> updateDealStage(String dealId, DealStage stage) async {
    throw UnimplementedError('Macro API CRM endpoints not yet configured.');
  }
}
