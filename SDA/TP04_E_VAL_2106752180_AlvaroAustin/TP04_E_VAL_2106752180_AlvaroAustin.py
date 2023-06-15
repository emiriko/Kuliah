import math
import hashlib
import sys

# User guide: Jalankan python app ini

# # Function untuk cek apakah angka tersebut prima atau tidak (not sure with this one)
# def isPrime(n):
#     if(n <= 1):
#         return False;

#     for i in range(2, int(math.sqrt(n)) + 1):
#         if(n%i == 0):
#             return False
#     return True

# def findNearestPrime(n): # Cari prima terdekat
#     for i in range(n, 2*n): # Looping dari tableSize 2n sampai 4n (karena mau cari prima terdekat)
#         if(isPrime(i)):
#             return i # Apabila true maka return prima tersebut

def findNearestPrime(n):
    """ Fungsi untuk mencari prima yang lebih besar dari 2*n """
    # Firasat time complexity for loop = O(n(log log(n)))
    tempPrimeList = [True for i in range(2*n + 1)]

    p = 2
    while(p*p <= 2*n): 
        if(tempPrimeList[p]):
            for i in range(p*p, 2*n + 1, p): # Mencoret semua faktor hingga tersisa prima
                tempPrimeList[i] = False
        p += 1

    for i in range(n+1, len(tempPrimeList)): # Return prima terdekat dari 2n
        if(tempPrimeList[i]):
            return i
    return -1

