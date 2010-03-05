from random import uniform

import string
import logging

class jtPassword:
    characters = ''
    def __init__(self):
        self.characters = list(string.ascii_letters)
        self.characters.extend(list(string.digits))

    def generatePassword(self, length):
        password = []
        for pos in range(length):
            char = self.randomChar()
            password.append(char)
        return string.join(password,'')
    
    def randomChar(self):
        index = uniform(0, len(self.characters)-1)
        return self.characters[int(index)]