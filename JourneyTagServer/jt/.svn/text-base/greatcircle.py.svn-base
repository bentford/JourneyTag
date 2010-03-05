import math

  
#all coordinates are to be given in decimal notation
#all distances are to be given in miles

#degrees i.e. 0 = North, 90 = East, etc. 
class GreatCircle:
    # http://sam.ucsd.edu/sio210/propseawater/ppsw_c/gcdist.c
    @staticmethod
    def inverse(miles, degrees, lat, lon):
        meters = GreatCircle.milesToMeters(miles)
        metersPerDegree = 111120.00071117
        degreesPerMeter = 1.0 / metersPerDegree
        radiansPerDegree = math.pi / 180.0
        degreesPerRadian = 180.0 / math.pi

        if meters > metersPerDegree*180:
            degrees -= 180.0
            if degrees < 0:
                degrees += 360.0
            meters = metersPerDegree * 360.0 - meters

        if degrees > 180:
            degrees -= 360.0

        c = degrees * radiansPerDegree
        d = meters * degreesPerMeter * radiansPerDegree
        L1 = lat * radiansPerDegree
        lon *= radiansPerDegree
        coL1 = (90.0 - lat) * radiansPerDegree
        coL2 = GreatCircle.ahav(GreatCircle.hav(c) / (GreatCircle.sec(L1) * GreatCircle.csc(d)) + GreatCircle.hav(d - coL1))
        L2   = (math.pi / 2) - coL2
        l    = L2 - L1

        dLo = math.cos(L1) * math.cos(L2)
        if dLo != 0:
            dLo  = GreatCircle.ahav((GreatCircle.hav(d) - GreatCircle.hav(l)) / dLo)

        if c < 0:
            dLo = -dLo

        lon += dLo
        if lon < -math.pi:
            lon += 2 * math.pi
        elif lon > math.pi:
            lon -= 2 * math.pi

        xlat = L2 * degreesPerRadian
        xlon = lon * degreesPerRadian
        #xlat = math.degrees(xlat)
        #xlon = math.degrees(xlon)
        
        return (xlat, xlon)

    @staticmethod
    def copysign(x,y):
        if y < 0:
            result = abs(x) * -1 
        else:
            result = abs(x)
        return result
    
    @staticmethod
    def ngt1(x):
        if abs(x) > 1:
            result = GreatCircle.copysign(1, x)
        else:
            result = x
        return result        

    @staticmethod
    def hav(x):
        return (1 - math.cos(x)) * 0.5        

    @staticmethod
    def ahav(x):
        return math.acos(GreatCircle.ngt1(1 - (x * 2)))
        
    @staticmethod
    def sec(x):
        return (1 / math.cos(x))
        
    @staticmethod
    def csc(x):
        return (1 / math.sin(x))
    
    @staticmethod
    def milesToMeters(miles):
        return miles * 1609.344
    
    @staticmethod
    def milesToMetersRounded(miles):
        return int(round(miles * 1609.344))

    @staticmethod
    def metersToMiles(meters):
        return meters * 0.0006213
    
    @staticmethod
    def distance(lat1,lon1, lat2, lon2):
        #haversine distance formula
        lat1 = math.radians(lat1)
        lon1 = math.radians(lon1)

        lat2 = math.radians(lat2)
        lon2 = math.radians(lon2)

        dlat = lat1 - lat2
        dlon = lon1 - lon2
        
        a = (math.sin(dlat / 2))**2 + math.cos(lat1) * math.cos(lat2) * (math.sin(dlon / 2))**2
        c = 2 * math.asin(min(1, math.sqrt(a)))
        dist = 3956 * c
        return int(round(dist))
    
    @staticmethod
    def distanceInMeters(lat1,lon1, lat2, lon2):
        #haversine distance formula
        lat1 = math.radians(lat1)
        lon1 = math.radians(lon1)

        lat2 = math.radians(lat2)
        lon2 = math.radians(lon2)

        dlat = lat1 - lat2
        dlon = lon1 - lon2
        
        a = (math.sin(dlat / 2))**2 + math.cos(lat1) * math.cos(lat2) * (math.sin(dlon / 2))**2
        c = 2 * math.asin(min(1, math.sqrt(a)))
        dist = 6366564.0 * c
        return dist        