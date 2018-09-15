import ballerina/http;
import ballerina/log;
import ballerina/io;

endpoint http:Client clientEndpoint {
    url: "http://localhost:8081/hello"
};
// By default, Ballerina assumes that the service is to be exposed via HTTP/1.1.
service<http:Service> hello bind { port: 8080 } {

    // All resources are invoked with arguments of server connector and request.
    @http:ResourceConfig {
        methods: ["GET"],
        path:"serviceA"
    }
    sayHello(endpoint caller, http:Request req) {
        string textValue = check req.getTextPayload();
        //log:printInfo("Service A");
        //log:printInfo(textValue);
        http:Request reqB = untaint req;
        http:Response res = new;

        var responseB = clientEndpoint->get("/serviceB", message=reqB);

        match responseB {
            http:Response resp => {
                var contentVal = resp.getTextPayload();
                match contentVal {
                    string sPayload => {
                        res.setPayload(untaint sPayload);
                    }
                    error err => {
                        log:printError(err.message, err = err);
                    }
                }
            }
            error err => { log:printError(err.message, err = err); }
        }

        // Sends the response back to the caller.
        caller->respond(res) but { error e => log:printError("Error sending response", err = e) };
    }
}