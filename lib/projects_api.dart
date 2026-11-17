import 'dart:math';

import 'api_data_model.dart';

abstract class ProjectsDataSource {
  Future<List<ApiDataModel>> fetchProjects(int page);
}

class ProjectsApi implements ProjectsDataSource {
  final _rng = Random();

  @override
  Future<List<ApiDataModel>> fetchProjects(int page) async {
    await Future.delayed(const Duration(milliseconds: 900));

    if (_rng.nextInt(5) == 0) throw ApiException('server error');

    if (page > 7) return [];

    return List.generate(
      20,
      (i) => ApiDataModel(
        id: 'p${page * 20 + i}',
        title: 'Project ${page * 20 + i}',
        company: 'Company ${_rng.nextInt(50)}',
        payout: 200 + _rng.nextInt(1800),
      ),
    );
  }
}
