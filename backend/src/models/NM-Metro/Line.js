const mongoose = require("mongoose");

const lineSchema = new mongoose.Schema(
  {
    name: String,
    stations: [String],
    lineID: String,
    length: String,
    depot: String,
    type: String,
    polylines: [
      {
        latitude: Number,
        longitude: Number,
        altitude: Number,
      },
    ],
  },
  { collection: "NM-Metro-Lines" }
);

module.exports = mongoose.model("Line", lineSchema);
