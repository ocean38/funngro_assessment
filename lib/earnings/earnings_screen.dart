import 'dart:async';

import 'package:flutter/material.dart';

import 'detail_screen.dart';
import 'earning.dart';
import 'earnings_api.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({
    super.key,
    required this.userId,
    required this.api,
  });

  final String userId;
  final EarningsApi api;

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  final List<Earning> _earnings = [];

  bool _loading = true;
  String? _error;
  bool _openingDetail = false;

  StreamSubscription<Earning>? _walletSub;

  @override
  void initState() {
    super.initState();
    _load();
    _walletSub = widget.api.walletUpdates(widget.userId).listen(
      _onWalletUpdate,
      onError: (_) {},
    );
  }

  @override
  void dispose() {
    _walletSub?.cancel();
    _walletSub = null;
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await widget.api.fetchEarnings(widget.userId);
      if (!mounted) return;
      setState(() {
        _earnings
          ..clear()
          ..addAll(data);
        _loading = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load earnings.';
      });
    }
  }

  void _onWalletUpdate(Earning update) {
    if (!mounted || _loading || _error != null) return;
    setState(() => _earnings.insert(0, update));
  }

  Future<void> _openDetail(Earning earning) async {
    if (_openingDetail) return;
    _openingDetail = true;
    try {
      final detail = await widget.api.fetchDetail(earning.id);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => DetailScreen(detail: detail),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Could not open details.')),
        );
    } finally {
      _openingDetail = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Earnings')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading && _earnings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _earnings.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.3),
          Center(child: Text(_error!)),
          const SizedBox(height: 12),
          Center(
            child: ElevatedButton(
              onPressed: _load,
              child: const Text('Retry'),
            ),
          ),
        ],
      );
    }

    if (_earnings.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.3),
          const Center(child: Text('No earnings yet.')),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _earnings.length,
      itemBuilder: (context, index) {
        final e = _earnings[index];
        return ListTile(
          key: ValueKey(e.id),
          title: Text('Earning #${e.id}'),
          subtitle: Text(e.formattedAmount),
          onTap: () => _openDetail(e),
        );
      },
    );
  }
}
