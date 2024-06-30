const express = require("express");
const metroRoutes = require("./metroRoutes");
const placesRoutes = require("./placesRoutes");

const router = express.Router();

router.use("/nm-metro", metroRoutes);
router.use("/places", placesRoutes);

module.exports = router;
