import 'package:hive/hive.dart';
import '../domain/remote_model.dart';

class RemoteRepository {
  static const String _boxName = 'remotes';

  Box<RemoteModel> get _box => Hive.box<RemoteModel>(_boxName);

  /// Saves or updates a RemoteModel (uses id as key).
  Future<void> saveRemote(RemoteModel remote) async {
    await _box.put(remote.id, remote);
  }

  /// Returns all saved remotes.
  List<RemoteModel> getAllRemotes() {
    return _box.values.toList();
  }

  /// Deletes a remote by id.
  Future<void> deleteRemote(String id) async {
    await _box.delete(id);
  }

  /// Returns a remote by id, or null if not found.
  RemoteModel? getRemote(String id) {
    return _box.get(id);
  }
}
