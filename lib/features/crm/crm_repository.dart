import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/macro_service_config.dart';
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
  ];

  @override
  Future<List<CrmDeal>> fetchDeals() async {
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
  final MacroServiceConfig _config;
  final String? Function() _tokenProvider;

  MacroCrmRepository({
    MacroServiceConfig? config,
    required String? Function() tokenProvider,
  }) : _config = config ?? MacroServiceConfig.production(),
       _tokenProvider = tokenProvider;

  @override
  Future<List<CrmDeal>> fetchDeals() async {
    final token = _tokenProvider();
    if (token == null || token.isEmpty) return [];

    try {
      final response = await http
          .get(
            Uri.parse('${_config.contactsHost}/v1/deals'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((item) => CrmDeal.fromJson(item)).toList();
      }
    } catch (_) {}

    return [];
  }

  @override
  Future<void> updateDealStage(String dealId, DealStage stage) async {
    final token = _tokenProvider();
    if (token == null || token.isEmpty) return;

    try {
      await http
          .patch(
            Uri.parse('${_config.contactsHost}/v1/deals/$dealId'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'stage': stage.name}),
          )
          .timeout(const Duration(seconds: 3));
    } catch (_) {}
  }
}
