@IsTest
private class ProjectControllerTest {

    // ─── Single Record Create ────────────────────────────────────────────────

    @IsTest
    static void testCreateProject_Success() {
        Test.startTest();
        Id projectId = ProjectController.createProject(
            'Test Project',
            'Draft',
            Date.today(),
            Date.today().addDays(30),
            'A test project description',
            'TEST_API_NAME'
        );
        Test.stopTest();

        System.assertNotEquals(null, projectId, 'Project Id should not be null after creation.');

        copado__Project__c created = [
            SELECT Id, Name, copado__Status__c, copado__Start_Date__c,
                   copado__End_Date__c, copado__Description__c, copado__API_Name__c
            FROM copado__Project__c
            WHERE Id = :projectId
        ];

        System.assertEquals('Test Project',          created.Name,                   'Name mismatch.');
        System.assertEquals('Draft',                 created.copado__Status__c,      'Status mismatch.');
        System.assertEquals(Date.today(),            created.copado__Start_Date__c,  'Start date mismatch.');
        System.assertEquals(Date.today().addDays(30),created.copado__End_Date__c,    'End date mismatch.');
        System.assertEquals('A test project description', created.copado__Description__c, 'Description mismatch.');
        System.assertEquals('TEST_API_NAME',         created.copado__API_Name__c,    'API Name mismatch.');
    }

    @IsTest
    static void testCreateProject_BlankName_ThrowsException() {
        Test.startTest();
        try {
            ProjectController.createProject('', 'Draft', null, null, null, null);
            System.assert(false, 'Expected ProjectControllerException was not thrown.');
        } catch (ProjectController.ProjectControllerException e) {
            System.assert(
                e.getMessage().contains('Project Name is required'),
                'Exception message mismatch: ' + e.getMessage()
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void testCreateProject_NullName_ThrowsException() {
        Test.startTest();
        try {
            ProjectController.createProject(null, 'Planned', null, null, null, null);
            System.assert(false, 'Expected ProjectControllerException was not thrown.');
        } catch (ProjectController.ProjectControllerException e) {
            System.assert(
                e.getMessage().contains('Project Name is required'),
                'Exception message mismatch: ' + e.getMessage()
            );
        }
        Test.stopTest();
    }

    // ─── Bulk Create ─────────────────────────────────────────────────────────

    @IsTest
    static void testCreateProjects_BulkSuccess() {
        List<copado__Project__c> projects = new List<copado__Project__c>();
        for (Integer i = 1; i <= 5; i++) {
            projects.add(new copado__Project__c(
                Name                   = 'Bulk Project ' + i,
                copado__Status__c      = 'Planned',
                copado__Start_Date__c  = Date.today(),
                copado__End_Date__c    = Date.today().addDays(i * 10),
                copado__API_Name__c    = 'BULK_API_' + i
            ));
        }

        Test.startTest();
        List<Id> projectIds = ProjectController.createProjects(projects);
        Test.stopTest();

        System.assertEquals(5, projectIds.size(), 'Should have created 5 projects.');
        for (Id pid : projectIds) {
            System.assertNotEquals(null, pid, 'Each project Id should not be null.');
        }
    }

    @IsTest
    static void testCreateProjects_EmptyList_ThrowsException() {
        Test.startTest();
        try {
            ProjectController.createProjects(new List<copado__Project__c>());
            System.assert(false, 'Expected ProjectControllerException was not thrown.');
        } catch (ProjectController.ProjectControllerException e) {
            System.assert(
                e.getMessage().contains('cannot be null or empty'),
                'Exception message mismatch: ' + e.getMessage()
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void testCreateProjects_NullList_ThrowsException() {
        Test.startTest();
        try {
            ProjectController.createProjects(null);
            System.assert(false, 'Expected ProjectControllerException was not thrown.');
        } catch (ProjectController.ProjectControllerException e) {
            System.assert(
                e.getMessage().contains('cannot be null or empty'),
                'Exception message mismatch: ' + e.getMessage()
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void testCreateProjects_BlankNameInList_ThrowsException() {
        List<copado__Project__c> projects = new List<copado__Project__c>{
            new copado__Project__c(Name = '')
        };

        Test.startTest();
        try {
            ProjectController.createProjects(projects);
            System.assert(false, 'Expected ProjectControllerException was not thrown.');
        } catch (ProjectController.ProjectControllerException e) {
            System.assert(
                e.getMessage().contains('valid Name'),
                'Exception message mismatch: ' + e.getMessage()
            );
        }
        Test.stopTest();
    }
}