const { client, databaseQueryHandler } = require("./config/config");

const express = require("express");
const cors = require("cors");

const app = express();

app.use(cors());
app.use(express.json());


const main = async() => {


   console.log("i am here ...");
   const srcDep = 500;
   const destDep = 518;
   const amount = 10000;
   const transferDate = '2020-03-25';
   const transferTime = '01:13:00';
   // const body = req.body;
  const transactions =  await databaseQueryHandler(
   `SELECT * FROM TrackRelatedTransactions (${srcDep} , ${destDep} , ${amount} , '${transferDate}' , '${transferTime}');`
  );
console.log(transactions);
// "SELECT * FROM followRelatedTransaction(500 , 501 , 100000 , '2020-03-25' , '09:00:00' , 0 , 0)"
// res.contentType("application/json");
// res.json(transactions);
}


main();
