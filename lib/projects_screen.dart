import 'package:flutter/material.dart';

import 'api_data_model.dart';
import 'projects_api.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key, required this.api});
  final ProjectsDataSource api;

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final _items = <ApiDataModel>[];

  static const _pageSize = 20;
  int _nextPage = 0;
  int _generation = 0;
  bool _initialLoading = true;
  bool _loadingMore = false;
  bool _refreshing = false;
  bool _endReached = false;
  bool _initialError = false;
  bool _pageError = false;

  @override
  void initState() {
    super.initState();
    _loadFirst();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Projects')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_initialLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return RefreshIndicator(
      onRefresh: _loadFirst,
      child: _initialError
          ? _fullPage(
              'Could not load projects.',
              action: ElevatedButton(
                onPressed: _loadFirst,
                child: const Text('Retry'),
              ),
            )
          : _items.isEmpty
          ? _fullPage('No projects yet.')
          : _buildList(),
    );
  }

  Widget _fullPage(String text, {Widget? action}) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 200),
        Center(child: Text(text)),
        if (action != null) ...[
          const SizedBox(height: 12),
          Center(child: action),
        ],
      ],
    );
  }

  Widget _buildList() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _items.length + 1,
      itemBuilder: (context, i) {
        if (i < _items.length) {
          final p = _items[i];
          return ListTile(
            key: ValueKey(p.id),
            title: Text(p.title),
            subtitle: Text(p.company),
            trailing: Text('₹${p.payout}'),
          );
        }
        return _buildFooter();
      },
    );
  }

  Widget _buildFooter() {
    if (_pageError) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Could not load more.',
              style: TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _loadNext, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_endReached) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text(
            "You've reached the end",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    if (_refreshing) {
      return const SizedBox(height: 16);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadNext();
    });
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> _loadFirst() async {
    final gen = ++_generation;
    setState(() {
      _loadingMore = false;
      _pageError = false;
      if (_items.isEmpty) {
        _initialLoading = true;
        _initialError = false;
        _refreshing = false;
      } else {
        _refreshing = true;
      }
    });
    try {
      final data = await widget.api.fetchProjects(0);
      if (!mounted || gen != _generation) return;
      setState(() {
        _items
          ..clear()
          ..addAll(data);
        _nextPage = 1;
        _endReached = data.length < _pageSize;
        _initialLoading = false;
        _initialError = false;
        _refreshing = false;
        _loadingMore = false;
        _pageError = false;
      });
    } catch (_) {
      if (!mounted || gen != _generation) return;
      final hadItems = _items.isNotEmpty;
      setState(() {
        _initialLoading = false;
        _initialError = !hadItems;
        _refreshing = false;
      });
      if (hadItems) _toast('Refresh failed. Showing previous data.');
    }
  }

  Future<void> _loadNext() async {
    if (_loadingMore ||
        _refreshing ||
        _endReached ||
        _initialLoading ||
        _initialError) {
      return;
    }
    final gen = _generation;
    final page = _nextPage;
    setState(() {
      _loadingMore = true;
      _pageError = false;
    });
    try {
      final data = await widget.api.fetchProjects(page);
      if (!mounted || gen != _generation) return;
      setState(() {
        _items.addAll(data);
        _nextPage = page + 1;
        _endReached = data.length < _pageSize;
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted || gen != _generation) return;
      setState(() {
        _pageError = true;
        _loadingMore = false;
      });
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }
}
