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

// Redis as cache
endpoint redis:Client cache {
    host: "localhost",
    password: "",
    options: { ssl: false }
};

service<http:Service> serviceFamousPolitical bind { port: 8081 } {

    getAll(endpoint caller, http:Request req) {

        http:Response res = new;

        try {
            // First check whether the database response is already cached
            var cachedResponse = cache->get("key1");

            match cachedResponse {
                // If the response is cached set it as the payload
                string result => {
                    //io:println("cache");
                    json parsedJson = internal:parseJson(result) but {
                        error => {}
                    };
                    res.setPayload(parsedJson);
                }

                // If the database response is not cached, query the database, get the result and cache it
                () => {
                    //io:println("not cache");
                    json dbResponse = getNewsFromDatabase();

                    if (!dbResponse.toString().contains("Internal Error")){
                        cacheDBResponse(dbResponse);
                        res.setPayload(untaint dbResponse);
                    }else{
                        res.statusCode = 500;
                        res.setPayload({"Error": "Internal Error"});
                    }
                }
                error => {
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
                        return jsonRes;
                    }
                    error e => {
                        //log:printError(e.message);
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
    } catch (error err) {
        //log:printError(err.message);
    }
}