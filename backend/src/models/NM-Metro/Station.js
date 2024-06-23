const mongoose = require("mongoose");

const stationSchema = new mongoose.Schema(
  {
    stationID: {
      type: String,
      required: true,
    },
    stationName: {
      English: {
        type: String,
        required: true,
      },
      Marathi: {
        type: String,
        required: true,
      },
    },
    distance: {
      toNextStation: {
        type: Number,
        required: true,
      },
      fromPreviousStation: {
        type: Number,
        required: true,
      },
    },
    location: {
      latitude: {
        type: Number,
        required: true,
      },
      longitude: {
        type: Number,
        required: true,
      },
    },
    facilities: [String],
    lineID: String,
  },
  { collection: "NM-Metro-Stations" }
);

module.exports = mongoose.model("Station", stationSchema);
