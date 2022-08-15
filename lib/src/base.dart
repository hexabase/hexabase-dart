import './hexabase.dart';
import 'package:graphql/client.dart';

class HexabaseBase {
  static late HexabaseClient client;

  Future<QueryResult> mutation(String query,
      {Map<String, dynamic>? variables}) async {
    final options = variables != null
        ? MutationOptions(
            document: gql(query),
            variables: variables,
          )
        : MutationOptions(
            document: gql(query),
          );
    final QueryResult result =
        await HexabaseBase.client.graphQLClient.mutate(options);
    if (result.hasException) {
      throw result.exception!;
    }
    return result;
  }

  Future<QueryResult> query(String query,
      {Map<String, dynamic>? variables}) async {
    final options = variables != null
        ? QueryOptions(
            document: gql(query),
            variables: variables,
          )
        : QueryOptions(
            document: gql(query),
          );
    final QueryResult result =
        await HexabaseBase.client.graphQLClient.query(options);
    if (result.hasException) {
      throw result.exception!;
    }
    return result;
  }
}