class DoubleHashMapBase:
    """ Class HashMap untuk mendapatkan hasil sesuai perintah tertentu """
    class Map:
        def __init__(self, username, password):
            # Constructor
            self.username= username 
            self.password = password
            
        def setUsername(self, username): # Set username (tidak dipakai)
            self.username = username
        def setHashedPassword(self, hashedPassowrd): # Set password yang hashed
            self.password = hashedPassowrd

    def __init__(self, tableSize = 11):
        self.size = tableSize # Table size (awal2 11)
        self.hashList = [None]*tableSize # Bikin list sebesar 11 (karena table size)
        self.count = 0 # Jumlah counter (banyaknya register)
        self.currentUser = None # Data yang login sekarang
        self.limit = math.ceil(tableSize*0.7) # Tentukan limit pertama kali
        self.PRIME = 7 # Constant PRIME

    def set_hashList(self, finalHashingCode, username, hashedPassword):
        """ Fungsi ini untuk menempatkan hash value pada hashmap"""
        self.hashList[finalHashingCode] = self.Map(username, hashedPassword) # Meletakkan hashCode dengan elemennya pada list

    def _encryptPassword(self, password):
        """ Fungsi ini untuk encrypt password """
        hashed = hashlib.md5(password.encode())

        return hashed.hexdigest()

    def _hitungHashCode(self, username):
        """ Fungsi ini untuk menghitung banyak nya ordinal dalam suatu string username"""
        temp = 0
    
        for i in username: # Looping per char
            temp += ord(i)

        return temp

    def _resize(self):
        """ Fungsi ini untuk memperbesar table size dan menambahkan limit serta memperbesar hash map"""

        prime = findNearestPrime(self.size*2)
        self.size = prime
        self.hashList = [None]*self.size
        self.limit =math.ceil(prime*0.7)
        self.count = 0 # Ulang agar akun yang register jadi 0 lagi (karena harus di rehash)

    def _add_count(self):
        """ Fungsi ini untuk menambahkan akun yang register"""
        self.count = self.count + 1
    
    def _get_count(self):
        """ Fungsi ini untuk mendapatkan berapa banyak akun yang register"""
        return self.count

    def getFinalKey(self, username):
        """ Fungsi ini untuk mendapatkan nilai hashcode dari sebuah username yang diberikan"""
        nilaiHashCode = self._hitungHashCode(username) # Mau itung hashcode nya
        firstHashing = nilaiHashCode % self.size
        if(self.hashList[firstHashing] == None): # In case kalo di delete
            # Apabila usernya none hal ini bisa terjadi apabila UNREGISTER, maka kita harus cari sampai seluruh cara
            counterHash = 1
            secondHashingTry = self.PRIME - (nilaiHashCode % self.PRIME)
            while(counterHash <= self.size): # Karena kita hanya perlu menghitung counterHash sampai akhir hash
                secondHashingAkhir = (firstHashing + counterHash*secondHashingTry) % self.size
                if(self.hashList[secondHashingAkhir] == None):
                    counterHash += 1
                    continue
                elif(self.hashList[secondHashingAkhir].username != username): 
                    counterHash += 1
                    continue
                elif(self.hashList[secondHashingAkhir].username == username): # Apabila ketemu user dengan username yang tepat
                    return secondHashingAkhir
        else:
            if(self.hashList[firstHashing].username == username): # Apabila ketemu user dengan username yang tepat pada fungsi hashing pertama
                return firstHashing
            else:
                counterHash = 1
                secondHashingTry = self.PRIME - (nilaiHashCode % self.PRIME)
                while(counterHash <= self.size):
                    secondHashingAkhir = (firstHashing + counterHash*secondHashingTry) % self.size
                    if(self.hashList[secondHashingAkhir] == None):
                        counterHash += 1
                        continue
                    elif(self.hashList[secondHashingAkhir].username != username): 
                        counterHash += 1
                        continue
                    elif(self.hashList[secondHashingAkhir].username == username): # Apabila ketemu user dengan username yang tepat pada fungsi hashing kedua
                        return secondHashingAkhir
        return -1

    def _hashing(self, nilaiHashCode):
        """ Fungsi ini untuk mencari index hashing paling tepat"""
        firstHashingTry = nilaiHashCode % self.size

        if(self.hashList[firstHashingTry] != None): # Apabila sudah ditempati index first hashing
            secondHashingTry = self._secondHashing(nilaiHashCode, firstHashingTry)

            return secondHashingTry

        return firstHashingTry

    def _secondHashing(self, nilaiHashCode, firstHashingTry):
        """ Fungsi ini untuk mencari index hashing paling tepat apabila hashing function pertama tidak bisa"""
        counter = 2
        secondHashingTry = self.PRIME - (nilaiHashCode % self.PRIME)
        secondHashingAkhir = (firstHashingTry + secondHashingTry) % self.size

        while(self.hashList[secondHashingAkhir] != None):
            secondHashingAkhir = (firstHashingTry + counter*secondHashingTry) % self.size
            counter += 1

        return secondHashingAkhir

    def register(self, username, password):
        """ Fungsi ini untuk cek register """
        if(self.check_username(username) == "Username Is Registered"): # Find whether username exist or not
            return "Username Already Exist"
        else:
            nilaiHashCode = self._hitungHashCode(username) 
            nilaiHashing = self._hashing(nilaiHashCode) # Final nilai dari hashing code/index
            self.set_hashList(nilaiHashing, username, self._encryptPassword(password)) # Masukkan ke hashmap
            self._add_count() # Tambah jumlah register
        
        if(self.count == self.limit): # Apabila ditambah mencapai limit maka harus di resize 
            # Resize -> rehash
            tempList = [] # Menampung user yang login

            for i in range(0, len(self.hashList)):
                if(self.hashList[i] != None):
                    tempList.append(self.hashList[i])

            self._resize()
            self.count = 0

            for i in range(0, len(tempList)): # Looping siapa saja yang login untuk di hash kembali
                nilaiHashCodeLoop = self._hitungHashCode(tempList[i].username) 
                nilaiHashingLoop = self._hashing(nilaiHashCodeLoop) # Final nilai dari hashing code/index
                self.set_hashList(nilaiHashingLoop, tempList[i].username, tempList[i].password)
                self._add_count()

        return "Register Successful"    
    
    def login(self, username, password):
        """ Fungsi untuk login """
        encryptCurrentPassword = self._encryptPassword(password) 
        if(self.check_username(username) == "Username Not Found"): # Apabila usernya tidak ditemukan
            return "Username Not Found"
        else: 
            finalKey = self.getFinalKey(username)
            if(finalKey == -1): # Apabila usernya tidak ada 
                return "Username Not Found"
            else: 
                if(self.hashList[finalKey].password == encryptCurrentPassword): # Apabila passwordnya benar
                    self.currentUser = self.hashList[finalKey]
                    return "Login Successful"
                else:
                    return "Incorrect Password"

    def edit_current_username(self, username):
        """ Fungsi untuk Edit username """
        keyToCheck = self.getFinalKey(username)
        if(keyToCheck != -1): # Apabila sudah ada user dengan username yang sama
            return "Username Already Exist"
        else: 
            self.currentUser.username = username 
            tempList = [] # Menampung karena harus di rehash
            for i in range(0, len(self.hashList)):
                if(self.hashList[i] != None):
                    tempList.append(self.hashList[i])
                self.hashList[i] = None

            for i in range(0, len(tempList)):
                nilaiHashCodeLoop = self._hitungHashCode(tempList[i].username) 
                nilaiHashingLoop = self._hashing(nilaiHashCodeLoop) # Final nilai dari hashing code/index
                self.set_hashList(nilaiHashingLoop, tempList[i].username, tempList[i].password)
                if(self.hashList[nilaiHashingLoop].username == username): # Harus catat yang login (karena username berubah maka harus di rehash oleh karena itu indexnya berubah)
                    self.currentUser = self.hashList[nilaiHashingLoop]

        return "Your Account Has Been Updated"

    def edit_current_password(self, password):
        """ Fungsi untuk mengubah password """
        new_password = self._encryptPassword(password)
        self.currentUser.password = new_password # Ganti saja passworndya
        return "Your Account Has Been Updated"

    def is_authenticated(self): 
        """ Fungsi untuk mengetahui sudah login atau belum"""
        if(self.currentUser != None): # Apabila sudah login
            return f"{self.currentUser.username} {self.currentUser.password}"
        else:
            return "Please Login"
    
    def unregister(self, username, password):
        """ Fungsi untuk unregister """
        encrypted_current_password = self._encryptPassword(password)
        finalKey = self.getFinalKey(username)
        if(finalKey == -1): # Apabila tidak ada akun yang di specify
            return "Username Not Found"
        elif(self.hashList[finalKey].password != encrypted_current_password): # Apabila password berbeda
            return "Incorrect Password"
        else: 
            self.hashList[finalKey] = None # Mengubah instance menjadi None
            self.count -= 1 # Mengurangi jumlah akun
        return "Your Account Has Been Deleted"
    
    def logout(self):
        """ Fungsi untuk logout """
        if(self.currentUser != None):
            self.currentUser = None
        else:
            return "You Have Not Been Logged In"
        return "You Have Been Logged Out"
    
    def inspect(self, row):
        """ Fungsi untuk mengetahui row kosong atau tidak """
        if(self.hashList[row] != None):
            return f"{self.hashList[row].username} {self.hashList[row].password}"
        else:
            return "Row Is Empty"

    def check_username(self, username):
        """ Fungsi untuk mengetahui apakah ada username tersebut atau tidak """
        finalKey = self.getFinalKey(username)
        if(finalKey == -1):
            return "Username Not Found"
        else:
            return "Username Is Registered"

    def count_username(self):
        """ Untuk menghitung berapa yang sudah register """
        return self.count
    
    def capacity(self):
        """ Menghitung table size yang besar """
        return self.size

