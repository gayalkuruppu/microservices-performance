import ballerina/http;

// By default, Ballerina assumes that the service is to be exposed via HTTP/1.1.
service<http:Service> hello bind { port: 8080 } {

    // All resources are invoked with arguments of server connector and request.
    @http:ResourceConfig {
        methods: ["GET"]
    }
    sayHello(endpoint caller, http:Request req) {
        string textValue = check req.getTextPayload();
        http:Response res = new;
        res.setPayload(untaint textValue);
        _ = caller -> respond(res);
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path:"test"
    }
    sayHellow(endpoint caller, http:Request req) {
        http:Response res = new;
        res.setPayload("Hello, World!");
        _ = caller -> respond(res);
    }
}
