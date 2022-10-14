const express = require("express");
const router = express.Router();
const dataController = require("../controllers/data");

//Data Routes - simplified for now
//the param should probably be different than :id
// topic clicked?
// router.get("/:id", dataController.getData); 


router.post("/createData", dataController.createData);

module.exports = router;