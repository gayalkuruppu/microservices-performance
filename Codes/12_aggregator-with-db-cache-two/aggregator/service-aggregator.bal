import ballerina/http;
import ballerina/log;
import ballerina/io;
import ballerina/internal;

endpoint http:Client clientEndpointFamousPolitical {
    url: "http://172.16.53.76:8081/serviceFamousPolitical"
};

endpoint http:Client clientEndpointSports {
    url: "http://172.16.53.70:8082/serviceSports"
};

//url: "http://172.16.53.76:8081/serviceFamousPolitical"
//url: "http://172.16.53.70:8082/serviceSports"
//url: "http://localhost:8081/serviceFamousPolitical"
//url: "http://localhost:8082/serviceSports"

service<http:Service> serviceAggregator bind { port: 8080 } {

    getAll(endpoint caller, http:Request req) {

        http:Response res = new;

        //getting the political and famous news from the serviceFamousPolitical microservice
        var responseFamousPolitical = clientEndpointFamousPolitical->get("/getAll");

        json famousPoliticalNews;
        match responseFamousPolitical {
            http:Response resp => {
                famousPoliticalNews = check resp.getJsonPayload();
            }
            error err => {
                famousPoliticalNews = {"Error": "Internal Error"};
            }
        }

        //getting the sports news from the sportsNews microservice
        var responseSports = clientEndpointSports->get("/getAll");

        json sportsNews;
        match responseSports {
            http:Response resp => {
                sportsNews = check resp.getJsonPayload();
            }
            error err => {
                sportsNews = {"Error": "Internal Error"};
            }
        }

        if(famousPoliticalNews.toString().contains("Internal Error") || sportsNews.toString().contains("Internal Error")){
            res.statusCode = 500;
            res.setPayload({"Error": "Internal Error"});
        } else {
            res.setPayload({"PoliticalFamousNews":untaint famousPoliticalNews, "SportsNews":untaint sportsNews});
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