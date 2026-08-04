import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/remote_repository.dart';
import 'remote_model.dart';

final remoteRepositoryProvider = Provider<RemoteRepository>((ref) {
  return RemoteRepository();
});

final remotesProvider =
    StateNotifierProvider<RemotesNotifier, List<RemoteModel>>((ref) {
  final repo = ref.watch(remoteRepositoryProvider);
  return RemotesNotifier(repo);
});

class RemotesNotifier extends StateNotifier<List<RemoteModel>> {
  final RemoteRepository _repo;

  RemotesNotifier(this._repo) : super([]) {
    loadRemotes();
  }

  /// Loads all remotes from Hive and updates state.
  void loadRemotes() {
    state = _repo.getAllRemotes();
  }

  /// Adds a new remote and updates state.
  Future<void> addRemote(RemoteModel remote) async {
    await _repo.saveRemote(remote);
    state = _repo.getAllRemotes();
  }

  /// Deletes a remote by id and updates state.
  Future<void> deleteRemote(String id) async {
    await _repo.deleteRemote(id);
    state = _repo.getAllRemotes();
  }

  /// Updates an existing remote (same id) and refreshes state.
  Future<void> updateRemote(RemoteModel remote) async {
    await _repo.saveRemote(remote);
    state = _repo.getAllRemotes();
  }
}
