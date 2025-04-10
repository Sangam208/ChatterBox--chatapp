const jwt = require('jsonwebtoken');

const auth = async (request, response, next) => {
    try {
        const token = request.header("x-auth-token");
        if (!token) return response.status(401).json({ msg: "No auth token, access denied" });
        const verified = jwt.verify(token, "passKey");
        if (!verified) return response.status(401).json({ msg: "Token verification failed, authorization denied" });
        request.user = verified.id;
        request.token = token;
        next();
    } catch (e) {
        response.status(500).json({ error: e.message });
    }
};

module.exports = auth;