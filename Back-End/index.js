const { client, databaseQueryHandler } = require("./config/config");

const express = require("express");
const cors = require("cors");

const app = express();

app.use(cors());
app.use(express.json());

app.listen(4000, "0.0.0.0" ,  () => {
   console.log("app starts listening ... ");
});

app.post("/transactions", async (req, res) => {
   console.log("i am here ...");
   const body = req.body;
   const transactions = await databaseQueryHandler(
      `SELECT * FROM TrackRelatedTransactions (${body.srcDep}, ${body.destDep}, ${body.amount}, '${body.transferDate}' , '${body.transferTime}');`
   );
   console.log(transactions);
   // "SELECT * FROM followRelatedTransaction(500 , 501 , 100000 , '2020-03-25' , '09:00:00' , 0 , 0)"
   // res.contentType("application/json");
   res.json(transactions);
});
