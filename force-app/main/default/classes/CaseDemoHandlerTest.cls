@isTest
private class CaseDemoHandlerTest {

    @TestSetup
    static void setupTestData() {
        List<Case> testCases = new List<Case>();
        testCases.add(new Case(Subject = 'Demo Case 1', Status = 'New',     Priority = 'Low'));
        testCases.add(new Case(Subject = 'Demo Case 2', Status = 'Working', Priority = 'Medium'));
        testCases.add(new Case(Subject = 'Demo Case 3', Status = 'Closed',  Priority = 'High'));
        insert testCases;
    }

    @isTest
    static void testGetOpenCases() {
        Test.startTest();
        List<Case> openCases = CaseDemoHandler.getOpenCases();
        Test.stopTest();

        System.assertNotEquals(null, openCases, 'Open cases list should not be null');
        // Only 2 cases are non-closed
        System.assertEquals(2, openCases.size(), 'Should return 2 open cases');
    }

    @isTest
    static void testUpdateCasePriority() {
        List<Case> casesToUpdate = [SELECT Id, Priority FROM Case WHERE Status != 'Closed'];

        Test.startTest();
        CaseDemoHandler.updateCasePriority(casesToUpdate, 'High');
        Test.stopTest();

        List<Case> updatedCases = [SELECT Id, Priority FROM Case WHERE Status != 'Closed'];
        for (Case c : updatedCases) {
            System.assertEquals('High', c.Priority, 'Priority should be updated to High');
        }
    }

    @isTest
    static void testUpdateCasePriorityEmptyList() {
        Test.startTest();
        CaseDemoHandler.updateCasePriority(new List<Case>(), 'Low');
        Test.stopTest();
        // No exception should be thrown
        System.assert(true, 'Empty list should be handled gracefully');
    }

    @isTest
    static void testGetCaseGreeting() {
        Case c = [SELECT Id, CaseNumber, Subject FROM Case WHERE Subject = 'Demo Case 1' LIMIT 1];

        Test.startTest();
        String greeting = CaseDemoHandler.getCaseGreeting(c);
        Test.stopTest();

        System.assertNotEquals(null, greeting, 'Greeting should not be null');
        System.assert(greeting.contains('Demo Case 1'), 'Greeting should contain the case subject');
    }

    @isTest
    static void testGetCaseGreetingNullCase() {
        Test.startTest();
        String greeting = CaseDemoHandler.getCaseGreeting(null);
        Test.stopTest();

        System.assertEquals('No Case provided.', greeting, 'Should return default message for null case');
    }
}