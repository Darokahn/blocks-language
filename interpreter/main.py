import sys
import re

class Token:
    def __init__(self):
        self.token = {}

    def match(string):
        raise NotImplemented
        """
        first, check if string matches condition
        if it does, set self.token to something and then return true
        """

class Name(Token):
    def __init__(self):
        super().__init__()
        self.names = []
    
    def match(self, string):
        if string:
            if string in self.names:
                self.token = {"token": "Name", "name": self.names.index(string)}
            else:
                self.token = {"token": "Name", "name": len(self.names)}
                self.names.append(string)
            print(self.token)
            return True


def main():
    args = sys.argv
    if len(args) > 2:
        raise Exception("current support is only for a target file. No additional arguments can be used at this time.")
        sys.exit(1)
    
    code = ""
    with open(args[1]) as file:
        code = file.read()
    

    token_types = [Name()]

    tokens = []

    string = ""

    for char in code:
        string += char
        for t in token_types:
            if t.match(string):
                string = string[0:-1]
                tokens += t.token
    print(tokens)




main()