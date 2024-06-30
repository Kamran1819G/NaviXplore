const express = require("express");
const place = require("../models/Places/Place");

const getPlaces = async (req, res, next) => {
  const places = await place.find({});

  req.places = places;

  next();
};

const searchPlaces = async (req, res, next) => {
  const { query } = req.query;

  if (!query) {
    return res.status(400).send("Search query is required");
  }

  const places = await place
    .find({
      $or: [
        { name: new RegExp(query, "i") },
        { description: new RegExp(query, "i") },
      ],
    })
    .limit(10);

  req.places = places;

  next();
};

const filterByTags = async (req, res, next) => {
  const { tags } = req.query;

  if (!tags) {
    return res.status(400).send("Tags are required");
  }

  const tagsArray = tags.split(",");

  const places = await place.find({
    tags: { $in: tagsArray },
  });

  req.places = places;

  next();
};

module.exports = { getPlaces, searchPlaces, filterByTags };
