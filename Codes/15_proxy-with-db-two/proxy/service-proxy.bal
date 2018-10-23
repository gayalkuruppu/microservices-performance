import ballerina/http;
import ballerina/log;
import ballerina/io;
import ballerina/internal;


endpoint http:Listener proxy{
    port:9090
};
@http:ServiceConfig {
    basePath: "/*"
}
service<http:Service> serviceProxy bind proxy {
    @http:ResourceConfig {
        path: "/*"
    }
    proxyMethod (endpoint conn, http:Request req){
        string url = untaint req.rawPath;
        sendRequest(url, req, conn);
    }
}

function defineEndpointWithProxy (string url) returns http:Client {
    endpoint http:Client httpEndpoint {
        url: url
    };
    return httpEndpoint;
}

function sendRequest(string url, http:Request req, http:Listener conn) {
    endpoint http:Client clientEP = defineEndpointWithProxy(url);
    endpoint http:Listener listenerEP = conn;
    var response = clientEP->forward("", req);
    match response {
        http:Response httpResponse => {
            _ = listenerEP->respond(httpResponse);
        }
        http:error err => {
            http:Response errorResponse = new;
            errorResponse.setTextPayload(err.message);
            _ = listenerEP->respond(errorResponse);
        }
    }
}