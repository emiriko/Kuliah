class InfixPostfix:
    """ SUPER CLASS BAGI Class Infix dan Postfix dibawah class ini"""
    def __init__(self):
        # Constructor 
        self.stack = [] 
        self.symbol = ['+', '-', '*', '/', '$']
        self.errorMessage = []

    def isEmpty(self): # Method untuk mengecek apabila stack empty atau tidak
        if(len(self.stack) == 0): # Apabila empty
            return True
        return False # Apabila tidak empty
    
    def pop(self): # Fungsi untuk pop stack
        if(not self.isEmpty()):
            return self.stack.pop()

    def push(self, item): # Fungsi untuk push ke stack
        self.stack.append(item)

    def setErrorMessage(self, message): # Fungsi untuk mengupdate error messages
        self.errorMessage += [message]

    def getErrorMessage(self):
        return self.errorMessage
        
class InfixToPostfix(InfixPostfix):

    def __init__(self):
        # Constructor 
        super().__init__() # Inherit constructor superclass
        self.precedence = {
        '(': 0, 
        ')': 0, 
        '+': 1, 
        '-': 1, 
        '/': 2, 
        '*': 2, 
        '$': 3, 
        }
        self.result = [] # Result
        # add_precedence = 1
        # minus_precedence = 1
        # multipication_precedence = 2
        # division_precedence = 2
        # exponential_precedence = 3
        # brackets_precedence = 4

    def changeInfix(self, lst): # Fungsi ini untuk mengganti infix menjadi postfix
        for item in lst:
            if(item == '+' or item == '-' or item == '*' or item == '/'):
                # Apabila symbol merupaka +, -, *, / maka kita harus coba untuk pop apabila precedence simbol ini lebih kecil atau bernilai sama dengan precedence yang ada pada ujung atas stack
                while(not super().isEmpty() and self.stack[-1] != '(' and self.precedence[item] <= self.precedence[self.stack[-1]]):
                    self.result.append(super().pop())
                super().push(item)
                
            elif(item == "$"): # Apabila merupakan $ maka tambahkan saja.
                super().push(item)

            elif (item == '('): # Apabila merupakan opening paranthesis maka masukkan saja
                super().push(item)

            elif(item == ')'): # Apabila merupakan closing paranthesis, kita mau pop seluruh item dalam stack kita sampai ketemu opening paranthesis 
                while(not super().isEmpty() and self.stack[-1] != '('):
                    self.result.append(self.pop())

                if(not super().isEmpty()):
                    if(self.stack[-1] == '('):
                        super().pop() # pop open bracket
                else:
                    super().setErrorMessage("[Missing Open Parenthesis]")
            else:
                # Apabila merupakan angka (sudah di validate jadi tidak mungkin huruf)
                if(item not in ['(', ')', '+', '-', '*', '/', '$']):
                    self.result.append(int(item))
        while(not super().isEmpty()): # Apabila masih ada sisa
            if(self.stack[-1] != '('): # Dan sisa itu bukan merupakan closing paranthesis (artinya dalam stack, hanya tersisa simbol)
                self.result.append(self.pop())
            else:
                # Apabila ada paranthesis dalam stack, maka artinya ada error
                super().setErrorMessage("[Missing closing paranthesis]")
                self.pop()

        return self.result # return list tersebut

class PostfixEvaluator(InfixPostfix):
    def __init__(self):
        # Menginherit constructor superclass
        super().__init__()
    
    def evaluatePostFix(self, postFix):
        # Mencari nilai postfix yang sudah ada
        for item in postFix:
            if(item not in self.symbol): # Apabila merupakan nomor
                super().push(item)
            else:
                if(not super().isEmpty()):
                    try: # Pop 2 bilangan (ideal) apabila bertemu dengan simbol
                        rhsNotInt = super().pop()
                        lhsNotInt = super().pop()

                        rhs = int(rhsNotInt)
                        lhs = int(lhsNotInt)

                        if(item == '+'):
                            # Apabila +, maka tambahkan seperti biasa
                            try:
                                temp = int(rhs + lhs) 
                                super().push(temp)
                            except OverflowError: # Apabila overflow
                                super().setErrorMessage("[Overflow happened!]")
                            except TypeError: # Apabila operasi tidak dapat dilakukan
                                if(str(lhsNotInt).isnumeric()):
                                    super().push(int(lhsNotInt))
                                elif(str(rhsNotInt).isnumeric()):
                                    super().push(int(rhsNotInt))
                                super().setErrorMessage("[Missing operand]")
                        elif(item == '-'):
                            # Apabila -, maka kurangi
                            try:
                                temp = int(lhs - rhs)
                                super().push(temp)
                            except OverflowError: # Apabila overflow
                                super().setErrorMessage("[Overflow happened!]")
                            except TypeError: # Apabila operasi tidak dapat dilakukan
                                if(str(lhsNotInt).isnumeric()):
                                    super().push(int(lhsNotInt))
                                elif(str(rhsNotInt).isnumeric()):
                                    super().push(int(rhsNotInt))
                                super().setErrorMessage("[Missing operand]")
                        elif(item == '*'):
                            # Apabila perkalian maka kalikan
                            try:
                                temp = int(lhs*rhs)
                                super().push(temp)
                            except OverflowError: # Apabila dibagi dengan 0
                                super().setErrorMessage("[Overflow happened!]")
                            except TypeError: # Apabila mendapat 0 
                                if(str(lhsNotInt).isnumeric()): 
                                    super().push(int(lhsNotInt))
                                elif(str(rhsNotInt).isnumeric()):
                                    super().push(int(rhsNotInt))
                                super().setErrorMessage("[Missing operand]")
                        elif(item == '/'):
                            # Apabila /, maka dibagi
                            try:
                                temp = int(lhs/rhs)
                                super().push(temp)
                            except ZeroDivisionError: # Apabila dibagi dengan 0
                                super().push(lhs)
                                super().setErrorMessage("[Division by Zero]")
                            except TypeError: # Apabila operasi tidak berhasil
                                if(str(lhsNotInt).isnumeric()):
                                    super().push(int(lhsNotInt))
                                elif(str(rhsNotInt).isnumeric()):
                                    super().push(int(rhsNotInt))
                                super().setErrorMessage("[Missing operand]")
                        elif(item == '$'):
                            # Apabila $, maka dipower
                            try:
                                temp = int(pow(lhs, rhs))
                                super().push(temp)
                            except OverflowError: # Apabila overflow
                                super().setErrorMessage("[Overflow happened!]")
                            except TypeError: # Apabila tidak dapat dilakukan operasi
                                if(str(lhsNotInt).isnumeric()):
                                    super().push(int(lhsNotInt))
                                elif(str(rhsNotInt).isnumeric()):
                                    super().push(int(rhsNotInt))
                                super().setErrorMessage("[Missing operand]")
                    except IndexError: # Apabila pop stack yang kosong
                        super().push(rhs)
                        super().setErrorMessage("[Missing operand]")
                    except TypeError: # Apabila mencoba untuk mengubah simbol menjadi int
                        if(str(lhsNotInt).isnumeric()):
                            super().push(int(lhsNotInt))
                        elif(str(rhsNotInt).isnumeric()):
                            super().push(int(rhsNotInt))
                        else:
                            super().pop()
                        super().setErrorMessage("[Missing operand]")
                else:
                    super().setErrorMessage("[Missing operand]")
                     
        if(not super().isEmpty()): # Kalau stack tidak empty 
            return int(super().pop())
        else: 
            return 0 # Untuk case contoh seperti input yang ada + - saja