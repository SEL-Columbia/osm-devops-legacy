### Map API 

The openstreetmap 0.6 api the [map request](http://wiki.openstreetmap.org/wiki/API_v0.6#Retrieving_map_data_by_bounding_box:_GET_.2Fapi.2F0.6.2Fmap) allows users to retrieve all osm data within a bounding box. 

The performance of this often called request is important.  

The ruby based implementation included in the [openstreetmap-website](github.com/openstreetmap/openstreetmap-website) source performs poorly in terms of runtime and memory.  Frequent/large requests handled by the ruby implementation will bring an osm server down.  

[cgimap](https://github.com/zerebubuth/openstreetmap-cgimap) is an alternative implementation of the map request method that performs much better.  It is written in c, exposed through fastcgi and deployed as a logically separate server.  

### Performance comparison

The following graph compares the performance of the rails implementation to cgimap.  This was a very informal analysis against a fairly dense, but small subset (area around Ibadan, Nigeria) of the master openstreetmap database.  The server was run in a docker container on a 4 year old Thinkpad.  

![](https://github.com/SEL-Columbia/osm-devops/blob/master/cgimap_analysis/comparison.png)

See csv files in cgimap_comparison folder in this repository for supporting data.  
