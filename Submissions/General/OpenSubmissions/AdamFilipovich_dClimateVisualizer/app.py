from dash.dependencies import Input, Output, State
import plotly.express as px
from dash import Dash, html, dcc, dash_table, ctx
import dash_leaflet as dl
from datetime import date
from data_fetcher import get_data, metadata
from dash_extensions.javascript import assign
from celery import Celery 
from dash.long_callback import CeleryLongCallbackManager
import dash_bootstrap_components as dbc
import os

theme = [dbc.themes.SIMPLEX] 

# defining how to render geojson.
point_to_layer = assign("""function(feature, latlng, context){
    const p = feature.properties;
    if(p.type === 'circlemarker'){return L.circleMarker(latlng, radius=p._radius)}
    if(p.type === 'circle'){return L.circle(latlng, radius=p._mRadius)}
    return L.marker(latlng);
}""")

celery_app = Celery(
    __name__, 
    broker=os.environ['REDIS_URL'], backend=os.environ['REDIS_URL'],
    #uncomment line below to run on local machine 
    #broker="redis://localhost:6379/0", backend="redis://localhost:6379/1"
    #you will also need to run 'celery -A application.celery_app worker'. explanation here: https://community.plotly.com/t/long-callback-with-celery-redis-how-to-get-the-example-app-work/57663/3
)
long_callback_manager = CeleryLongCallbackManager(celery_app)

app = Dash(__name__, long_callback_manager=long_callback_manager, prevent_initial_callbacks=True, external_stylesheets=theme)
server = app.server

app.layout = html.Div([

    dcc.Store(id='memory'),  

    html.H1("dClimate APIV4 Visualizer"),

    html.H2("Input"),

    html.H4("Location Selection:"),

    dl.Map(children=[dl.TileLayer(), dl.LayerGroup(id="layer"), dl.GeoJSON(id="geojson", options=dict(pointToLayer=point_to_layer))], center=(40.786, -73.962),
           id="map", style={'width': '100%', 'height': '50vh', 'margin': "auto", "display": "block"}),

    html.H4("Radius Slider:"),

    dcc.Slider(0, 100, marks=None, value=10, id="circle_radius", updatemode="drag"),

    html.Div("Current radius: 10 km", id='slider-output-container'),

    html.H4("Dataset Selection:"),

    dcc.Dropdown(
        id='dataset',
        options=[
            {'label': 'CHIRPS Final 0.05 Resolution Precipitation', 'value': 'chirps_final_05-daily'},
            {'label': 'CHIRPS Final 0.25 Resolution Precipitation', 'value': 'chirps_final_25-daily'},
            {'label': 'CHIRPS Preliminary 0.05 Resolution Precipitation', 'value': 'chirps_prelim_05-daily'},
            {'label': 'Climate Prediction Center Global Precipitation', 'value': 'cpc_precip_global-daily'},
            {'label': 'Climate Prediction Center US Precipitation', 'value': 'cpc_precip_us-daily'},
            {'label': 'Climate Prediction Center Global Maximum Temperature', 'value': 'cpc_temp_max-daily'},
            {'label': 'Climate Prediction Center Global Minimum Temperature', 'value': 'cpc_temp_min-daily'},
            {'label': 'ERA5 2m Temperature', 'value': 'era5_2m_temp-hourly'},
            {'label': 'ERA5 Precipitation', 'value': 'era5_precip-hourly'}, 
            {'label': 'ERA5 Surface Solar Radiation', 'value': 'era5_surface_solar_radiation_downwards-hourly'}, 
            {'label': 'ERA5 East/West Wind', 'value': 'era5_wind_10m_u-hourly'}, 
            {'label': 'ERA5 East/West Wind', 'value': 'era5_wind_10m_v-hourly'}, 
            {'label': 'PRISM Precipitation', 'value': 'prism-precip-daily'},                
                ],
        placeholder='Select your dataset.',
        value=None,
        style={},
                ),

    html.H4("Daterange Selection:"),

    dcc.DatePickerRange(
        id='my-date-picker-range',
        min_date_allowed=date(1995, 8, 5),
        max_date_allowed=date(2022, 9, 1),
        initial_visible_month=date(2021, 9, 1),
        number_of_months_shown=3,
        clearable=True,
    ),

    html.Br(),

    html.Button(id='get_data', n_clicks=0, children='Get data', style={"font-size": "16px", "padding": "6px 16px", "border-radius": "8px"}),

    html.Button(id='cancel', n_clicks=0, children='Cancel', style={"font-size": "16px", "padding": "6px 16px", "border-radius": "8px"}),

    dbc.Container(dbc.Row(dbc.Col(id='fs_spinner', children=None))),

    html.Div(id="error"),

    html.H2("Output"),

    html.H3("Dataset information:"),

    html.Div(id="date-info"),

    html.Div(id="info"),

    html.H3("Gridpoints within your query:"),

    html.Div(id="gridpoint_list"),

    html.H3("Average Graph:"),

    html.Div(id="average_graph"),

    html.H3("Data Table:"),

    html.Div(id="table_div"),

])

