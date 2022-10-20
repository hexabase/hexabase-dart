import './hexabase.dart';
import 'package:graphql/client.dart';

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
            fetchPolicy: FetchPolicy.networkOnly,
          )
        : QueryOptions(
            document: gql(query),
            fetchPolicy: FetchPolicy.networkOnly,
          );
    final QueryResult result =
        await HexabaseBase.client.graphQLClient.query(options);
    if (result.hasException) {
      throw result.exception!;
    }
    return result;
  }
}
