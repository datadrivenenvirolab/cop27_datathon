# GST Datathon Submission 
## General Prompt - Open Submission Category
## Adam Filipovich - Visualizing Data with dClimate's Upcoming API 

### Youtube demo [here](https://youtu.be/kdMGQyWziVg)

### App available [here](https://datathon-dclimate.herokuapp.com)

## Overview

This project is built on top of dClimate's upcoming API V4. It is a web app which allows a user to access, visualize, and download sliced weather and climate data from several different data sources.

In order to learn more about the technology which makes this possible read [here](https://dclimate.medium.com/introducing-zarrchitecture-on-dclimate-c12c0ad7e744).

In order to learn more about dClimate visit [here](https://www.dclimate.net/). 

In order to use the previous dClimate API visit [here](https://api.dclimate.net/).

In order to request access to the upcoming early access of the API V4 visit [here](https://csti51zef2d.typeform.com/ZarrAPI?typeform-source=dclimate.medium.com).

## Technologies used 

### Data Infrastructure  

This app uses dClimate's API V4 which accesses [Zarr](https://zarr.readthedocs.io/en/stable/) files stored on [IPFS](https://docs.ipfs.tech/concepts/what-is-ipfs/).

### Application 

This app is written in Python using Plotly's Dash library. A Celery worker, alongside a Redis backend, is used to queue and handle requests, allowing for longer queries to be made.
