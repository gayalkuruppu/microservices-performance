import ballerina/http;
import ballerina/mysql;
import ballerina/log;
import ballerina/io;

endpoint http:Client clientEndpoint {
    url: "http://172.16.53.70:8082/serviceSports"
	//url: "http://localhost:8082/serviceSports"
};

endpoint mysql:Client testDB {
    host: "localhost",
    port: 3306,
    name: "type2PoliticalNewsDb",
    username: "root",
    password: "user",
    poolOptions: { maximumPoolSize: 50 },
    dbOptions: { useSSL: false }
};

service<http:Service> servicePolitical bind { port: 8081 } {

    getAll(endpoint caller, http:Request req) {
        http:Response res = new;

        var responseB = clientEndpoint->get("/getAll");

        try {
            var selectRet = testDB->select("SELECT * FROM type2PoliticalNewsDb.news;", ());

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
            //json returnValue;
            match selectRet {
                table tableReturned => {
                    //convert to json
                    var jsonConversionRet = <json>tableReturned;
                    match jsonConversionRet {
                        json jsonRes => {
                            if(jsonRes.toString().contains("Internal Error") || sportsNews.toString().contains("Internal Error")){
                                res.statusCode = 500;
                                res.setPayload("Internal Error");
                            } else {
                                res.setPayload({"PoliticalNews":untaint ans, "SportsNews":untaint sportsNews});
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
        res.setPayload("hello, this is political news service");
        _ = caller -> respond(res);
    }
}
