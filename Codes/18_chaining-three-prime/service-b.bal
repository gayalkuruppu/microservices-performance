import ballerina/http;
import ballerina/log;

endpoint http:Client clientEndpoint {
    url: "http://172.16.53.54:8082/prime"
};

@http:ServiceConfig {
    basePath: "/prime"
}
service<http:Service> PrimeServiceTwo bind { port: 8081 } {
    // All resources are invoked with arguments of server connector and request.
    @http:ResourceConfig {
        methods: ["GET"],
        path: "/check"
    }
    checkPrime(endpoint caller, http:Request req) {
        http:Response res = new;
        var params = req.getQueryParams();
        var num = <int>params.number;
        var low = <int>params.lower;
        var up = <int>params.upper;

        int number=0;
        int uBoundry=0;
        int lBoundry=0;
        match num {
            int valueNum => {
                number = valueNum;

                match low {
                    int valueLow => {
                        lBoundry = valueLow;

                        match up {
                            int valueUp => {
                                uBoundry = valueUp;

                                int boundry = ((number/2) / 3);
                                int remainder = ((number/2) % 3);

                                int uBoundryServiceNext=number/2;
                                int lBoundryServiceNext=0;

                                if(remainder == 0){
                                    //log:printInfo("r0");

                                    lBoundryServiceNext=(boundry*2)+1;
                                } else if(remainder == 1){
                                    //log:printInfo("r1");

                                    lBoundryServiceNext=(boundry*2)+2;
                                }else {
                                    //log:printInfo("r2");

                                    lBoundryServiceNext=(boundry*2)+2;
                                }
                                //log:printInfo(<string>lBoundry);
                                //log:printInfo(<string>uBoundry);
                                //log:printInfo(<string>lBoundryServiceNext);
                                //log:printInfo(<string>uBoundryServiceNext);
                                //log:printInfo("yes");

                                boolean ans = isPrime(number,lBoundry,uBoundry);

                                if(ans){
                                    string path="/check?number="+number+"&lower="+lBoundryServiceNext+"&upper="+uBoundryServiceNext;

                                    //log:printInfo("true");

                                    var responseNext = clientEndpoint->get(untaint path);

                                    json respNext;
                                    match responseNext {
                                        http:Response resp => {
                                            respNext = check resp.getJsonPayload();
                                            res.statusCode = resp.statusCode;
                                            res.setJsonPayload(untaint respNext);
                                        }
                                        error err => {
                                            res.statusCode = 500;
                                            res.setPayload({"Error": "Internal Error"});
                                        }
                                    }
                                } else {
                                    //log:printInfo("false");
                                    res.setJsonPayload({"isPrime":ans});
                                }
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
