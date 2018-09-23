import ballerina/http;
import ballerina/mysql;
import ballerina/log;
import ballerina/io;
import ballerina/internal;
import wso2/redis;

endpoint http:Client clientEndpoint {
    url: "http://172.16.53.70:8081/serviceSports"
};
//url: "http://172.16.53.70:8081/serviceSports"
//url: "http://localhost:8081/serviceSports"

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

// Redis as cache
endpoint redis:Client cache {
    host: "localhost",
    password: "",
    options: { ssl: false }
};

service<http:Service> serviceFamousPolitical bind { port: 8080 } {
    getAll(endpoint caller, http:Request req) {
        http:Response res = new;

        //getting the sports news from the sportsNews microservice
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
            // First check whether the database response is already cached
            var cachedResponse = cache->get("key1");

            match cachedResponse {
                // If the response is cached set it as the payload
                string result => {

                    json parsedJson = internal:parseJson(result) but {
                        error => {}
                    };

                    if(sportsNews.toString().contains("Internal Error")){
                        res.statusCode = 500;
                        res.setPayload({"Error": "Internal Error"});

                    } else {
                        res.setPayload({"PoliticalFamousNews": parsedJson, "SportsNews":untaint sportsNews});
                    }
                 }
                // If the database response is not cached, query the database, get the result and cache it
                () => {

                    json dbResponse = getNewsFromDatabase();
                    if(!dbResponse.toString().contains("Internal Error")){
                        cacheDBResponse(dbResponse);
                    }
                    if(dbResponse.toString().contains("Internal Error") || sportsNews.toString().contains("Internal Error")){
                        res.statusCode = 500;
                        res.setPayload({"Error": "Internal Error"});
                    } else {
                        res.setPayload({"PoliticalFamousNews":untaint dbResponse, "SportsNews":untaint sportsNews});
                    }
                }
                error => {
                    res.statusCode = 500;
                    res.setPayload({"Error": "Internal Error"});
                }
            }
        } catch (error err) {
            //log:printError(err.message);
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

function getNewsFromDatabase() returns json{
    try{
        var selectRet = testDB->select("SELECT * FROM type1NewsDb.news;", ());

        //json returnValue;
        match selectRet {
            table tableReturned => {

            //convert to json
                var jsonConversionRet = <json>tableReturned;
                match jsonConversionRet {
                    json jsonRes => {
                        log:printDebug(jsonRes.toString());
                        tableReturned.close();
                        return jsonRes;
                    }
                    error e => {
                        //log:printError(e.message);
                        tableReturned.close();
                        return {"Error": "Internal Error"};
                    }
                }
            }
            error e => {
                //log:printError(e.message);
                return {"Error": "Internal Error"};
            }
        }
    } catch (error err) {
        //log:printError(err.message);
        return {"Error": "Internal Error"};
    }
}

function cacheDBResponse(json dbResp) {
    try {
        // Cache the response
        json cacheVal = { cacheValue: dbResp};
        _ = cache->setVal("key1", dbResp.toString());
        // Set an expiry time for the cache
        _ = cache->pExpire("key1", 60000);
    }catch (error err) {
        //log:printError(err.message);
    }
}