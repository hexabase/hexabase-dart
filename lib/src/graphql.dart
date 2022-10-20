String GRAPHQL_LOGIN = r'''
  mutation Login($loginInput: LoginInput!) {
    login(loginInput: $loginInput) {
      token
    }
  }
''';

String GRAPHQL_LOGIN_AUTH0 = r'''
  mutation loginAuth0($auth0Input: Auth0Input!) {
    loginAuth0(auth0Input: $auth0Input) {
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

String GRAPHQL_GET_APPLICATION_AND_DATASTORE = r'''
  query GetApplicationAndDataStore($workspaceId: String!) {
    getApplicationAndDataStore(workspaceId: $workspaceId) {
      application_id
      name
      display_id
      datastores {
        name
        datastore_id
      }
    }
  }
''';

String GRAPHQL_APPLICAION_CREATE_PROJECT = r'''
  mutation applicationCreateProject($createProjectParams: CreateProjectParams!) {
    applicationCreateProject(createProjectParams: $createProjectParams) {
      project_id
    }
  }
''';

String GRAPHQL_UPDATE_PROJECT_NAME = r'''
  mutation updateProjectName($payload: UpdateProjectNamePl!) {
    updateProjectName(payload: $payload) {
      success
      data
    }
  }
''';

String GRAPHQL_DELETE_PROJECT = r'''
  mutation deleteProject($payload: DeleteProjectPl!) {
    deleteProject(payload: $payload) {
      success
      data
    }
  }
''';

String GRAPHQL_CREATE_WORKSPACE = r'''
  mutation createWorkspace($createWorkSpaceInput: CreateWorkSpaceInput!) {
    createWorkspace(createWorkSpaceInput: $createWorkSpaceInput) {
      w_id
    }
  }
''';

String GRAPHQL_GET_ITEM_SEARCH_CONDITIONS = r'''
  query getItemSearchConditions ($datastoreId: String!, $projectId: String!) {
    getItemSearchConditions(datastoreId: $datastoreId, projectId: $projectId) {
      has_error
      result {
        f_id
        name
        display_id
        data_type
        max_value
        min_value
        order
        users_info {
          single_select
        }
        ds_lookup_info {
          dslookup_project_id
          dslookup_datastore_id
          dslookup_field_id
        }
        options {
          option_id
          sort_id
          value
          enabled
          color
        }
        statuses {
          status_id
          status_name
        }
      }
    }
}
''';

String GRAPHQL_DATASTORE_GET_DATASTORE_ITEMS = r'''
  mutation datastoreGetDatastoreItems(
    $projectId: String,
    $datastoreId: String!,
    $getItemsParameters: GetItemsParameters!
  ) {
    datastoreGetDatastoreItems(
      projectId: $projectId,
      getItemsParameters: $getItemsParameters,
      datastoreId: $datastoreId
    ) {
      items
      totalItems
    }
  }
''';

String GRAPHQL_GET_APPLICATION_PROJECT_ID_SETTING = r'''
  query getApplicationProjectIdSetting ($applicationId: String!) {
    getApplicationProjectIdSetting(applicationId: $applicationId) {
      p_id
      name {
        ja
        en
      }
      id
      display_id
      created_at
      updated_at
    }
  }
''';

String GRAPHQL_DATASTORE_UPDATE_ITEM = r'''
  mutation DatastoreUpdateItem(
    $itemActionParameters: ItemActionParameters!
    $itemId: String!
    $datastoreId: String!
    $projectId: String!
  ) {
    datastoreUpdateItem(
      ItemActionParameters: $itemActionParameters
      itemId: $itemId
      datastoreId: $datastoreId
      projectId: $projectId
    )
  }
''';

String GRAPHQL_DATASTORE_CREATE_NEW_ITEM = r'''
  mutation DatastoreCreateNewItem($newItemActionParameters: NewItemActionParameters!, $datastoreId: String!, $projectId: String!) {
    datastoreCreateNewItem(newItemActionParameters: $newItemActionParameters, datastoreId: $datastoreId, projectId: $projectId) {
      error
      history_id
      item
      item_id
    }
  }
''';

String GRAPHQL_GET_DATASTORE_ITEM_DETAILS = r'''
  query GetDatastoreItemDetails($itemId: String!, $datastoreId: String!, $projectId: String, $datastoreItemDetailParams: DatastoreItemDetailParams) {
    getDatastoreItemDetails(itemId: $itemId, datastoreId: $datastoreId, projectId: $projectId, datastoreItemDetailParams: $datastoreItemDetailParams) {
      title
      rev_no
      field_values
      status_list
      item_actions
      status_actions
      status_order
      status_action_order
      item_action_order
    }
  }
''';

String GRAPHQL_DATASTORE_DELETE_ITEM = r'''
  mutation DatastoreDeleteItem($deleteItemReq: DeleteItemReq!, $itemId: String!, $datastoreId: String!, $projectId: String!) {
    datastoreDeleteItem(deleteItemReq: $deleteItemReq, itemId: $itemId, datastoreId: $datastoreId, projectId: $projectId) {
      error
    }
  }
''';

String GRAPHQL_DATASTORE_EXECUTE_ITEM_ACTION = r'''
  mutation DatastoreExecuteItemAction(
    $projectId: String!,
    $datastoreId: String!,
    $actionId: String!,
    $itemId: String!,
    $itemActionParameters: ItemActionParameters!
  ) {
    datastoreExecuteItemAction(
      projectId: $projectId,
      datastoreId: $datastoreId,
      actionId: $actionId,
      itemId: $itemId,
      itemActionParameters: $itemActionParameters
    ) {
      item_id
      item
      error
    }
  }
''';
