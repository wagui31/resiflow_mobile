import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_session_controller.dart';
import '../../depense/application/depense_providers.dart';
import '../data/vote_repository.dart';
import '../domain/vote_models.dart';

final voteOverviewControllerProvider =
    AsyncNotifierProvider<VoteOverviewController, List<VoteOverview>>(
      VoteOverviewController.new,
    );

final voteDetailsProvider = FutureProvider.family<VoteDetails, int>((
  ref,
  voteId,
) {
  return ref.read(voteRepositoryProvider).fetchVoteDetails(voteId);
});

class VoteOverviewController extends AsyncNotifier<List<VoteOverview>> {
  @override
  Future<List<VoteOverview>> build() async {
    ref.watch(currentUserProvider);
    return _fetch();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> createVote(CreateVotePayload payload) async {
    final repository = ref.read(voteRepositoryProvider);
    await repository.createVote(payload);
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> submitVote({
    required int voteId,
    required VoteChoice choice,
    String? comment,
  }) async {
    final repository = ref.read(voteRepositoryProvider);
    await repository.submitVote(
      voteId: voteId,
      choice: choice,
      comment: comment,
    );
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> closeVote(int voteId) async {
    final repository = ref.read(voteRepositoryProvider);
    await repository.closeVote(voteId);
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> createExpenseFromVote(int voteId) async {
    final repository = ref.read(voteRepositoryProvider);
    await repository.createExpenseFromVote(voteId);
    state = await AsyncValue.guard(_fetch);
    ref.invalidate(expenseOverviewProvider);
    ref.invalidate(adminPendingExpensesProvider);
    ref.invalidate(adminPendingSharedExpensePaymentsProvider);
  }

  Future<List<VoteOverview>> _fetch() async {
    final user = ref.read(currentUserProvider);
    final residenceId = user?.residenceId;
    if (residenceId == null) {
      throw const VoteDataException(
        'Authenticated residence context is missing.',
      );
    }
    return ref
        .read(voteRepositoryProvider)
        .fetchResidenceVoteOverviews(residenceId);
  }
}

class VoteDataException implements Exception {
  const VoteDataException(this.message);

  final String message;

  @override
  String toString() => message;
}
