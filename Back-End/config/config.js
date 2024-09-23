const { Client } = require("pg");

const client = new Client({
   host: "postgres",
   database: "bank",
   port: 5432,
   user: "mahdi",
   password: "1234",
});

client.connect();
const databaseQueryHandler = async (queryString) => {
   const relation = await client.query(queryString);
   // catch((err) => console.log(err));
   // client.end();
   return relation.rows;
};

module.exports = { client, databaseQueryHandler };
