const path = require('path');
const dotenv = require('dotenv').config({ path: "./config/.env" });

const { MongoClient, ServerApiVersion } = require('mongodb');
const mongoose = require("mongoose");
const express = require('express');
const app = express();
const methodOverride = require("method-override");
const logger = require("morgan");
const mainRoutes = require("./routes/main");
const dataRoutes = require("./routes/data");
// const commentRoutes = require("./routes/comments");

//Using EJS for views
app.set('view engine', 'ejs')
//Static Folder
app.use(express.static('public'))
// app.use('/static', express.static('public'))
//Body Parsing
app.use(express.urlencoded({ extended: true }))
app.use(express.json())
//Logging
app.use(logger("dev"));
//Use forms for put / delete
app.use(methodOverride("_method"));

//Setup Routes For Which The Server Is Listening
app.use("/", mainRoutes);
app.use("/data", dataRoutes);
// app.use("/feedback", mainRoutes);


// Connect to Database
const connectDB = async () => {
    try {
    const conn = await mongoose.connect(process.env.DB_STRING, { 
        useUnifiedTopology: true
    })
    console.log(`MongoDB Connected: ${conn.connection.host}`);
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
};


connectDB();
// Run Server 
app.listen(process.env.PORT, () => {
    console.log("Server is running, you better catch it!");
});