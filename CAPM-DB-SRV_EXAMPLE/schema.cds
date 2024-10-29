using from '@sap/cds-common-content';
using {OP_API_PRODUCT_SRV_0001 as prod_api} from '../srv/external/OP_API_PRODUCT_SRV_0001';
using {API_PURCHASEREQ_PROCESS_SRV as preq_api} from '../srv/external/API_PURCHASEREQ_PROCESS_SRV';
using {
  managed,
  sap.common.CodeList,
  Currency
} from '@sap/cds/common';


namespace buyer.portal.direct;

aspect cuid : managed {
  key ID : UUID;
}

entity RequestHeader : cuid {

  PRNumber               : String;
  PRType                 : String;
  StatusCode             : Association to Status;
  @mandatory RequestDesc : String;
  _Items                 : Composition of many RequestItem
                             on _Items.requestHeaderID = $self.ID;
  _Comments              : Composition of many Comments
                             on _Comments.requestHeaderID = $self.ID;


  RequestNo              : String(10);
  RequestNoInt           : Integer;

  @Semantics.TotalPrice.currencyCode: 'Currency'
  TotalPrice             : Decimal;
  _Attachments           : Composition of many Attachment
                             on _Attachments.header = $self;

  _DMSAppAttachments     : Association to many DMSAppAttachment
                             on _DMSAppAttachments.header = $self;

  @Semantics.currencyCode
  Currency               : Currency;
  decidedAt              : Timestamp;
}

entity RequestItem : cuid {
  requestHeaderID     : String;
  PRItemNumber        : String;
  @mandatory ItemDesc : String;
  @mandatory material : Association to Material;
  MaterialDesc        : String;
  PurOrg              : String;
  @mandatory plant    : Association to Plant;
  @mandatory Quantity : Integer;
  UoM                 : String;
  Price               : Decimal;
  ReqItemNo           : String;
  ReqItemNoInt        : Integer;
}

entity Material           as
  projection on prod_api.A_Product {
    key Product     as ID,
        ProductType as Desc

  }

entity Plant              as
  projection on prod_api.A_ProductPlant {
    key Plant as ID
  }


entity PurchaseRequsition as
  projection on preq_api.A_PurchaseReqnItemText {
    key PurchaseRequisition,
        PurchaseRequisitionItem
  }

entity Status : CodeList {
  key Code : String enum {
        InApproval = 'A';
        Ordered    = 'O';
        Rejected   = 'R';
        Saved      = 'S';
      };
}

entity Comments : cuid {

  requestHeaderID : String;
  Text            : LargeString;
}

entity Attachment : cuid {
  @Core.MediaType  : mediaType
  content   : LargeBinary;

  @Core.IsMediaType: true
  mediaType : String;
  fileName  : String;
  size      : Integer;
  url       : String;
  header    : Association to RequestHeader
}

@cds.persistence.skip
@Sdm.Entity
entity DMSAppAttachment {
  key id            : String @Sdm.Field     : {
        type: 'property',
        path: 'cmis:objectId'
      };
      fileName      : String
                             @Sdm.Field     : {
        type: 'property',
        path: 'cmis:name'
      };
      content       : LargeBinary

                             @Core.MediaType: mediaType  @Core.ContentDisposition.Filename: fileName;
      mediaType     : String

                             @Core.IsMediaType
                             @Sdm.Field     : {
        type: 'property',
        path: 'cmis:contentStreamMimeType'
      };
      createdBy     : String

                             @Sdm.Field     : {
        type: 'property',
        path: 'cmis:createdBy'
      };
      createdAtDate : String

                             @Sdm.Field     : {
        type: 'property',
        path: 'cmis:creationDate'
      };
      parentIds     : array of String

                             @Sdm.Field     : {
        type: 'property',
        path: 'sap:parentIds'
      };
      cmisObjectId  : String

                             @Sdm.Field     : {
        type: 'property',
        path: 'cmis:objectId'
      };
      url           : String @Sdm.Field     : {type: 'link'};
      header        : Association to one RequestHeader
}
