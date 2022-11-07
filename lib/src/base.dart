import './hexabase.dart';
import 'package:graphql/client.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

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

  /*
  static Future<dynamic> post(String path, dynamic data,
      {bool auth = true, bool multipart = false}) async {
    if (auth && client.token == null) {
      throw Exception('Not authenticated');
    }
    final dio = Dio();
    dio.interceptors.add(LogInterceptor(responseBody: false));
    // dio.options.contentType = Headers.formUrlEncodedContentType;
    if (multipart) {
      data = FormData.fromMap({
        'filename': data['filename'],
        'file': MultipartFile.fromBytes(data['file'],
            filename: data['filename'], contentType: MediaType('image', 'png')),
      });
    }
    final response = await dio.post(
      '${client.getRestEndPoint()}$path',
      data: data,
      options: Options(
        headers: {
          'Authorization': 'Bearer ${client.token}',
        },
      ),
    );
    print(response.data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.data;
    } else {
      throw Exception('Failed to load post');
    }
  }
  */
}
