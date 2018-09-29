import ballerina/http;
import ballerina/mysql;
import ballerina/log;
import ballerina/io;
import ballerina/internal;
import wso2/redis;

// Mysql as the database
endpoint mysql:Client testDB {
    host: "localhost",
    port: 3306,
    name: "type1NewsDb",
    username: "root",
    password: "user",
    poolOptions: { maximumPoolSize: 50 },
    dbOptions: { useSSL: false }
};

service<http:Service> serviceFamousPolitical bind { port: 8081 } {

    getAll(endpoint caller, http:Request req) {
        http:Response res = new;

        try {
            var selectRet = testDB->select("SELECT * FROM type1NewsDb.news;", ());

            //json returnValue;
            match selectRet {
                table tableReturned => {


                    //convert to json
                    var jsonConversionRet = <json>tableReturned;
                    //dt.close();
                    match jsonConversionRet {
                        json jsonRes => {
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
        res.setPayload("hello, this service provide both political and famous news");
        _ = caller -> respond(res);
    }
}