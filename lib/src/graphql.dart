String GRAPHQL_LOGIN = r'''
  mutation Login($loginInput: LoginInput!) {
    login(loginInput: $loginInput) {
      token
    }
  }
''';

String GRAPHQL_WORKSPACES = r'''
  query Workspaces {
    workspaces {
      workspaces {
        workspace_name
        workspace_id
      }
      current_workspace_id
    }
  }
''';
