import ballerina/http;
import ballerina/mysql;
import ballerina/log;
import ballerina/io;

endpoint http:Client clientEndpoint {
    url: "http://localhost:8081/serviceB"
};

endpoint mysql:Client testDB {
    host: "localhost",
    port: 3306,
    name: "type1NewsDb",
    username: "root",
    password: "user",
    poolOptions: { maximumPoolSize: 100 },
    dbOptions: { useSSL: false }
};

service<http:Service> serviceA bind { port: 8080 } {

    getAll(endpoint caller, http:Request req) {
        http:Response res = new;
        var selectRet = testDB->select("SELECT * FROM type1NewsDb.news;", ());

        table dt;
        match selectRet {
            table tableReturned => {
                dt = tableReturned;
                //convert to json
                var jsonConversionRet = <json>dt;

                match jsonConversionRet {
                    json jsonRes => {

                        var responseB = clientEndpoint->get("/getAll");

                        match responseB {
                            http:Response resp => {
                                json newsB = check resp.getJsonPayload();
                                log:printDebug(jsonRes.toString());
                                res.setPayload({"PoliticalFamousNews": untaint jsonRes, "SportsNews":untaint newsB});
                            }
                            error err => {
                                res.statusCode = 500;
                                res.setPayload("Internal Error");
                            }
                        }
                    }
                    error e => {
                        //log:printError(e.message);
                        res.statusCode = 500;
                        res.setPayload("Internal error");
                    }
                }
            }
            error e => {
                res.statusCode = 500;
                res.setPayload("Internal error");
            }
        }

        _ = caller -> respond(res);
    }
}
