import 'nexabiz_membership_authorization_snapshot.dart';

/// Pure domain query store interface for reading atomic authorization snapshots.
abstract interface class CoreAuthorizationQueryStore {
  /// Reads the atomic authorization snapshot for the given [membershipId].
  ///
  /// Returns null if the membership does not exist.
  Future<NexaBizMembershipAuthorizationSnapshot?>
  readMembershipAuthorizationSnapshot(String membershipId);
}
