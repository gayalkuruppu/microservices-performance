import ballerina/http;
import ballerina/io;

endpoint http:Client clientEP {
    url:"http://localhost:8081",
    proxy: {
        host:"localhost",
        port:9090
    }
};

function main (string... args) {
    http:Request req = new;
    var resp = clientEP->get("/serviceFamousPolitical/getAll");
    match resp {
        error err => io:println(err.message);
        http:Response response => {
            match (response.getJsonPayload()) {
                error payloadError => io:println(payloadError.message);
                json res => io:println(res.toString());
            }
        }
    }
}