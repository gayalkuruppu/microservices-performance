import ballerina/http;
import ballerina/mysql;
import ballerina/log;

endpoint mysql:Client testDB {
    host: "localhost",
    port: 3306,
    name: "type1SportsNewsDb",
    username: "root",
    password: "user",
    poolOptions: { maximumPoolSize: 100 },
    dbOptions: { useSSL: false }
};

service<http:Service> serviceB bind { port: 8081 } {

    getAll(endpoint caller, http:Request req) {
        http:Response res = new;
        var selectRet = testDB->select("SELECT * FROM type1SportsNewsDb.news;", ());
        table dt;
        match selectRet {
            table tableReturned => {
                dt = tableReturned;

                //convert to json
                var jsonConversionRet = <json>dt;
                match jsonConversionRet {
                    json jsonRes => {
                        res.setPayload(untaint jsonRes);
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
