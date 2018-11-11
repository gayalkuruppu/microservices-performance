import ballerina/http;
import ballerina/log;
import ballerina/io;
import ballerina/internal;

endpoint http:Client clientEndpointPrimeOne {
    //url: "http://172.16.53.102:8081/prime"
    url: "http://localhost:8081/prime"
};

@http:ServiceConfig {
    basePath: "/prime"
}
service<http:Service> serviceAggregator bind { port: 8080 } {

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/check"
    }
    aggregator(endpoint caller, http:Request req) {

        http:Response res = new;
        var params = req.getQueryParams();
        var num = <int>params.number;
        int number=0;
        match num {
            int value => {
                int boundry= (value/2);
                string path = "/check?number="+value+"&lower=2&upper="+boundry;

                //getting the ans from the service one microservice
                var responseAns = clientEndpointPrimeOne->get(untaint path);

                match responseAns {
                    http:Response resp => {
                        res = resp;
                    }
                    error err => {
                        res.statusCode = 500;
                        res.setPayload({"Error": "Internal Error"});
                    }
                }

            }
            error err => {
                res.statusCode = 500;
                res.setPayload({"Error": "Internal Error"});
            }
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