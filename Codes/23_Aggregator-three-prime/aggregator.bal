import ballerina/http;
import ballerina/log;

endpoint http:Client clientEndpointOne {
    url: "http://localhost:8081/prime"
    //url: "http://172.16.53.102:8081/prime"
};
endpoint http:Client clientEndpointTwo {
    url: "http://localhost:8082/prime"
    //url: "http://172.16.53.103:8082/prime"
};

endpoint http:Client clientEndpointThree {
    url: "http://localhost:8083/prime"
    //url: "http://172.16.53.103:8083/prime"
};

// By default, Ballerina assumes that the service is to be exposed via HTTP/1.1.
@http:ServiceConfig {
    basePath: "/prime"
}
service<http:Service> PrimeServiceOne bind { port: 8080 } {

    // All resources are invoked with arguments of server connector and request.
    @http:ResourceConfig {
        methods: ["GET"],
        path: "/check"
    }
    checkPrime(endpoint caller, http:Request req) {
        http:Response res = new;

        var params = req.getQueryParams();
        var num = <int>params.number;
        int number=0;
        match num {
            int value => {
                number = value;
                int boundry = ((value/2) / 3);
                int remainder = ((value/2) % 3);

                int uBoundryServiceOne=0;
                int lBoundryServiceOne=2;
                int uBoundryServiceTwo=0;
                int lBoundryServiceTwo=0;
                int uBoundryServiceThree=number/2;
                int lBoundryServiceThree=0;

                if(remainder == 0){
                    //log:printInfo("r0");
                    uBoundryServiceOne=boundry;
                    uBoundryServiceTwo=(boundry*2);
                    lBoundryServiceTwo=boundry+1;
                    lBoundryServiceThree=(boundry*2)+1;
                } else if(remainder == 1){
                    //log:printInfo("r1");
                    uBoundryServiceOne=boundry+1;
                    lBoundryServiceTwo=boundry+2;
                    uBoundryServiceTwo=(boundry*2)+1;
                    lBoundryServiceThree=(boundry*2)+2;
                }else {
                    //log:printInfo("r2");
                    uBoundryServiceOne=boundry+1;
                    lBoundryServiceTwo=boundry+2;
                    uBoundryServiceTwo=(boundry*2)+1;
                    lBoundryServiceThree=(boundry*2)+2;
                }
                //log:printInfo(<string>lBoundryServiceOne);
                //log:printInfo(<string>uBoundryServiceOne);
                //log:printInfo(<string>lBoundryServiceTwo);
                //log:printInfo(<string>uBoundryServiceTwo);
                //log:printInfo("yes");

                string pathOne="/check?number="+number+"&lower="+lBoundryServiceOne+"&upper="+uBoundryServiceOne;
                var responseOne = clientEndpointOne->get(untaint pathOne);

                json respOne;

                match responseOne {
                    http:Response resOne => {
                        respOne = check resOne.getJsonPayload();
                    }
                    error err => {
                        respOne = {"Error": "Internal Error"};
                    }
                }

                string pathTwo="/check?number="+number+"&lower="+lBoundryServiceTwo+"&upper="+uBoundryServiceTwo;
                var responseTwo = clientEndpointTwo->get(untaint pathTwo);

                json respTwo;
                match responseTwo {
                    http:Response resTwo => {
                        respTwo = check resTwo.getJsonPayload();
                    }
                    error err => {
                        respTwo = {"Error": "Internal Error"};
                    }
                }

                string pathThree="/check?number="+number+"&lower="+lBoundryServiceThree+"&upper="+uBoundryServiceThree;
                var responseThree = clientEndpointThree->get(untaint pathThree);

                json respThree;
                match responseThree {
                    http:Response resThree => {
                        respThree = check resThree.getJsonPayload();
                    }
                    error err => {
                        respThree = {"Error": "Internal Error"};
                    }
                }


                if(respOne.toString().contains("true") && respTwo.toString().contains("true") && respThree.toString().contains("true")){
                    res.setJsonPayload({"isPrime":true});
                } else if (respOne.toString().contains("false") || respTwo.toString().contains("false") || respThree.toString().contains("false")){
                    res.setJsonPayload({"isPrime":false});
                } else {
                    res.statusCode = 500;
                    res.setPayload({"Error": "Internal Error"});
                }

            }
            error err => {
                res.statusCode = 500;
                res.setPayload({"Error": "Internal Error"});
            }
        }
        _ = caller -> respond(res);
    }

    test(endpoint caller, http:Request req) {
        http:Response res = new;
        res.setPayload("Hello, This is aggregator service");
        _ = caller -> respond(res);
    }
}
