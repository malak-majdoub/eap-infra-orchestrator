const dotenv = require("dotenv");
const express = require("express");
const app = express();

dotenv.config();
const PORT = process.env.PORT;
app.use(express.json());


app.get("/", (req, res) => {
  res.send("Hello from Express server!");
});

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});