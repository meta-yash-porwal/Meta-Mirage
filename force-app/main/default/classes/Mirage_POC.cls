public with sharing class Mirage_POC {
    
    /**
     *  future method to call when external callout need to make as per httpCreationMethod method.
     *  @return void
     */
    @future(callout=true)
    public static void callHTTPRequestMethod() {
        httpCreationMethod();
    }

    /**
     *  method to make GET http request callout to metacube.com.
     *  @return HttpResponse - return httpsReponse to check statusCode and response.
     */
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

    /**
     *  method to create Metadata service.
     *  @return MetadataService.MetadataPort - return MetadataPort to access Metadata service.
     */
    private static MetadataService.MetadataPort createMetadataService() {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;
    }

    /**
     * method to create picklist value using metadata service class 
     * By reading custom field and adding picklist value without removing other picklist value.
     * @return void
     */
    public static void createPicklistValue() {
        MetadataService.MetadataPort service = createMetadataService();     
        Schema.DescribeFieldResult dfr = Account.SLA__c.getDescribe();        

        // Read Custom Field
        MetadataService.CustomField customField = 
            (MetadataService.CustomField) service.readMetadata('CustomField', 
                new String[] { 'Account.' + dfr.getName() }).getRecords()[0];

        // Define the Value Set and Value Set Definitions
        MetadataService.ValueSet vs = new MetadataService.ValueSet();
        MetadataService.ValueSetValuesDefinition vd = new MetadataService.ValueSetValuesDefinition();

        // Define the picklist values
        List<MetadataService.CustomValue> customValues = new List<MetadataService.CustomValue>();
        MetadataService.CustomValue cv1 = new MetadataService.CustomValue();
        cv1.label = 'seven';
        cv1.fullName = 'seven';
        cv1.isActive = true;
        cv1.default_x = false;
        cv1.color = '#ffffff';
        customValues.add(cv1);
        MetadataService.CustomValue cv2 = new MetadataService.CustomValue();
        cv2.label = 'eight';
        cv2.fullName = 'eight';
        cv2.isActive = true;
        cv2.default_x = false;
        cv2.color = '#ffffff';
        customValues.add(cv2);
        customField.valueSet.valueSetDefinition.value.addAll(customValues);

        for (MetadataService.CustomValue customValue : customField.valueSet.valueSetDefinition.value) {
            // Not getting isActive value so setting it to true to avoid error
            customValue.isActive = true;
        }

        // Update Custom Field
        List<MetadataService.SaveResult> saveResultList = service.updateMetadata(new MetadataService.Metadata[] { customField });

        for (MetadataService.SaveResult saveResult : saveResultList) {
            
            if (saveResult.errors != null) {

                for (MetadataService.Error error : saveResult.errors) {
                    System.debug(error.message);
                    System.debug(error.fields);

                }   
            }
        }
    }

    @InvocableMethod
    public static List<String> returnAccountName (List<Id> ids) {
        List<String> accName = new List<String>();

        for (Account acc: [SELECT Id, Name FROM Account WHERE Id IN :ids]) {
            accName.add(acc.Name);
        }
        return accName;
    }

    /**
     * method to strip inaccessbile fields from SOQL and DML statements
     */
    public static void stripInaccess() {
        try {
            List<Contact> conList = [SELECT Id, Name FROM Contact LIMIT 10];
            SObjectAccessDecision decision1 = Security.stripInaccessible(AccessType.READABLE, conList);
            System.debug(decision1.getRecords());
            System.debug(decision1.getRemovedFields());
            
            Contact con = new Contact(FirstName = 'Test', LastName = 'Test');
            SObjectAccessDecision decision2 = Security.stripInaccessible(AccessType.CREATABLE, conList);
            System.debug(decision2.getRecords());
            System.debug(decision2.getRemovedFields());
            insert decision2.getRecords();
        } catch (Exception e) {
            throw new CustomException(e.getMessage());
            throw new Exception(e.getMessage());
            System.debug(e.getMessage());
        }
    }
}