#callback to tell user which radius they have selected
@app.callback(
    Output('slider-output-container', 'children'),
    Input('circle_radius', 'value'))
def update_output(value):
    return 'Current radius: {} km'.format(value)


#main callbcak to fetch data + update map 
@app.long_callback(
            [
    Output('table_div', 'children'),
    Output('average_graph', 'children'),
    Output('layer', 'children'),
    Output('gridpoint_list', 'children'),
    Output('geojson', 'data'),
    Output('error', 'children'),
            ],
            [
    Input('get_data', 'n_clicks'),
    Input("map", "click_lat_lng"),
    Input('circle_radius', 'value'),
    State('map', 'click_lat_lng'),
    State('my-date-picker-range', 'start_date'),
    State('my-date-picker-range', 'end_date'),
    State('dataset', 'value')
            ],

    running=[
        (Output("get_data", "disabled"), True, False),
        (Output("cancel", "disabled"), False, True),
        (Output('fs_spinner', 'children'), dbc.Spinner(size='md', type="grow"), None)
    ],
    cancel=[Input("cancel", "n_clicks")],

            )
def update_output(n_clicks, map_click, radius, latlong, start, end, dataset):
    x = {'type': 'FeatureCollection', 'features': [{'type': 'Feature', 'properties': {'type': 'circle', '_radius': 161.65387904378895, '_mRadius': radius*1000, '_leaflet_id': 152}, 'geometry': {'type': 'Point', 'coordinates': [latlong[1], latlong[0]]}}]}
    if ctx.triggered_id in ['map', 'circle_radius']:
        return [None, None, dl.Marker(position=map_click, children=dl.Tooltip("({:.3f}, {:.3f})".format(*map_click))), None, x, None]


    elif n_clicks > 0:
        datas = get_data(latlong[0], latlong[1], radius, start, end, dataset)
        data = datas[0]
        avg = datas[1]
        latlongs = datas[2]
        var = datas[3]
        error = datas[4]
        if error not in [None]:
            return [None, None, None, None, None, error]

        pointers = [] 
        
        for latlong in latlongs:
            pointers.append(dl.Marker(position=latlong, children=dl.Tooltip("({:.3f}, {:.3f})".format(*latlong))))

        fig = px.line(avg, x="time", y=var)

        table = dash_table.DataTable(data.to_dict('records'), [{"name": i, "id": i} for i in data.columns], export_format="csv",page_size=50, style_table={'max-height': '300px', 'overflowY': 'auto'})
        return [table, dcc.Graph(figure=fig), pointers, str(latlongs)[1:-1], x, None]
    else:
        pass

#callback to update interface based on dataset selected (dateranges, dataset info)
@app.callback(
    [
        Output(component_id='my-date-picker-range', component_property='initial_visible_month'),
        Output(component_id='my-date-picker-range', component_property='min_date_allowed'),
        Output(component_id='my-date-picker-range', component_property='max_date_allowed'),
        Output(component_id='info', component_property='children'),
        Output(component_id='my-date-picker-range', component_property='start_date'),
        Output(component_id='my-date-picker-range', component_property='end_date'),
        Output(component_id='date-info', component_property='children'),
    ],
    [
        Input(component_id='dataset', component_property='value'),
    ]
)

def update_daterange1(dataset):

    results = metadata(dataset)
    results.append(None)
    results.append(None)
    results.append(f"The date range of this dataset is from {results[0]} to {results[2]}.")

    return results

if __name__ == '__main__':
    app.run_server(debug=True)
