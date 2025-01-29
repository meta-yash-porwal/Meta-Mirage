@isTest
public with sharing class Mirage_POC implements HttpCalloutMock {
    Integer calls = 0;

    public HTTPResponse respond(HTTPRequest req) {
        calls++;
        System.assertEquals('GET', req.getMethod());
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"hello": "world"}');
        res.setStatusCode(200);
        return res;
    }
    
    @future(callout=true)
    public static void callHTTPRequestMethod() {
        httpCreationMethod();
    }

    public static HttpResponse httpCreationMethod() {
        HttpRequest httpReq = new HttpRequest();
        httpReq.setEndpoint('https://www.metacube.com');
        httpReq.setMethod('GET');
        Http http = new Http();
        HttpResponse httpResp = http.send(httpReq);
        return httpResp;
    }

    @future(callout=true)
    public static void callHTTPRequestMethod2() {
        HttpRequest httpReq = new HttpRequest();
        httpReq.setEndpoint('https://www.metacube.com');
        httpReq.setMethod('GET');
        Http http = new Http();
        http.send(httpReq);
    }

    @future(callout=true)
    public static void callHTTPRequestMethod3() {
        HttpRequest httpReq = new HttpRequest();
        httpReq.setEndpoint('https://www.metacube.com');
        httpReq.setMethod('GET');
        Http http = new Http();

        if (!Test.isRunningTest()) {
            http.send(httpReq);
        }
    }

    @IsTest
    public static void testHTTPCalloutMock() {
        Mirage_POC poc = new Mirage_POC();
        Test.setMock(HttpCalloutMock.class, poc);
        Test.startTest();
        HttpResponse hr = httpCreationMethod();
        callHTTPRequestMethod2();
        callHTTPRequestMethod3();
        Test.stopTest();
        System.assertEquals(200, hr.getStatusCode());
        System.assertEquals(2, poc.calls);
        System.assertEquals(0, Limits.getCallouts());
    }


    public static void picklistValueUpdate() {
        Schema.DescribeSObjectResult dfrAcc = Schema.SObjectType.Account;
        Schema.DescribeFieldResult dfr = Account.Industry.getDescribe();
        Schema.DescribeFieldResult dfrName = Account.Name.getDescribe();
        List<metadataservice.CustomValue> picklistValues = new List<metadataservice.CustomValue>();
    
        for (Schema.PicklistEntry value :dfr.getPicklistValues()) {
            metadataservice.CustomValue temp = new metadataservice.CustomValue();
            temp.fullName = value.getLabel();
            temp.isActive = value.isActive();
            temp.color = '#ffffff';
            temp.default_x = value.isDefaultValue();
            picklistValues.add(temp);
        }
        metadataservice.CustomValue temp = new metadataservice.CustomValue();
        temp.fullName = 'AI';
        temp.default_x = false;
        temp.isActive = true;
        temp.color = '#ffffff';
        picklistValues.add(temp);

        MetadataService.MetadataPort service = createMetadataService();
                    
        List<MetadataService.CustomObject> objDemoList = new List<MetadataService.CustomObject>();
        MetadataService.CustomObject customObject = new MetadataService.CustomObject();
        MetadataService.CustomField customfield = new MetadataService.CustomField();
        MetadataService.CustomField objectNameField = new MetadataService.CustomField();

        metadataservice.ValueSet vs = new metadataservice.ValueSet();
        metadataservice.ValueSetValuesDefinition vd = new metadataservice.ValueSetValuesDefinition();
        vd.sorted = false;
        vd.value = picklistValues;
        vs.valueSetDefinition = vd;

        customField.valueSet = vs;
        customfield.fullName = dfr.getName();
        customfield.inlineHelpText = dfr.getInlineHelpText();
        customfield.label = dfr.getLabel();
        customfield.type_x = 'Picklist';

        objectNameField.fullName = dfrName.getName();
        objectNameField.label = dfrName.getLabel();
        objectNameField.type_x = 'Text';

        customObject.fullName = dfrAcc.getName();
        customObject.label = dfrAcc.getLabel();
        customObject.pluralLabel = dfrAcc.getLabelPlural();
        customObject.nameField = objectNameField;
        customObject.fields = new List<MetadataService.CustomField>{customField};
        customObject.deploymentStatus = 'Deployed';
        customObject.sharingModel = 'ReadWrite';
        objDemoList.add(customObject);
        service.updateMetadata(objDemoList);
    }

    private static MetadataService.MetadataPort createMetadataService() {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;
    }
}
