import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/cagnotte_repository.dart';
import '../domain/cagnotte_models.dart';

final residenceFundTransactionsProvider = FutureProvider.autoDispose
    .family<List<ResidenceFundTransaction>, int>((ref, residenceId) {
      return ref
          .read(cagnotteRepositoryProvider)
          .fetchTransactions(residenceId);
    });
