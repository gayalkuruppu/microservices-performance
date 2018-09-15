import ballerina/http;

// By default, Ballerina assumes that the service is to be exposed via HTTP/1.1.
service<http:Service> hello bind { port: 8080 } {

    // All resources are invoked with arguments of server connector and request.
    sayHello(endpoint caller, http:Request req) {
        http:Response res = new;
        // A util method that can be used to set a string payload.
        res.setPayload("Hello, World!");

        // Sends the response back to the caller.
        _ = caller -> respond(res);
    }
}
