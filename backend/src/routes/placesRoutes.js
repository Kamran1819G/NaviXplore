const express = require("express");
const placesMiddlewares = require("../middlewares/placesMiddlewares");

const router = express.Router();

router.get("/", placesMiddlewares.getPlaces, (req, res) => {
  res.json(req.places);
});

router.get("/search", placesMiddlewares.searchPlaces, (req, res) => {
  res.json(req.places);
});

router.get("/filter", placesMiddlewares.filterByTags, (req, res) => {
  res.json(req.places);
});

module.exports = router;