doubleHashMap = DoubleHashMapBase()
soal = []
while True:
    inp = input().strip().split(" ") # Dapatkan input
    perintahSatu = inp[0]
    if(perintahSatu == "EXIT"): # Apabila perintah EXIT
        sys.exit()
    elif(perintahSatu == "CAPACITY"): # Apabila perintah CAPACITY (kapasitas tabel)
        print(doubleHashMap.capacity())
    elif(perintahSatu == "COUNT_USERNAME"): # Untuk mencari berapa banyak yang register
        print(doubleHashMap.count_username())
    elif(perintahSatu == "LOGOUT"): # Untuk logout
        print(doubleHashMap.logout())
    elif(perintahSatu == "IS_AUTHENTICATED"): # Untuk cek apakah login atau tidak
        print(doubleHashMap.is_authenticated())
    elif(perintahSatu == "INSPECT"): # Untuk cek apakah row terisi atau tidak
        perintahDua = int(inp[1]) # Nanti coba try except 
        print(doubleHashMap.inspect(perintahDua)) 
    elif(perintahSatu == "CHECK_USERNAME"): # Untuk cek apakah username sudah terregister atau tidak
        perintahDua = inp[1]
        print(doubleHashMap.check_username(perintahDua))
    elif(perintahSatu == "REGISTER"): # Untuk register
        perintahDua = inp[1]
        perintahTiga = inp[2]
        register = doubleHashMap.register(perintahDua, perintahTiga)
        print(register)
    elif(perintahSatu == "LOGIN"): # Untuk login
        perintahDua = inp[1]
        perintahTiga = inp[2]
        login = doubleHashMap.login(perintahDua, perintahTiga)
        print(login)
    elif(perintahSatu == "EDIT_CURRENT"): # Untuk edit akun
        perintahDua = inp[1]
        perintahTiga = inp[2]
        if(perintahDua == "USERNAME"): # Edit nama akun
            edit_current = doubleHashMap.edit_current_username(perintahTiga)
            print(edit_current)
        elif(perintahDua == "PASSWORD"): # Edit password akun
            edit_current = doubleHashMap.edit_current_password(perintahTiga)
            print(edit_current)
        else:
            print("Pilih diantara USERNAME atau PASSWORD!")
    elif(perintahSatu == "UNREGISTER"): # Untuk tidak jadi register
        perintahDua = inp[1]
        perintahTiga = inp[2]
        unregister = doubleHashMap.unregister(perintahDua, perintahTiga)
        print(unregister)
    else:
        print("Masukkan perintah yang benar!")
