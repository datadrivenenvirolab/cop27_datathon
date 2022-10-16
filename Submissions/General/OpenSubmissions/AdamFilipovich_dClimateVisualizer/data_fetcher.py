import requests
import xarray as xr
import os 

#get api access information
ADDRESS = os.environ.get('ADDRESS')
AUTH = os.environ.get('AUTH')

#fetch data for circular query
def get_data(lat, long, radius, start, end, dataset):
    r = requests.post(
            f"http://{ADDRESS}/geo_temporal_query/{dataset}?output_format=netcdf",
            json={"circle_params": {"radius": radius, "center_lat": lat, "center_lon": long}, "time_range" : [start, end]},
            auth=("basic_auth", AUTH)
        )

    #sloppy fix for when an error occurs, doesnt currently have error handling
    if r.text[0] == '<':
        return [None, None, None, None, "There was an error processing your request. This may happen when you select no data (too small of a radius) or too much data (too large of a radius/timeframe)."]

    ds = xr.open_dataset(r.content)

    df = ds.to_dataframe()
    #flatten columns for now
    df.reset_index(inplace=True)
    df = df.dropna()
    var = df.columns.values[3]

    data = df
    df2 = df

    latlongs = [] 

    for index, row in df.iterrows():
        if [row['latitude'], row['longitude']] in latlongs:
            pass 
        else: 
            latlongs.append([row['latitude'], row['longitude']])


    frame_dict = {}

    for latlong in latlongs:
        df = data[data.latitude == latlong[0]]
        df = df[df.longitude == latlong[1]]
        frame_dict[str(latlong)] = df 

    df = data.drop(['latitude', 'longitude'], axis=1)
    df = df.set_index('time')

    df = df.groupby(level=0)

    avg = df.agg({var:'mean'})
    avg['time'] = avg.index


    return [df2, avg, latlongs, var, None]


#function to get metadata
def metadata(dataset):
    r = requests.get(
        f"http://{ADDRESS}/metadata/{dataset}",
        auth=("basic_auth", AUTH)
    )
    metadata = r.json()

    daterange = metadata['properties']['date range']

    formatted = [f"{daterange[0][0:4]}-{daterange[0][4:6]}-{daterange[0][6:8]}", f"{daterange[0][0:4]}-{daterange[0][4:6]}-{daterange[0][6:8]}", f"{daterange[1][0:4]}-{daterange[1][4:6]}-{daterange[1][6:8]}", metadata['properties']['dataset description']]

    return formatted
