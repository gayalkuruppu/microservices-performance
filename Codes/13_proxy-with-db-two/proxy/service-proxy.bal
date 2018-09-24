import ballerina/http;
import ballerina/log;
import ballerina/io;
import ballerina/internal;

endpoint http:Client clientEndpointFamousPolitical {
    //url: "http://172.16.53.76:8081/serviceFamousPolitical"
    url: "http://localhost:8081/serviceFamousPolitical"
};

endpoint http:Client clientEndpointSports {
    //url: "http://172.16.53.70:8082/serviceSports"
    url: "http://localhost:8082/serviceSports"
};

service<http:Service> serviceProxy bind { port: 8080 } {

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/{resourcepath}"
    }
    getFamousAndPoliticalNews(endpoint caller, http:Request req, string resourcepath) {
        if(resourcepath.contains("famouspoliticalnews")){
            //io:println("proxy1");
            var clientFamousPoliticalResponse = clientEndpointFamousPolitical->forward("/getAll", req);
            
            match clientFamousPoliticalResponse{
                http:Response resp => {
                    _ = caller -> respond(resp);
                }
                error err => {
                    http:Response res = new;
                    res.statusCode = 500;
                    res.setPayload(err.message);
                    _ = caller -> respond(res);
                    //log:printError("Error sending response", e);
                }
            }
        } else if (resourcepath.contains("sportsnews")){
            //io:println("proxy2");
            var clientSportsResponse = clientEndpointSports->forward("/getAll", req);

            match clientSportsResponse {
                http:Response resp => {
                    _ = caller -> respond(resp);
                }
                error err => {
                    http:Response res = new;
                    res.statusCode = 500;
                    res.setPayload(err.message);
                    _ = caller -> respond(res);
                    //log:printError("Error sending response", e);
                }
            }
        }
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path:"test"
    }
    testService(endpoint caller, http:Request req) {
        http:Response res = new;
        res.setPayload("hello, this is proxy service");
        _ = caller -> respond(res);
    }
}