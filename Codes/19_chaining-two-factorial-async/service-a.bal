import ballerina/http;
import ballerina/log;
import ballerina/runtime;

endpoint http:Client clientEndpoint {
    url: "http://172.16.53.54:8081/prime"
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
                int boundry = ((value/2) / 2);
                int remainder = ((value/2) % 2);

                int uBoundryServiceOne=0;
                int lBoundryServiceOne=2;
                int uBoundryServiceTwo=value/2;
                int lBoundryServiceTwo=0;

                if(remainder == 0){
                    //log:printInfo("r0");
                    uBoundryServiceOne=boundry;
                    lBoundryServiceTwo=boundry+1;
                } else {
                    //log:printInfo("r1");
                    uBoundryServiceOne=boundry+1;
                    lBoundryServiceTwo=boundry+2;
                }
                //log:printInfo(<string>lBoundryServiceOne);
                //log:printInfo(<string>uBoundryServiceOne);
                //log:printInfo(<string>lBoundryServiceTwo);
                //log:printInfo(<string>uBoundryServiceTwo);
                //log:printInfo("yes");

                string path="/check?number="+number+"&lower="+lBoundryServiceTwo+"&upper="+uBoundryServiceTwo;
                future<http:Response|error> f3 = start clientEndpoint->get(untaint path);

                boolean ans = isPrime(number,lBoundryServiceOne,uBoundryServiceOne);
                //log:printInfo(<string>ans);

                if(ans){
                    //log:printInfo("true");
                    var responseTwo = await f3;

                    json respTwo;
                    match responseTwo {
                        http:Response resp => {
                            respTwo = check resp.getJsonPayload();
                            //log:printInfo(respTwo.toString());
                            res.setJsonPayload(untaint respTwo);
                        }
                        error err => {
                            res.statusCode = 500;
                            res.setPayload({"Error": "Internal Error"});
                        }
                    }
                } else {
                    //log:printInfo("false");
                    boolean cancelled = f3.cancel();
                    //log:printInfo(<string>f3.isDone());
                    //log:printInfo(<string>cancelled);
                    res.setJsonPayload({"isPrime":ans});
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
        res.setPayload("Hello, This is prime service");
        _ = caller -> respond(res);
    }
}

function isPrime(int value,int lowerBoundry, int upperBoundry) returns (boolean) {
    boolean checkPrime = true;
    foreach divisor in lowerBoundry ... upperBoundry {
        //log:printInfo(<string>divisor);
        if (value % divisor == 0) {
            checkPrime = false;
            break;
        }
    }
    return checkPrime;
}
