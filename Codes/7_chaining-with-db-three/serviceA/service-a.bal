import ballerina/http;
import ballerina/mysql;
import ballerina/log;
import ballerina/io;

endpoint http:Client clientEndpoint {
    url: "http://172.16.53.76:8081/servicePolitical"
};
//url: "http://172.16.53.76:8081/servicePolitical"
//url: "http://localhost:8081/servicePolitical"
endpoint mysql:Client testDB {
    host: "localhost",
    port: 3306,
    name: "type2FamousNewsDb",
    username: "root",
    password: "user",
    poolOptions: { maximumPoolSize: 50 },
    dbOptions: { useSSL: false }
};

service<http:Service> serviceFamous bind { port: 8080 } {

    getAll(endpoint caller, http:Request req) {
        http:Response res = new;

        var responseB = clientEndpoint->get("/getAll");

        try {
            var selectRet = testDB->select("SELECT * FROM type2FamousNewsDb.news;", ());

            var responseSports = clientEndpoint->get("/getAll");
            json news;
            match responseSports {
                http:Response resp => {
                    news = check resp.getJsonPayload();
                }
                error err => {
                    news = {"Error": "Internal Error"};
                }
            }
            //json returnValue;
            match selectRet {
                table tableReturned => {
                    //convert to json
                    var jsonConversionRet = <json>tableReturned;
                    match jsonConversionRet {
                        json jsonRes => {
                            json ans = jsonRes;
                            log:printDebug(jsonRes.toString());
                            if(ans.toString().contains("Internal Error") || news.toString().contains("Internal Error")){
                                res.statusCode = 500;
                                res.setPayload("Internal Error");
                                tableReturned.close();
                            } else {
                                res.setPayload({"FamousNews": untaint jsonRes, "PoliticalNews":untaint news.PoliticalNews, "SportsNews":untaint news.SportsNews});
                                tableReturned.close();
                            }
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
            //log:printError(err.message);
            res.statusCode = 500;
            res.setPayload({"Error": "Internal Error"});
        }
        //log:printInfo(getNewsFromDB.toString());
        _ = caller -> respond(res);
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path:"test"
    }
    testService(endpoint caller, http:Request req) {
        http:Response res = new;
        res.setPayload("hello, this is famous news service");
        _ = caller -> respond(res);
    }
}
