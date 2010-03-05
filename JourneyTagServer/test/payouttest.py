import unittest

import sys
sys.path.append('../')

from jt.payout import *

class PayoutTest(unittest.TestCase):
    def test_round(self):
        self.assertEqual(1.0, round(0.9999999,3))
        self.assertEqual(0.124, round(0.1235,3))

    def test_calculatePayout(self):
        self.assertEqual(1.0,jtPayout.calculatePayout(0))

unittest.main()