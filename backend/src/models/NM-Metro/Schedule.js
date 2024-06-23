const mongoose = require("mongoose");
const Schema = mongoose.Schema;

const ScheduleSchema = new Schema(
  {
    lineID: {
      type: String,
      required: true,
    },
    trainName: {
      type: String,
      required: true,
    },
    direction: {
      type: String,
      required: true,
    },
    schedules: [
      {
        stationID: {
          type: String,
          required: true,
        },
        time: {
          type: [String],
          required: true,
        },
      },
    ],
  },
  { collection: "NM-Metro-Schedules" }
);

module.exports = mongoose.model("Schedule", ScheduleSchema);
