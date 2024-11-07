const jwt = require('jsonwebtoken');
const jwtSecret = process.env.JWT_SECRET || "4715aed3c946f7b0a38e6b534a9583628d84e96d10fbc04700770d572af3dce43625dd";

function authenticateToken(req, res, next) {
    const token = req.cookies.token;
    if (!token) {
        return res.redirect('/login');
    }

    try {
        const decoded = jwt.verify(token, jwtSecret);
        req.admin = decoded.admin;
        next();
    } catch (error) {
        return res.redirect('/login');
    }
}

module.exports = authenticateToken;
//const jwt = require("jsonwebtoken");
//const config = require("./config");
//
//let checkToken = (req, res, next) => {
//  let token = req.headers["authorization"];
//  console.log(token);
//
//  // Ensure the token is present and remove "Bearer " prefix if it exists
//  if (token) {
//    token = token.startsWith("Bearer ") ? token.slice(7, token.length) : token;
//
//    jwt.verify(token, config.key, (err, decoded) => {
//      if (err) {
//        return res.json({
//          status: false,
//          msg: "Token is invalid",
//        });
//      } else {
//        req.decoded = decoded; // Attach decoded token data to the request
//        next(); // Proceed to the next middleware or route handler
//      }
//    });
//  } else {
//    return res.json({
//      status: false,
//      msg: "Token is not provided",
//    });
//  }
//};
//
//const authenticateToken = (req, res, next) => {
//  const token = req.headers['authorization']?.split(' ')[1]; // Extract the token from Bearer token
//
//  if (!token) {
//    return res.status(401).json({ message: "Access token is required" });
//  }
//
//  jwt.verify(token, 'your_jwt_secret', (err, decoded) => {
//    if (err) {
//      return res.status(403).json({ message: "Invalid or expired token" });
//    }
//    req.decoded = decoded; // Attach the decoded information to the request
//    next(); // Proceed to the next middleware or route handler
//  });
//};
//
//
//module.exports = {
//  checkToken: checkToken,
//};
