import 'dart:async';
import 'dart:collection';

class MetadataPipelineStageQueue<T> {
  MetadataPipelineStageQueue({required this.watermark});

  final int watermark;
  final ListQueue<T> _items = ListQueue<T>();
  final ListQueue<_DeferredStageEntry<T>> _deferred =
      ListQueue<_DeferredStageEntry<T>>();
  Completer<void>? _itemWaiter;
  Completer<void>? _spaceWaiter;

  bool get isEmpty => _items.isEmpty;
  bool get isFull => occupancy >= watermark;
  int get length => _items.length;
  int get occupancy => _items.length + _deferred.length;

  bool enqueue(T item, {void Function()? onAdmitted}) {
    if (_items.length < watermark && _deferred.isEmpty) {
      _pushReady(item);
      return true;
    }
    _deferred.addLast(
      _DeferredStageEntry<T>(item: item, onAdmitted: onAdmitted),
    );
    return false;
  }

  Future<T?> take({
    required bool Function() shouldStop,
    Duration? timeout,
  }) async {
    while (_items.isEmpty) {
      if (shouldStop()) {
        return null;
      }
      final waiter = _itemWaiter ??= Completer<void>();
      if (timeout == null) {
        await waiter.future;
      } else {
        try {
          await waiter.future.timeout(timeout);
        } on TimeoutException {
          return null;
        }
      }
    }
    final item = _items.removeFirst();
    _promoteDeferred();
    _spaceWaiter?.complete();
    _spaceWaiter = null;
    return item;
  }

  Future<void> waitForSpace() async {
    if (!isFull) {
      return;
    }
    final waiter = _spaceWaiter ??= Completer<void>();
    await waiter.future;
  }

  void notifyAll() {
    _itemWaiter?.complete();
    _itemWaiter = null;
    _spaceWaiter?.complete();
    _spaceWaiter = null;
  }

  void _pushReady(T item) {
    _items.addLast(item);
    _itemWaiter?.complete();
    _itemWaiter = null;
  }

  void _promoteDeferred() {
    while (_items.length < watermark && _deferred.isNotEmpty) {
      final deferred = _deferred.removeFirst();
      deferred.onAdmitted?.call();
      _pushReady(deferred.item);
    }
  }
}

class _DeferredStageEntry<T> {
  const _DeferredStageEntry({required this.item, this.onAdmitted});

  final T item;
  final void Function()? onAdmitted;
}
