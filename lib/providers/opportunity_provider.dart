import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/opportunity.dart';
import '../repositories/opportunity_repo.dart';

final opportunityRepositoryProvider = Provider<OpportunityRepository>((ref) {
  return OpportunityRepository();
});

final activeOpportunitiesProvider = StreamProvider<List<Opportunity>>((ref) {
  final repository = ref.watch(opportunityRepositoryProvider);

  return repository.watchActiveOpportunities();
});

final startupOpportunitiesProvider =
    StreamProvider.family<List<Opportunity>, String>((ref, startupId) {
      final repository = ref.watch(opportunityRepositoryProvider);

      return repository.watchStartupOpportunities(startupId);
    });
