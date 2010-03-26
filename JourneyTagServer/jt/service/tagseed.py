
import jt.model

from random import uniform

def get():
    
    count = jt.model.TagSeed.all().count()
    if count == 0:
        return None
        
    offset = int(uniform(0,count))
    loc = jt.model.TagSeed.all().fetch(1,offset)[0]
    return loc