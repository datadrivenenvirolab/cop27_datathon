const Source = require("../models/Source");

module.exports = {
    getData: async (req, res) => {
      try {
        const sources = await Source.find().lean();
        res.render("data.ejs", { sources: sources });
      } catch (err) {
        console.log(err);
      }
    },
    getAddData: async (req, res) => {
      await res.render("add-data.ejs");
    },
    createData: async (req, res) => {
      console.log(req.body)

      try {
        await Source.create({
          title: req.body.title,
          url: req.body.url,
          status: req.body.status,
          description: req.body.description,
          topic: req.body.topic,
          visType: req.body.visType,
          scale: req.body.scale,
          audience: req.body.audience,
          geographies: req.body.geographies,
          year: req.body.year,
          submitterName: req.body.submitterName,
          submitterEmail: req.body.submitterEmail,
        });
        console.log(req.body)
        console.log("Data source has been added!");
        res.redirect("/");
      } catch (err) {
        console.log("Failed to add Data");
        console.log(req.body)

        console.log(err);
      }
    }
};  