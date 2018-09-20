import ballerina/http;
import ballerina/mysql;
import ballerina/log;
import ballerina/io;

endpoint mysql:Client testDB {
    host: "localhost",
    port: 3306,
    name: "type2SportsNewsDb",
    username: "root",
    password: "user",
    poolOptions: { maximumPoolSize: 50 },
    dbOptions: { useSSL: false }
};

service<http:Service> serviceSports bind { port: 8082 } {
    getAll(endpoint caller, http:Request req) {

        http:Response res = new;

        try {
            var selectRet = testDB->select("SELECT * FROM type2SportsNewsDb.news;", ());
            table dt;

            //json returnValue;
            match selectRet {
                table tableReturned => {
                    dt = tableReturned;

                    //convert to json
                    var jsonConversionRet = <json>dt;
                    match jsonConversionRet {
                        json jsonRes => {
                            log:printDebug(jsonRes.toString());
                            res.setPayload(untaint jsonRes);
                        }
                        error e => {
                            res.statusCode = 500;
                            res.setPayload({"Error": "Internal Error"});
                        }
                    }
                }
                error e => {
                    //log:printError(e.message);
                    res.statusCode = 500;
                    res.setPayload({"Error": "Internal Error"});
                }
            }
        } catch (error err) {
            res.statusCode = 500;
            res.setPayload({"Error": "Internal Error"});
        }

        _ = caller -> respond(res);
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path:"test"
    }
    testService(endpoint caller, http:Request req) {
        http:Response res = new;
        res.setPayload("hello, this is sports news service");
        _ = caller -> respond(res);
    }
}