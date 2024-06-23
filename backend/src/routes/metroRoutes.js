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

// `/api/nm-metro/get-stations`
router.get("/get-stations", getStations, (req, res) => {
  res.json(req.stations);
});

// `/api/nm-metro/get-nearest-station?latitude=<LATITUDE>&longitude=<LONGITUDE>`
router.get("/get-nearest-station", findNearestStation, (req, res) => {
  res.json(req.nearestStation);
});

// `/api/nm-metro/search-station?query=<QUERY>`
router.get("/search-station", searchStation, (req, res) => {
  res.json(req.stations);
});

// `/api/nm-metro/get-upcoming-trains?lineID=<LINE_ID>&direction=<DIRECTION>&stationID=<STATION_ID>`
router.get("/get-upcoming-trains", upcomingTrains, (req, res) => {
  const { upcomingTrains } = req;
  res.json(upcomingTrains);
});

// `/api/nm-metro/get-metro-schedule?lineID=<LINE_ID>&direction=<DIRECTION>&trainNo=<TRAIN_NO>`
router.get("/get-metro-schedule", trainSchedule, (req, res) => {
  res.json(req.trainSchedule);
});

router.get("/lines", getLines, (req, res) => {
  res.json(req.line);
});

module.exports = router;
