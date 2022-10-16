# Climate Data Explorer
![Climate Data Explorer cover image](https://github.com/wo1vin/climatedataexplorer/blob/main/public/assets/cover.png?raw=true)

# Introduction
The Paris Climate Agreement included guidelines to “take stock” of the world’s progress towards the climate goals set forth by the Agreement (Page 20, Article 14). The agreement states that the first global stocktake (GST) will be in 2023. The GST gave way to the COP27 Global Stocktake Climate Datathon, which launched on September 21st, and closes on October 15th.

Organized by the Open Earth Foundation, Data-Driven Enviro Lab 2.0, and Climate Action Data 2.0, the datathon fosters innovation, collaboration, and the creation of data visualization tools to aid in the analysis of climate data for the 2023 GST. With the opportunity provided by the event, a small, global team of passionate climate activists is working to tackle the prompt to “Map the Climate Data Platform Space.” This work in progress is the result of that collaborative effort. 

---

# Objective
The Climate Data Explorer seeks to identify and bring together important data from sources including and beyond national statistics to enable decision makers, climate experts, businesses, and citizens to address all aspects of the climate crisis.

---

# Who is this for?
The platform is open to anyone with an interest in current climate data, or in tackling the climate crisis. 

---

# View of the App
![Climate Data Explorer cover image](https://github.com/wo1vin/cop27_datathon/blob/dc6225fa18dd577a296167d7201ba8ca8d99ade6/Submissions/Mitigation/MappingClimateDataSpace/DataExplorer_MappingClimateDataSpace/public/assets/WebApp-Sample1.png?raw=true)
![Climate Data Explorer cover image](https://github.com/wo1vin/cop27_datathon/blob/dc6225fa18dd577a296167d7201ba8ca8d99ade6/Submissions/Mitigation/MappingClimateDataSpace/DataExplorer_MappingClimateDataSpace/public/assets/WebApp-Sample2.png?raw=true)
![Climate Data Explorer cover image](https://github.com/wo1vin/cop27_datathon/blob/dc6225fa18dd577a296167d7201ba8ca8d99ade6/Submissions/Mitigation/MappingClimateDataSpace/DataExplorer_MappingClimateDataSpace/public/assets/WebApp-Sample3.png?raw=true)

___


# Packages/Dependencies
- Dotenv
- Express
- Ejs
- Method-override
- MongoDB
- Mongoose
- Morgan
- Nodemon

---

# Devs 
- Have Node installed
- Fork this repo
- Clone it to your local machine
- Edit the .env file with the following variables:
    - `DB_STRING =` set the value to your own MongoDB Connection String with the user and password fields replaced, or contact me for edit access to the database used in this web app.
    - `PORT = 3000` (value doesn't matter)
- On the terminal in the folder with the project, run `npm install`
- After install, type either `npm run start` or `node server` to start the app
- If no errors were logged, you can open a browser tab and go to `http://localhost:3000/` to view the project.
- If you plan to publish the code remember to add the .env file to .gitignore

Happy Coding!
