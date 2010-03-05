import unittest

import sys
sys.path.append('../')

from jt.wordfilter import *

class WordFilterTest(unittest.TestCase):
    def test_clean(self):
        self.assertEqual(True, containsUnfitWord('afucka') )        
        self.assertEqual(True, containsUnfitWord('fucka') )
        self.assertEqual(True, containsUnfitWord('fuck') )
    
    def test_cleanword(self):
        self.assertEqual('f**k', cleanWord('fuck') )

    def test_removeunfitword(self):
        self.assertEqual('i like to f**k', removeUnfitWord('i like to fuck') )

unittest.main()