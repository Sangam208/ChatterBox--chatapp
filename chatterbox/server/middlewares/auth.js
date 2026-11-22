const jwt = require('jsonwebtoken');

const auth = async (request, response, next) => {
    try {
        const token = request.header("x-auth-token");
        if (!token) return response.status(401).json({ msg: "No auth token, access denied" });
        const jwtSecret = process.env.JWT_SECRET;
        if (!jwtSecret) {
            return response.status(500).json({ error: 'JWT_SECRET is not configured on the server' });
        }
        const verified = jwt.verify(token, jwtSecret);
        if (!verified) return response.status(401).json({ msg: "Token verification failed, authorization denied" });
        request.user = verified.id;
        request.token = token;
        next();
    } catch (_) {
        response.status(401).json({ error: 'Invalid or expired auth token' });
    }
};

module.exports = auth;
