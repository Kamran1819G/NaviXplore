const express = require("express");
const metroMiddlewares = require("../middlewares/metroMiddlewares");

const router = express.Router();

router.get("/", (req, res) => {
  res.send("Welcome to NM-Metro API");
});

// `/api/nm-metro/stations`
router.get("/stations", metroMiddlewares.getStations, (req, res) => {
  res.json(req.stations);
});

// `/api/nm-metro/stations/nearest?latitude=<LATITUDE>&longitude=<LONGITUDE>`
router.get(
  "/stations/nearest",
  metroMiddlewares.findNearestStation,
  (req, res) => {
    res.json(req.nearestStation);
  }
);

// `/api/nm-metro/stations/search?query=<QUERY>`
router.get("/stations/search", metroMiddlewares.searchStation, (req, res) => {
  res.json(req.stations);
});

// `/api/nm-metro/trains/upcoming?lineID=<LINE_ID>&direction=<DIRECTION>&stationID=<STATION_ID>`
router.get("/trains/upcoming", metroMiddlewares.upcomingTrains, (req, res) => {
  res.json(req.upcomingTrains);
});

// `/api/nm-metro/trains/schedule?lineID=<LINE_ID>&direction=<DIRECTION>&trainNo=<TRAIN_NO>`
router.get("/trains/schedule", metroMiddlewares.trainSchedule, (req, res) => {
  res.json(req.trainSchedule);
});

router.get("/lines", metroMiddlewares.getLines, (req, res) => {
  res.json(req.line);
});

module.exports = router;
