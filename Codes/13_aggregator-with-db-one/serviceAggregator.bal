import ballerina/http;
import ballerina/log;
import ballerina/io;
import ballerina/internal;

endpoint http:Client clientEndpointNews {
    url: "http://172.16.53.53:8081/serviceNews"
    //url: "http://localhost:8081/serviceNews"
};


service<http:Service> serviceAggregator bind { port: 8080 } {

    getAll(endpoint caller, http:Request req) {

        http:Response res = new;

        //getting the news from the servicenews microservice
        var responseNews = clientEndpointNews->get("/getAll");

        json news;
        match responseNews {
            http:Response resp => {
                news = check resp.getJsonPayload();
                //io:println(news.toString());
            }
            error err => {
                news = {"Error": "Internal Error"};
            }
        }

        if(news.toString().contains("Internal Error")){
            res.statusCode = 500;
            res.setPayload({"Error": "Internal Error"});
        } else {
            res.setPayload({"News":untaint news});
        }
        _ = caller -> respond(res);
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path:"test"
    }
    testService(endpoint caller, http:Request req) {
        http:Response res = new;
        res.setPayload("hello, this aggregator service");
        _ = caller -> respond(res);
    }
}