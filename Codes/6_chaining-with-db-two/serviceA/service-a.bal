import ballerina/http;
import ballerina/mysql;
import ballerina/log;
import ballerina/io;

endpoint http:Client clientEndpoint {
    url: "http://172.16.53.70:8081/serviceSports"
};
//url: "http://172.16.53.70:8081/serviceSports"
endpoint mysql:Client testDB {
    host: "localhost",
    port: 3306,
    name: "type1NewsDb",
    username: "root",
    password: "user",
    poolOptions: { maximumPoolSize: 50 },
    dbOptions: { useSSL: false }
};

service<http:Service> serviceFamousPolitical bind { port: 8080 } {

    getAll(endpoint caller, http:Request req) {
        http:Response res = new;
        var responseSports = clientEndpoint->get("/getAll");
        json sportsNews;
        match responseSports {
            http:Response resp => {
                sportsNews = check resp.getJsonPayload();
            }
            error err => {
                sportsNews = {"Error": "Internal Error"};
            }
        }

        try {
            var selectRet = testDB->select("SELECT * FROM type1NewsDb.news;", ());
            //table dt;
            //json returnValue;
            match selectRet {
                table tableReturned => {
                    //convert to json
                    var jsonConversionRet = <json>tableReturned;
                    match jsonConversionRet {
                        json jsonRes => {
                            json ans = jsonRes;
                            log:printDebug(jsonRes.toString());
                            if(ans.toString().contains("Internal Error") || sportsNews.toString().contains("Internal Error")){
                                res.statusCode = 500;
                                res.setPayload("Internal Error");
                                tableReturned.close();
                            } else {
                                res.setPayload({"PoliticalFamousNews":untaint ans, "SportsNews":untaint sportsNews});
                                tableReturned.close();
                            }
                        }
                        error e => {
                            //log:printError(e.message);
                            tableReturned.close();
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
        res.setPayload("hello, this service provide both political and famous news");
        _ = caller -> respond(res);
    }
}
