using {buyer.portal.direct as my} from '../db/schema';

service buyer.portal.direct.request

{
  @odata.draft.enabled
  @(
    Common.SideEffects #ItemChanged  : {
      SourceEntities  : [_Items],
      TargetProperties: ['TotalPrice']
    },

    Common.SideEffects #CommentsAdded: {
      SourceProperties: ['StatusCode_Code'],
      TargetEntities  : [_Comments]
    },

    Common.SideEffects #ItemsAdded   : {
      SourceProperties: ['StatusCode_Code'],
      TargetEntities  : [_Items]
    }
  )
  entity RequestHeader @(restrict: [
    {
      grant: '*',
      to   : 'Admin'
    },
    {
      grant: '*',
      to   : 'User',
      where: 'createdBy = $user'
    },
    {
      grant: 'READ',
      to   : 'Approver'
    }
  ])                      as projection on my.RequestHeader
    actions {
      @(
        cds.odata.bindingparameter.name: '_it',
        Common.SideEffects             : {TargetProperties: ['_it/StatusCode_Code']}
      )

      action RequestApproval() returns String;

    }

  annotate RequestHeader with @(UI.UpdateHidden: {$edmJson: {$If: [
    {$Eq: [
      {$Path: 'StatusCode_Code'},
      'A'
    ]},
    true,
    false
  ]}}, );

  annotate RequestHeader with @changelog: [RequestDesc] {
    RequestDesc @changelog;
    StatusCode  @changelog
  };


  annotate RequestHeader with @(UI.DeleteHidden: {$edmJson: {$If: [
    {$Eq: [
      {$Path: 'StatusCode_Code'},
      'A'
    ]},
    true,
    false
  ]}}, );

  @(Common.SideEffects #ItemChanged: {
    SourceProperties: ['material_ID'],
    TargetProperties: ['Price']
  }, )
  entity RequestItem      as projection on my.RequestItem;

  annotate RequestItem {
    Quantity @changelog
  }


  entity Material         as projection on my.Material;
  entity Plant            as projection on my.Plant;
  entity Status           as projection on my.Status;
  entity Comments         as projection on my.Comments;
  entity Attachment       as projection on my.Attachment;

  @cds.persistence.skip
  @odata.singleton
  entity ExcelUpload {
    @Core.MediaType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    excel : LargeBinary;
  };


  entity DMSAppAttachment as projection on my.DMSAppAttachment
  action RejectApproval(id : UUID)                                                       returns {};
  action CreatePurchaseReq(id : UUID)                                                    returns {};
  action CopyAttachments(requestHeaderID : UUID, copiedRequestHeaderID : UUID)           returns {};
  action UpdateItemName(DMSItemID : String, requestHeaderID : String, fileName : String) returns {}
}
