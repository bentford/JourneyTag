import unittest

import sys
sys.path.append('../')

from jt.greatcircle import GreatCircle

class GreatCircleTest(unittest.TestCase):
    def test_distance(self):
        lon1 = -123.697748
        lon2 = -122.717808
        
        lat1 = 42.355901
        lat2 =  42.355901
        
        result = GreatCircle.distance(lat1,lon1,lat2,lon2)
        self.assertEqual(result, 50)

unittest.main()