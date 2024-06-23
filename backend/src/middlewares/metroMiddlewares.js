const Station = require("../models/NM-Metro/Station");
const Line = require("../models/NM-Metro/Line");
const Schedule = require("../models/NM-Metro/Schedule");
const NodeCache = require("node-cache");

const cache = new NodeCache({ stdTTL: 3600 });

/**
 * Converts degrees to radians.
 *
 * @param {number} deg - The angle in degrees to be converted.
 * @return {number} The angle in radians.
 */
function deg2rad(deg) {
  return deg * (Math.PI / 180);
}

/**
 * Calculates the distance between two geographical coordinates using the Haversine formula.
 *
 * @param {number} lat1 - The latitude of the first point.
 * @param {number} lon1 - The longitude of the first point.
 * @param {number} lat2 - The latitude of the second point.
 * @param {number} lon2 - The longitude of the second point.
 * @return {number} The distance between the two points in kilometers.
 */
function getDistance(lat1, lon1, lat2, lon2) {
  const R = 6371; // Radius of the earth in km
  const dLat = deg2rad(lat2 - lat1);
  const dLon = deg2rad(lon2 - lon1);
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(deg2rad(lat1)) *
      Math.cos(deg2rad(lat2)) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c; // Distance in km
}

/**
 * Retrieves the stations from the cache if available, otherwise fetches them from the database and stores them in the cache.
 *
 * @param {Object} req - The request object.
 * @param {Object} res - The response object.
 * @param {Function} next - The next function in the middleware chain.
 * @return {Promise<void>} - A promise that resolves when the stations are retrieved or fetched.
 */
const getStations = async (req, res, next) => {
  const cachedStations = cache.get("stations");

  if (cachedStations) {
    req.stations = cachedStations;
    return next();
  }

  try {
    const stations = await Station.find();

    const formattedStations = stations.map((station) => ({
      stationID: station.stationID,
      stationName: {
        English: station.stationName.English,
        Marathi: station.stationName.Marathi,
      },
      location: {
        latitude: station.location.latitude,
        longitude: station.location.longitude,
      },
      distance: {
        toNextStation: station.distance.toNextStation,
        fromPreviousStation: station.distance.fromPreviousStation,
      },
      facilities: station.facilities,
      lineID: station.lineID,
    }));

    cache.set("stations", formattedStations);
    req.stations = formattedStations;
    next();
  } catch (error) {
    next(error);
  }
};

/**
 * Finds the nearest station based on the latitude and longitude provided in the request query.
 *
 * @param {Object} req - The request object.
 * @param {Object} res - The response object.
 * @param {Function} next - The next function in the middleware chain.
 */
const findNearestStation = async (req, res, next) => {
  const { latitude, longitude } = req.query;

  if (!latitude || !longitude) {
    return res.status(400).send("Latitude and longitude are required");
  }

  const stations = await Station.find();
  let nearestStation = null;
  let minDistance = Infinity;

  stations.forEach((station) => {
    const distance = getDistance(
      latitude,
      longitude,
      station.location.latitude,
      station.location.longitude
    );
    if (distance < minDistance) {
      minDistance = distance;
      nearestStation = {
        stationID: station.stationID,
        lineID: station.lineID,
        stationName: {
          English: station.stationName.English,
          Marathi: station.stationName.Marathi,
        },
        location: {
          latitude: station.location.latitude,
          longitude: station.location.longitude,
        },
        distance: distance.toFixed(2),
      };
    }
  });

  req.nearestStation = nearestStation;
  next();
};

/**
 * Searches for stations based on the provided query.
 *
 * @param {Object} req - The request object.
 * @param {Object} res - The response object.
 * @param {Function} next - The next function in the middleware chain.
 * @return {Promise<void>} - A promise that resolves when the search is complete.
 */
const searchStation = async (req, res, next) => {
  const { query } = req.query;

  if (!query) {
    return res.status(400).send("Search query is required");
  }

  let stations = await Station.find({
    $or: [
      { "stationName.English": new RegExp(query, "i") },
      { "stationName.Marathi": new RegExp(query, "i") },
    ],
  });

  stations = stations.map((station) => ({
    stationID: station.stationID,
    stationName: {
      English: station.stationName.English,
      Marathi: station.stationName.Marathi,
    },
    location: {
      latitude: station.location.latitude,
      longitude: station.location.longitude,
    },
  }));

  req.stations = stations;
  next();
};

/**
 * Middleware to find upcoming train schedules for a specific station and direction.
 *
 * @param {Object} req - The request object containing query parameters (lineID, direction, stationID).
 * @param {Object} res - The response object.
 * @param {Function} next - The next function in the middleware chain.
 * @return {Promise<void>} - A promise that resolves when schedules are found.
 */
const upcomingTrains = async (req, res, next) => {
  const { lineID, direction, stationID } = req.query;

  if (!lineID || !direction || !stationID) {
    return res
      .status(400)
      .send("lineID, direction, and stationID are required");
  }

  try {
    const schedule = await Schedule.findOne({
      lineID,
      direction,
      "schedules.stationID": stationID,
    });

    if (!schedule) {
      return res
        .status(404)
        .send(
          `No schedules found for line ${lineID}, direction ${direction}, and station ${stationID}`
        );
    }

    const stationSchedule = schedule.schedules.find(
      (s) => s.stationID === stationID
    );

    req.upcomingTrains = {
      lineID: schedule.lineID,
      trainName: schedule.trainName,
      stationID: stationSchedule.stationID,
      upcomingTimes: stationSchedule.time,
    };

    next();
  } catch (error) {
    console.error("Error fetching schedules:", error);
    res.status(500).send("Error fetching schedules");
  }
};

/**
 * Retrieves the train schedule for a given line, direction, and train number.
 *
 * @param {Object} req - The request object containing query parameters (lineID, direction, trainNo).
 * @param {Object} res - The response object.
 * @param {Function} next - The next function in the middleware chain.
 * @return {Promise<void>} - A promise that resolves when the train schedule is retrieved.
 * @throws {Error} - If any of the required query parameters are missing.
 * @throws {Error} - If the schedule data is not found for the given lineID and direction.
 * @throws {Error} - If the trainNo is invalid.
 * @throws {Error} - If an error occurs during the retrieval process.
 */
const trainSchedule = async (req, res, next) => {
  const { lineID, direction, trainNo } = req.query;

  if (!lineID || !direction || !trainNo) {
    return res
      .status(400)
      .send("Missing required query parameters: lineID, direction, trainNo");
  }

  try {
    // Find schedule data based on lineID and direction
    const scheduleData = await Schedule.findOne({ lineID, direction });

    if (!scheduleData) {
      return res
        .status(404)
        .send("Schedule not found for the given lineID and direction");
    }

    const trainSchedule = scheduleData.schedules.map((station) => {
      const trainTime = station.time[trainNo];
      if (!trainTime) {
        throw new Error("Invalid trainNo");
      }
      return {
        stationID: station.stationID,
        time: trainTime,
      };
    });

    req.trainSchedule = {
      lineID: scheduleData.lineID,
      direction: scheduleData.direction,
      trainName: scheduleData.trainName,
      trainSchedule: trainSchedule,
    };
    next();
  } catch (error) {
    return res.status(500).send(error.message);
  }
};

const getLines = async (req, res, next) => {
  const { lineID } = req.query;

  const line = await Line.findOne({ lineID });

  if (!line) {
    return res.status(404).send("Line not found");
  }

  req.line = line;
  next();
};

module.exports = {
  getStations,
  getLines,
  findNearestStation,
  searchStation,
  upcomingTrains,
  trainSchedule,
};
