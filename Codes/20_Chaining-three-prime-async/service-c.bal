import ballerina/http;
import ballerina/log;

// By default, Ballerina assumes that the service is to be exposed via HTTP/1.1.
@http:ServiceConfig {
    basePath: "/prime"
}
service<http:Service> PrimeServiceTwo bind { port: 8082 } {
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
        int upper=0;
        int lower=0;
        match num {
            int valueNum => {
                number = valueNum;

                match low {
                    int valueLow => {
                        lower = valueLow;

                        match up {
                            int valueUp => {
                                upper = valueUp;

                                boolean ans = isPrime(number,lower,upper);

                                res.setJsonPayload({"isPrime":ans});
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
