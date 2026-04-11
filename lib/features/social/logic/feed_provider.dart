import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/feed_repository.dart';

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepository();
});

final feedProvider = StreamProvider.autoDispose<List<FeedItem>>((ref) {
  final repo = ref.watch(feedRepositoryProvider);
  return repo.getFeed();
});
