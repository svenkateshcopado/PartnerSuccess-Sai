public with sharing class ProjectController {

    /**
     * Creates a new copado__Project__c record.
     * @param projectName   The name of the project (required).
     * @param status        The status of the project (e.g., 'Draft', 'Planned', 'In progress', 'Completed').
     * @param startDate     The start date of the project.
     * @param endDate       The end date of the project.
     * @param description   A description of the project.
     * @param apiName       An API name identifier for the project.
     * @return              The Id of the newly created project record.
     */
    public static Id createProject(
        String projectName,
        String status,
        Date startDate,
        Date endDate,
        String description,
        String apiName
    ) {
        if (String.isBlank(projectName)) {
            throw new ProjectControllerException('Project Name is required and cannot be blank.');
        }

        copado__Project__c newProject = new copado__Project__c(
            Name                    = projectName,
            copado__Status__c       = status,
            copado__Start_Date__c   = startDate,
            copado__End_Date__c     = endDate,
            copado__Description__c  = description,
            copado__API_Name__c     = apiName
        );

        try {
            insert newProject;
        } catch (DmlException e) {
            throw new ProjectControllerException(
                'Failed to create Project record: ' + e.getDmlMessage(0)
            );
        }

        return newProject.Id;
    }

    /**
     * Bulk creates a list of copado__Project__c records.
     * @param projects  List of copado__Project__c records to insert.
     * @return          List of Ids of the newly created project records.
     */
    public static List<Id> createProjects(List<copado__Project__c> projects) {
        if (projects == null || projects.isEmpty()) {
            throw new ProjectControllerException('Project list cannot be null or empty.');
        }

        for (copado__Project__c proj : projects) {
            if (String.isBlank(proj.Name)) {
                throw new ProjectControllerException('Each project must have a valid Name.');
            }
        }

        try {
            insert projects;
        } catch (DmlException e) {
            throw new ProjectControllerException(
                'Failed to bulk create Project records: ' + e.getDmlMessage(0)
            );
        }

        List<Id> projectIds = new List<Id>();
        for (copado__Project__c proj : projects) {
            projectIds.add(proj.Id);
        }
        return projectIds;
    }

    public class ProjectControllerException extends Exception {}
}