import tkinter as ttk
from main import Main
import string 

""" 
Menggunakan class GUI dibawah ini sebagai alat untuk menggunakan aplikasi Infix to Postfix to Evaluate ini. Cara menggunakannya kalian hanya perlu untuk menjalankan code dalam file ini. Ingat, menjalankan kode di file lain tidak akan menjalan GUI tersebut

- Alvaro Austin
"""

class App(ttk.Frame):
    def __init__(self, master = None):
        # Menginisialisasikan GUI 
        super().__init__(master)
        self.pack()
        self.infix_ans = ttk.StringVar()
        self.create_widgets()
        self.create_button()

    def create_widgets(self): 
        # Fungsi untuk memperlihatkan Entry infix dan desain awal.
        self.frm_infix = ttk.LabelFrame(self, text = "Infix to Postfix evaluator!")
        self.lbl_infix_ans = ttk.Label(self.frm_infix, text = "Masukkan ekspresi infix: ")
        self.ent_infix_ans = ttk.Entry(self.frm_infix, textvariable = self.infix_ans)

        self.ent_infix_ans.bind("<Return>", self.btn_cari_clicked)

        self.frm_infix.pack()
        self.lbl_infix_ans.grid(row = 0, column = 0, sticky = ttk.E)
        self.ent_infix_ans.grid(row = 0, column = 1, padx = 5, pady = 5)
    
    def create_button(self):
        # Fungsi ini untuk memperlihatkan button untuk mencari hasil infix (menjadi postfix, maupun mendapatkan hasil infix tersebut serta error message apabila ada)
        self.btn_cari = ttk.Button(self, text = "Cari Hasilnya!", command = self.btn_cari_clicked)
        self.btn_cari.pack()

    def create_popup(self, ekspresiInfix, ekspresiPostfix,  result, errorMessage):
        # Fungsi ini untuk memperlihatkan hasil serta persamaan infix yang pertama kali di tanyakan.
        self.frm_infix = ttk.LabelFrame(self, text = "Jawaban")
        self.lbl_infix_ans = ttk.Label(self.frm_infix, text = "Masukkan ekspresi infix: ")
        self.hasil_infix_ans = ttk.Label(self.frm_infix, text = ekspresiInfix)

        self.lbl_postfix_ans = ttk.Label(self.frm_infix, text = "Ekspresi Postfix: ")
        self.hasil_postfix_ans = ttk.Label(self.frm_infix, text = ekspresiPostfix)

        self.lbl_result_ans = ttk.Label(self.frm_infix, text = "Nilai: ")
        self.hasil_result_ans = ttk.Label(self.frm_infix, text = result)

        if(errorMessage != ""):
            # Memperlihatkan apabila ada error message, kalau tidak ada tidak kelihatan
            self.lbl_error_msg_ans = ttk.Label(self.frm_infix, text = "Error Messages: ")
            self.hasil_error_msg_ans = ttk.Label(self.frm_infix, text = errorMessage)


        self.frm_infix.pack()

        self.lbl_infix_ans.grid(row = 0, column = 0, sticky = ttk.E)
        self.hasil_infix_ans.grid(row = 0, column = 1, sticky = ttk.E)

        self.lbl_postfix_ans.grid(row = 1, column = 0, sticky = ttk.E)
        self.hasil_postfix_ans.grid(row = 1, column = 1, sticky = ttk.E)

        self.lbl_result_ans.grid(row = 2, column = 0, sticky = ttk.E)
        self.hasil_result_ans.grid(row = 2, column = 1, sticky = ttk.E)
        
        if(errorMessage != ""): 
            # Memperlihatkan apabila ada error message, kalau tidak ada, tidak kelihatan
            self.lbl_error_msg_ans.grid(row = 3, column = 0, sticky = ttk.E)
            self.hasil_error_msg_ans.grid(row = 3, column = 1, sticky = ttk.E)

    def btn_cari_clicked(self, event = None):
        # Mencari hasil atau algoritma utama untuk menjalankan GUI ini. 
        infix = self.infix_ans.get() # Mendapatkan nilai entry untuk infix
        s = ""
        togglePunctuation = False

        for element in infix:
            if(element in string.punctuation and togglePunctuation == False):
                s += " " + element + " " 
                togglePunctuation = True
            elif(element in string.punctuation and togglePunctuation == True):
                s += element + " "
                togglePunctuation = True 
            elif(element.isspace() == False):
                s += element
                togglePunctuation = False

        finalizedInput = s.strip().split(" ") # Mendapatkan infix yang sudah dapat dimasukkan ke fungsi-fungsi lain sebagai list

        main = Main()
        validated = main.validate_input(finalizedInput) # Validasi nilai input tersebut (contoh, apabila ada symbol yang bukan termasuk symbol utama yaitu +, -, *, /, $, (, dan ) )
        ekspresiPostfix = ""
        errorMessage = ""
        result = ""

        if(validated): # Apabila input nya sudah tervalidasi bahwa input tersebut sudah wajar
            lst = main.changeInfixToPostfix(finalizedInput) # Cari list postfix

            result = main.EvaluatePostfix(lst) # Evaluasi nilai postfix tersebut

            for char in lst:
                ekspresiPostfix += (str(char) + " ") # Ganti postfix (lst) menjadi string
            if(main.errorMessage[1] != []): # Apabila ada error pada postfix
                errorMessage = main.errorMessage[1][0]
            elif(main.errorMessage[0] != []): # Apabila ada error pada infix
                errorMessage = main.errorMessage[0][0]
            else: # Apabila tidak ada error, berarti error messagenya tidak ada
                errorMessage = ""
        else:
            errorMessage = main.errorMessage[0] # Kalau misal tidak tervalidasi berarti error messagenya berdasarkan error yang di kembalikan pada fungsi validateInput

        ekspresiInfix = infix

        self.create_popup(ekspresiInfix, ekspresiPostfix, result, errorMessage) # Membuat popup .

myapp = App()  
myapp.master.title("Infix -> Postfix -> Hasil")
myapp.master.mainloop()