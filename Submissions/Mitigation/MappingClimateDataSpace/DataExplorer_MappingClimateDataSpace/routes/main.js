const express = require("express");
const router = express.Router();

const homeController = require("../controllers/home");
const dataController = require("../controllers/data");

//Main Routes - simplified for now
router.get("/", homeController.getIndex);
router.get("/add-data", dataController.getAddData); 
router.get("/data", dataController.getData);


module.exports = router;