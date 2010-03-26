import hashlib

def hashPassword(password):
    sha = hashlib.sha1()
    sha.update(password)
    return sha.hexdigest()