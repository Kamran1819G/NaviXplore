const express = require("express");

const {
  getStations,
  getLines,
  findNearestStation,
  searchStation,
  upcomingTrains,
  trainSchedule,
} = require("../middlewares/metroMiddlewares");

const router = express.Router();

router.get("/", (req, res) => {
  res.send("Welcome to NM-Metro API");
});

// `/api/nm-metro/stations`
router.get("/stations", getStations, (req, res) => {
  res.json(req.stations);
});

// `/api/nm-metro/stations/nearest?latitude=<LATITUDE>&longitude=<LONGITUDE>`
router.get("/stations/nearest", findNearestStation, (req, res) => {
  res.json(req.nearestStation);
});

// `/api/nm-metro/stations/search?query=<QUERY>`
router.get("/stations/search", searchStation, (req, res) => {
  res.json(req.stations);
});

// `/api/nm-metro/trains/upcoming?lineID=<LINE_ID>&direction=<DIRECTION>&stationID=<STATION_ID>`
router.get("/trains/upcoming", upcomingTrains, (req, res) => {
  res.json(req.upcomingTrains);
});

// `/api/nm-metro/trains/schedule?lineID=<LINE_ID>&direction=<DIRECTION>&trainNo=<TRAIN_NO>`
router.get("/trains/schedule", trainSchedule, (req, res) => {
  res.json(req.trainSchedule);
});

router.get("/lines", getLines, (req, res) => {
  res.json(req.line);
});

module.exports = router;
