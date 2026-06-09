public with sharing class CaseDemoHandler {

    /**
     * Returns a list of all Open Cases
     */
    public static List<Case> getOpenCases() {
        return [
            SELECT Id, CaseNumber, Subject, Status, Priority, OwnerId
            FROM Case
            WHERE Status != 'Closed'
            WITH SECURITY_ENFORCED
            LIMIT 200
        ];
    }

    /**
     * Updates the Priority of a given list of Cases
     */
    public static void updateCasePriority(List<Case> cases, String priority) {
        if (cases == null || cases.isEmpty()) return;
        for (Case c : cases) {
            c.Priority = priority;
        }
        update cases;
    }

    /**
     * Returns a simple greeting message for a Case
     */
    public static String getCaseGreeting(Case c) {
        if (c == null) return 'No Case provided.';
        return 'Hello! Case Number: ' + c.CaseNumber + ' | Subject: ' + c.Subject;
    }
}