function [array] = readsld(filepath, series)
% filepath: char, path to .sld file
% series: int, ID of series to open
% channel: int, ID of channel to open
% frame: int, timepoint of series to open

r = bfGetReader(filepath);                  

        %access the OME metadata and get number of series
        omeMeta = r.getMetadataStore();            
        nSeries = r.getSeriesCount();               
           
            %switch between series and load that series
            r.setSeries(series);      
            r.getSeries();                 

            %get metadata and extract important features
            omeMeta = r.getMetadataStore();    
            stackSizeX = omeMeta.getPixelsSizeX(0).getValue();      %image width in pixels
            stackSizeY = omeMeta.getPixelsSizeY(0).getValue();      %image height in pixels
            stackSizeZ = omeMeta.getPixelsSizeZ(0).getValue();      %number of slices
            stackSizeC = omeMeta.getPixelsSizeC(0).getValue();      %number of channels
            stackSizeT = omeMeta.getPixelsSizeT(0).getValue();      %number of time points
                      
               %Using bioformats GetPlane we can retrieve a plane given a 
               %set of (z, c, t) coordinates, which we have to linearisesd
               %using get.Index.  You have to use T = T-1, C=C-1, and 
               %Z=Z-1:
               %T = frame;          %get T coordinate for index
               %C = channel;               %get C (channel) coordinate for index(only one!)
               %we will get the Z coordinate in the next for loop
                     
               %We need to store all of Z-stacks of this time-point
               %in an array to be processed later, so set up and empty array 
               %and start a count
               count = 1;
               array = [];
 
               %iterate through all the Z-stacks 
               
               for T = 0:stackSizeT-1
               for Z = 0:stackSizeZ-1
                   for C = 0:stackSizeC-1
                   
                    %Use the index to read in the specific plane and
                    %convet to double
                    plane = bfGetPlane(r, r.getIndex(Z, C, T) +1);     
                    plane = double(plane);

                    %add plane to array at position (count, 1)(in essence 
                    %you are appending the array) and add 1 to count
                    array(:,:,count) = plane;
                    count = count+1;
               end
               end
               end
               array = uint16(array);
end