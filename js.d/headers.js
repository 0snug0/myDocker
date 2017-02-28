function summary(req, res) {
    res.headers.test = 'something';
    var a, s, reqh, resh;
    s += "Method: " + req.method + "\n";
    s += "HTTP version: " + req.httpVersion + "\n";
    s += "Remote Address: " + req.remoteAddress + "\n";
    s += "URI: " + req.uri + "\n";

    s += "Request Headers:\n";
    for (reqh in req.headers) {
        s += "\t" + reqh + ": "  + req.headers[reqh] + "\n";
    }

    s += "Response Headers:\n";
    for (resh in res.headers) {
        s += "\t" + resh + ": "  + req.headers[resh] + "\n";
    }

    s += "Args:\n";
    for (a in req.args) {
        s += "  arg '" + a + "' is '" + req.args[a] + "\n";
    }

    return s;
}