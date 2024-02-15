const String GRAPHQL_LOGIN = r'''
  mutation Login($loginInput: LoginInput!) {
    login(loginInput: $loginInput) {
      token
    }
  }
''';

const String GRAPHQL_LOGIN_AUTH0 = r'''
  mutation loginAuth0($auth0Input: Auth0Input!) {
    loginAuth0(auth0Input: $auth0Input) {
      token
    }
  }
''';

const String GRAPHQL_USER_INFO = r'''
  query UserInfo {
    userInfo {
      username
      email
      profile_pic
      u_id
      current_workspace_id
      is_ws_admin
      user_roles {
        r_id
        role_name
        role_id
        p_id
        application_id
        application_name
        application_display_order
      }
    }
  }
''';

const String GRAPHQL_WORKSPACES = r'''
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

const String GRAPHQL_GET_APPLICATION_AND_DATASTORE = r'''
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

const String GRAPHQL_APPLICAION_CREATE_PROJECT = r'''
  mutation applicationCreateProject($createProjectParams: CreateProjectParams!) {
    applicationCreateProject(createProjectParams: $createProjectParams) {
      project_id
    }
  }
''';

const String GRAPHQL_UPDATE_PROJECT_NAME = r'''
  mutation updateProjectName($payload: UpdateProjectNamePl!) {
    updateProjectName(payload: $payload) {
      success
      data
    }
  }
''';

const String GRAPHQL_DELETE_PROJECT = r'''
  mutation deleteProject($payload: DeleteProjectPl!) {
    deleteProject(payload: $payload) {
      success
      data
    }
  }
''';

const String GRAPHQL_GET_PROJECT = r'''
  query Query($projectId: String!) {
    getInfoProject(projectId: $projectId) {
      p_id
      display_order
      template_id
      display_id
      name
      w_id
    }
  }
''';

const String GRAPHQL_CREATE_WORKSPACE = r'''
  mutation createWorkspace($createWorkSpaceInput: CreateWorkSpaceInput!) {
    createWorkspace(createWorkSpaceInput: $createWorkSpaceInput) {
      w_id
    }
  }
''';

const String GRAPHQL_SELECT_WORKSPACE = r'''
  mutation setCurrentWorkSpace($setCurrentWorkSpaceInput: SetCurrentWorkSpaceInput!) {
    setCurrentWorkSpace(setCurrentWorkSpaceInput: $setCurrentWorkSpaceInput) {
      success
    }
  }
''';

const String GRAPHQL_GET_ITEM_SEARCH_CONDITIONS = r'''
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

const String GRAPHQL_DATASTORE_GET_DATASTORE_ITEMS = r'''
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

const String GRAPHQL_GET_APPLICATION_PROJECT_ID_SETTING = r'''
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

const String GRAPHQL_DATASTORE_UPDATE_ITEM = r'''
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

const String GRAPHQL_DATASTORE_CREATE_NEW_ITEM = r'''
  mutation DatastoreCreateNewItem($newItemActionParameters: NewItemActionParameters!, $datastoreId: String!, $projectId: String!) {
    datastoreCreateNewItem(newItemActionParameters: $newItemActionParameters, datastoreId: $datastoreId, projectId: $projectId) {
      error
      history_id
      item
      item_id
    }
  }
''';

const String GRAPHQL_GET_DATASTORE = r'''
  query DatastoreSetting($datastoreId: String!) {
    datastoreSetting(datastoreId: $datastoreId) {
      display_id
      names
      id
      field_layout {
        display_id
        col
        id
        row
        size_x
        size_y
      }
      fields {
        as_title
        data_type
        display_id
        display_name
        field_index
        full_text
        id
        max_value
        min_value
        names
        options {
          o_id
          _key
          fieldID
        }
        show_list
        search
        status
        title_order
        unique
      }
      roles {
        name
        id
        display_id
      }
      statuses {
        names
        display_id
        id
      }
    }
  }
''';

const String GRAPHQL_GET_DATASTORE_ITEM_DETAILS = r'''
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

const String GRAPHQL_DATASTORE_DELETE_ITEM = r'''
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

const String GRAPHQL_CREATE_ITEM_FILE_ATTACHMENT = r'''
  mutation CreateItemFileAttachment($payload: ItemFileAttachmentPl!) {
		createItemFileAttachment(payload: $payload) {
			_id
			created_at
			d_id
			contentType
      datastore_id
			deleted
			field_id
			display_order
			file_id
			filename
			filepath
      item_id
      i_id
			mediaLink
			p_id
			timeCreated
      size
      selfLink
			temporary
			updated
			w_id
      user_id
		}
	}
''';

const String GRAPHQL_GET_DOWNLOAD_FILE = r'''
  query GetDownloadFile($id: String!) {
		getDownloadFile(id: $id){
			
		}
	}
''';

