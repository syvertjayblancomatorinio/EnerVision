const jwt = require("jsonwebtoken");
const config = require("./config");

let checkToken = (req, res, next) => {
  let token = req.headers["authorization"];
  console.log(token);

  // Ensure the token is present and remove "Bearer " prefix if it exists
  if (token) {
    token = token.startsWith("Bearer ") ? token.slice(7, token.length) : token;

    jwt.verify(token, config.key, (err, decoded) => {
      if (err) {
        return res.json({
          status: false,
          msg: "Token is invalid",
        });
      } else {
        req.decoded = decoded; // Attach decoded token data to the request
        next(); // Proceed to the next middleware or route handler
      }
    });
  } else {
    return res.json({
      status: false,
      msg: "Token is not provided",
    });
  }
};

module.exports = {
  checkToken: checkToken,
};
