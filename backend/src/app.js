require("dotenv").config();
const express = require("express");
const mongoose = require("mongoose");
const api = require("./routes/api");

const app = express();
const mongoURI =
  process.env.MONGODB_URI || "mongodb://localhost:27017/NaviXplore";
const port = process.env.PORT || 3000;

// Middleware to parse JSON
app.use(express.json());

// Connect to MongoDB
mongoose
  .connect(mongoURI)
  .then(() => console.log("MongoDB connected"))
  .catch((err) => {
    console.error("MongoDB connection error:", err);
    process.exit(1);
  });

// Use routes
app.get("/", (req, res) => {
  res.send("Welcome to NaviXplore API");
});

app.use("/api", api);

// Start server
app.listen(port, () => {
  console.log("Server started on port 3000");
});