const String GRAPHQL_DATASTORE_DELETEITEM_FILE_ATTACHMENT_ITEM = r'''
  mutation DatastoreDeleteItemFileAttachmentItem(
    $fileId: String!
    $fieldId: String!
    $itemId: String!
  ) {
    datastoreDeleteItemFileAttachmentItem(
      fileId: $fileId
      fieldId: $fieldId
      itemId: $itemId
    ) {
			data
			success
		}
	}
''';

const String GRAPHQL_LOGOUT = r'''
  mutation Logout {
    logout {
      data
      success
    }
  }
''';

const String GRAPHQL_DATASTORES_GLOBAL_SEARCH = r'''
mutation($payload: GlobalSearchPayload!) {
  datastoresGlobalSearch(
		payload: $payload
  ) {
    search_result {
      title
      file_name
      datastore_name
      a_id
      category
    }
    item_list
    page
    page_size
  }
}
''';

const String GRAPHQL_CREATE_DATASTORE_FROM_TEMPLATE = r'''
  mutation CreateDatastoreFromTemplate($payload: CreateDatastoreFromSeedReq!) {
    createDatastoreFromTemplate(payload: $payload) {
      datastoreId
    }
  }
''';

const String GRAPHQL_UPDATE_DATASTORE_SETTING = r'''
  mutation UpdateDatastoreSetting($payload: DatastoreUpdateSetting!) {
    updateDatastoreSetting(payload: $payload) {
      success
      data
    }
  }
''';

const String GRAPHQL_DELETE_DATASTORE = r'''
  mutation DeleteDatastore($datastoreId: String!) {
    deleteDatastore(datastoreId: $datastoreId) {
      success
    }
  }
''';

const String GRAPHQL_DATASTORE_GET_FIELDS = r'''
  query DatastoreGetFields($projectId: String!, $datastoreId: String!) {
    datastoreGetFields(
      projectId: $projectId
      datastoreId: $datastoreId
    )
    {
      fields
      field_layout
    }
  }
''';

const String GRAPHQL_DATASTORES = r'''
  query Datastores($projectId: String!) {
    datastores(
      projectId:$projectId
    )
    {
      d_id
      p_id
      w_id
      ws_name
      name
      uploading
      imported
      no_status
      show_in_menu
      deleted
      display_order
      display_id
      show_only_dev_mode
      use_qr_download
      use_csv_update
      use_external_sync
      use_replace_upload
      unread
      invisible
      use_grid_view
      use_grid_view_by_default
      use_board_view
      is_external_service
      data_source
      external_service_data
      show_display_id_to_list
      show_info_to_list
    }
  }
''';

const String GRAPHQL_DATASTORE_CREATE_FIELD = r'''
  mutation DatastoreCreateField($payload: CreateFieldPayload!, $datastoreId: String!) {
    datastoreCreateField(
      payload: $payload
      datastoreId: $datastoreId
    ) {
      display_id
      field_id
    }
  }
''';

const String GRAPHQL_GET_GROUP_TREE = r'''
  query GetGroupTree() {
    getGroupTree(
    ) {
      error
      result {
        id
        name
        display_id
        index
        show_child
        disable_ui_access
        childGroups {
          id
          name
          display_id
          index
          show_child
          disable_ui_access
        }
      }
    }
  }
''';

const String GRAPHQL_WORKSPACE_GET_GROUP_CHILDREN = r'''
  query WorkspaceGetGroupChildren($groupId: String) {
    workspaceGetGroupChildren(
      groupId: $groupId
    )
    {
      error
      group {
        g_id
        group_id
        name
        index
      }
      children {
        g_id
        group_id
        name
        index
      }
      count
    }
  }
''';

const String GRAPHQL_CREATE_GROUP = r'''
  mutation CreateGroup($parentGroupId: String!, $payload: CreateGroupReq!) {
    createGroup(
      payload: $payload
      parentGroupId: $parentGroupId
    ) {
      error
      groupTree_datastores_res
      group {
        id
        g_id
        name
        display_id
        index
        disable_ui_access
        is_root
        access_key
        created_at
      }
    }
  }
''';

const String GRAPHQL_UPDATE_GROUP = r'''
  query UpdateGroup($groupId: String!, $payload: UpdateGroupReq!) {
    updateGroup(
      payload: $payload
      groupId: $groupId
    ) {
      error
      group {
        g_id
        group_id
        name
        index
      }
      children {
        g_id
        group_id
        name
        index
      }
      count
    }
  }
''';

const String GRAPHQL_DELETE_GROUP = r'''
  query DeleteGroup($groupId: String!) {
    deleteGroup(
      groupId: $groupId
    ) {
      error
    }
  }
''';
