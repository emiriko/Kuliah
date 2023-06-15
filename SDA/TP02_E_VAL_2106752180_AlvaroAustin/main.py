from algorithm import InfixToPostfix, PostfixEvaluator

class Main:
    def __init__(self):
        # Constructor main class
        self.allowed_symbol = ['+', '-', '*', '/', '$', '(', ')']
        self.errorMessage = []

    def validate_input(self, input):
        # Fungsi untuk validasi input 
        symbolToggle = False # Elemen toggle 
        paranthesisLeftToggle = False # Elemen toggle
        paranthesisRightToggle = False # Elemen toggle
        numberToggle = False # Elemen toggle
        for item in input: # Looping input tersebut 
            if(item.isnumeric() == False and item not in self.allowed_symbol):
                # Apabila ada simbol yang bukan merupakan allowed_symbol, maka error
                self.setErrorMessage("[Symbol yang dimasukkan tidak termasuk requirement]")
                return False
            elif(item.isnumeric() == False):
                if(item == '('): # Apabila open paranthesis ada yang salah pola
                    if((symbolToggle == True and paranthesisLeftToggle == False and numberToggle == False) or (numberToggle == False and symbolToggle == False and paranthesisLeftToggle == False and paranthesisRightToggle == False) or (paranthesisLeftToggle == True and numberToggle == False and symbolToggle == False and paranthesisRightToggle == False)):
                        paranthesisLeftToggle = True
                        paranthesisRightToggle = False
                        symbolToggle = False
                        numberToggle = False
                    else: 
                        # Kalau misal polanya tidak sesuai dengan kondisi maka salah
                        self.setErrorMessage("[Input format ada yang salah!]")
                        return False
                elif(item == ')'):
                    # Pola untuk closing parantheses 
                    if((symbolToggle == False and paranthesisLeftToggle == False and paranthesisRightToggle == False and numberToggle == True) or (paranthesisLeftToggle == True and paranthesisRightToggle == False and symbolToggle == False and numberToggle == False) or (paranthesisRightToggle == True and symbolToggle == False and numberToggle == False and paranthesisLeftToggle == False)):
                        paranthesisRightToggle = True
                        paranthesisLeftToggle = False
                        symbolToggle = False
                        numberToggle = False
                    else:
                        # Apabila tidak sesuai dengan pola
                        self.setErrorMessage("[Input format ada yang salah!]")
                        return False
                else:
                    # Apabila simbol selain paranthesis
                    symbolToggle = True
                    paranthesisRightToggle = False
                    paranthesisLeftToggle = False
                    numberToggle = False
            else:
                # Apabila merupakan angka
                symbolToggle = False
                paranthesisLeftToggle = False
                paranthesisRightToggle = False
                numberToggle = True
        return True # Apabila tidak ada error maka validationnya sudah benar

    def changeInfixToPostfix(self, input): # Mengubah dari infix ke postfix
        infix = InfixToPostfix() # memanggil instance 
        lstPostfix = infix.changeInfix(input) # Memanggil method instance tersebut
        errorMessage = infix.getErrorMessage() # Mendapatkan error message pada constructor
        self.setErrorMessage(errorMessage) # Memanggil perubahan errormessage
        return lstPostfix # Mengembalikan list berupa hasil postfix

    def setErrorMessage(self, message): 
        self.errorMessage += [message] # Menambahkan error message

    def getErrorMessage(self):
        return self.errorMessage # Mengembalikan error message

    def EvaluatePostfix(self, lst):
        postfix = PostfixEvaluator() # Instance class postfix 
        errorMessage = postfix.getErrorMessage() # Mengambil error message
        self.setErrorMessage(errorMessage)

        return postfix.evaluatePostFix(lst) # Evaluate hasil postfix tersebut