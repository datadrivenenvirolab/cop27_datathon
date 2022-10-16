const mongoose = require("mongoose");

const SourceSchema = new mongoose.Schema({
    title: {
        type: String,
        // required: true,
    },
    url: {
        type: String,
        // required: true,
    },
    status: {
        type: String,
        required: false,
    },
    description: {
        type: String,
        // required: true,
    },
    topic: {
        type: mongoose.Mixed,
        // required: true,
    },
    vistype: {
        type: mongoose.Mixed,
        // required: true,
    },
    scale: {
        type: mongoose.Mixed,
        // required: true,
    },
    audience: {
        type: mongoose.Mixed,
        // required: true,
    },
    geographies: {
        type: mongoose.Mixed,
        // required: true,
    },
    organizations: {
        type: String,
        // required: true,
    },
    year: {
        type: String,
        required: false,
    },
    submitterName: {
        type: String,
        // required: true,
    },
    submitterEmail: {
        type: String,
        // required: true,
    },
    dateUploaded: {
        type: Date,
        default: Date.now,
    },
})
module.exports = mongoose.model("Source", SourceSchema);