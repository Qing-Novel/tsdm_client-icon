import 'dart:io' if (dart.libaray.js) 'package:web/web.dart';

import 'package:fpdart/fpdart.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/exceptions/exceptions.dart';
import 'package:tsdm_client/extensions/fp.dart';
import 'package:tsdm_client/instance.dart';
import 'package:tsdm_client/shared/providers/net_client_provider/net_client_provider.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:universal_html/parsing.dart';

/// Repository of searching.
class SearchRepository {
  static const _searchUrl = '$baseUrl/plugin.php';

  /// An search action with given parameters:
  ///
  /// * [keyword]: Query keyword.
  /// * [fid]: Forum id, 0 represents any forum.
  /// * [uid]: Author user id, 0represents any user.
  /// * [pageNumber]: Page number of search result.
  AsyncEither<uh.Document> searchWithParameters({
    required String keyword,
    required String fid,
    required String uid,
    required int pageNumber,
  }) => AsyncEither(() async {
    final queryParameters = <String, String>{
      'id': 'Kahrpba:search',
      'query': keyword,
      'authorid': uid,
      'fid': fid,
      'page': '$pageNumber',
    };

    final netClient = getIt.get<NetClientProvider>();
    final respEither = await netClient.get(_searchUrl, queryParameters: queryParameters).run();
    if (respEither.isLeft()) {
      return left(respEither.unwrapErr());
    }
    final resp = respEither.unwrap();
    if (resp.statusCode != HttpStatus.ok) {
      return left(HttpRequestFailedException(resp.statusCode));
    }

    final document = parseHtmlDocument(resp.data as String);
    return right(document);
  });
}
