@isTest
public with sharing class Test_Mirage_POC implements HttpCalloutMock {
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

    @IsTest
    public static void testHTTPCalloutMock() {
        Test_Mirage_POC poc = new Test_Mirage_POC();
        Test.setMock(HttpCalloutMock.class, poc);
        Test.startTest();
        HttpResponse hr = Mirage_POC.httpCreationMethod();
        Mirage_POC.callHTTPRequestMethod2();
        Mirage_POC.callHTTPRequestMethod3();
        Test.stopTest();
        System.assertEquals(200, hr.getStatusCode());
        System.assertEquals(2, poc.calls);
        System.assertEquals(0, Limits.getCallouts());
    }


}
