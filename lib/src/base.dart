import './hexabase.dart';
import 'package:graphql/client.dart';
import 'package:dio/dio.dart';
// import 'package:eventsource/eventsource.dart';

class HexabaseBase {
  static late Hexabase client;

  static Future<QueryResult> mutation(String query,
      {Map<String, dynamic>? variables, bool auth = true}) async {
    if (auth && client.token == null) {
      throw Exception('Not authenticated');
    }
    final options = variables != null
        ? MutationOptions(
            document: gql(query),
            variables: variables,
            fetchPolicy: FetchPolicy.noCache,
          )
        : MutationOptions(
            document: gql(query),
            fetchPolicy: FetchPolicy.noCache,
          );
    final QueryResult result =
        await HexabaseBase.client.graphQLClient.mutate(options);
    if (result.hasException) {
      throw result.exception!;
    }
    return result;
  }

  static Future<QueryResult> query(String query,
      {Map<String, dynamic>? variables, bool auth = true}) async {
    if (auth && client.token == null) {
      throw Exception('Not authenticated');
    }
    final options = variables != null
        ? QueryOptions(
            document: gql(query),
            variables: variables,
            fetchPolicy: FetchPolicy.noCache,
          )
        : QueryOptions(
            document: gql(query),
            fetchPolicy: FetchPolicy.noCache,
          );
    final QueryResult result =
        await HexabaseBase.client.graphQLClient.query(options);
    if (result.hasException) {
      throw result.exception!;
    }
    return result;
  }

  static Future<dynamic> get(String path,
      {Map<String, String>? query,
      bool auth = true,
      bool binary = false}) async {
    if (auth && client.token == null) {
      throw Exception('Not authenticated');
    }
    var uri = Uri.parse('${client.restUrl}$path');
    if (query != null) {
      uri = uri.replace(queryParameters: query);
    }

    final dio = Dio();
    // dio.interceptors.add(LogInterceptor(responseBody: false));
    var options = Options(
      headers: {
        'Authorization': 'Bearer ${HexabaseBase.client.token}',
        'Content-Type': 'application/json',
      },
    );
    if (binary) {
      options.responseType = ResponseType.bytes;
    }
    var response = await dio.get(uri.toString(), options: options);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.data;
    } else {
      throw Exception('Failed to load get');
    }
  }

  static Future<dynamic> delete(
    String path, {
    Map<String, String>? query,
    bool auth = true,
  }) async {
    if (auth && client.token == null) {
      throw Exception('Not authenticated');
    }
    var uri = Uri.parse('${client.restUrl}$path');
    if (query != null) {
      uri = uri.replace(queryParameters: query);
    }

    final dio = Dio();
    // dio.interceptors.add(LogInterceptor(responseBody: false));
    var options = Options(
      headers: {
        'Authorization': 'Bearer ${HexabaseBase.client.token}',
      },
    );
    var response = await dio.delete(uri.toString(), options: options);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.data;
    } else {
      throw Exception('Failed to load delete');
    }
  }

  static Future<dynamic> post(String path, dynamic data,
      {bool auth = true, bool multipart = false}) async {
    if (auth && client.token == null) {
      throw Exception('Not authenticated');
    }
    final dio = Dio();
    dio.interceptors.add(LogInterceptor(responseBody: false));
    final response = await dio.post(
      '${client.restUrl}$path',
      data: data,
      options: Options(
        headers: {
          'Authorization': 'Bearer ${client.token}',
        },
      ),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.data;
    } else {
      throw Exception('Failed to load post');
    }
  }
}
