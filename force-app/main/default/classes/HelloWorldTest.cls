@IsTest
private class HelloWorldTest {

    @IsTest
    static void testGreetWithName() {
        String result = HelloWorld.greet('Copado');
        System.assertEquals('Hello, Copado!', result, 'Should greet the provided name.');
    }

    @IsTest
    static void testGreetWithoutName() {
        String result = HelloWorld.greet(null);
        System.assertEquals('Hello, World!', result, 'Should return default greeting for null.');
    }

    @IsTest
    static void testGreetWithBlankName() {
        String result = HelloWorld.greet('   ');
        System.assertEquals('Hello, World!', result, 'Should return default greeting for blank string.');
    }
}