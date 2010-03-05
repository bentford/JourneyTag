
unfitWords = ['fuck','shit','cunt','dick','ass','nigger']

def filterWord(word):
    lowered = word.lower()
    if containsUnfitWord(lowered):
        word = lowered #name is now lowered, but who cares about them
        word = removeUnfitWord(word)

    return word

def cleanWord(word):
    newWord = ''
    letters = list(word)
    for index in range(len(letters)):
        if index == 0 or index == len(letters)-1:
            newWord += letters[index]
        else:
            newWord += '*'
    return newWord

def removeUnfitWord(text):
    clean = text
    for unfitWord in unfitWords:
        clean = clean.replace(unfitWord,cleanWord(unfitWord))
    
    return clean
    
    
def containsUnfitWord(text):
    for unfitWord in unfitWords:
        if text.find(unfitWord) > -1:
            return True
    return False