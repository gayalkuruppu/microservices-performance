import ballerina/http;
import ballerina/mysql;
import ballerina/log;
import ballerina/io;

endpoint mysql:Client testDB {
    host: "172.16.53.121",
    port: 3306,
    name: "type0NewsDb",
    username: "root",
    password: "user",
    poolOptions: { maximumPoolSize: 50 },
    dbOptions: { useSSL: false }
};

//172.16.53.67
service<http:Service> serviceNews bind { port: 8081 } {

    getAll(endpoint caller, http:Request req) {
        http:Response res = new;

        try {
            var selectRet = testDB->select("SELECT * FROM type0NewsDb.news;", ());

            //json returnValue;
            match selectRet {
                table tableReturned => {
                    //convert to json
                    var jsonConversionRet = <json>tableReturned;
                    match jsonConversionRet {
                        json jsonRes => {
                            res.setPayload(untaint jsonRes);
                        }
                        error e => {
                            //log:printError(e.message);
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
        res.setPayload("hello, this service provide all types of news");
        _ = caller -> respond(res);
    }
}