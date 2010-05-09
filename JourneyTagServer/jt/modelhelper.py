class JsonQueryUtil:
    @staticmethod
    def toArray(name,query):
        first = True
        response = '{"%s":[' % (name)
        for entity in query:
            if not first:
                response += ','
            else:
                first = False
            response += entity.toJSON()
        response += ']}'
        return response
    @staticmethod
    def toSingleKey(name,query):
        entity = query.fetch(1)

        if len(entity) == 0:
            key = '';
        else:
          key = str(entity[0].key())
          
        return '{"%s":"%s"}' % (name,key)

class JsonObjectUtil:
    @staticmethod
    def toSingleValue(name,key):
        return '{"%s":"%s"}' % (name,key)
        
def keyArrayToJson(name, array):
    first = True
    response = '{"%s":[' % (name)
    for key in array:
        if not first:
            response += ','
        else:
            first = False
        response += '"%s"' % str(key)
    response += ']}'
    return response
        