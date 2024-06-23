const express = require("express");
const metroRoutes = require("./metroRoutes");

const router = express.Router();

router.use("/nm-metro", metroRoutes);

module.exports = router;
