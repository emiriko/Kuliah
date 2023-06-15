import sys

MAX_VALUE = 2**63-1

def showTable(arr):
    """ FUNGSI UNTUK PRINT TABEL S DAN M"""
    for i in range(1, len(arr)):
        for j in range(1, len(arr)):
            if(j == 1): # Apabila awal-awal maka tidak perlu di text-align
                print(f"{arr[i][j]}", end = " ") 
            else:
                print(f"{arr[i][j]:>12}", end = " ") # Text align sebesar 12 kekanan
        print()
    print("\n")

def PRINT_OPTIMAL_PARENS(s, i, j):
    """ Fungsi untuk mendapatkan perkalian matrix yang optimal"""
    if(i == j): # Apabila i == j maka print nilai A ke i tersebut
        print(f"A{i}", end = "")
    else: 
        print("(", end = "") # Apabila buka kurung tidak perlu ditambah apa-apa
        PRINT_OPTIMAL_PARENS(s, i, s[i][j]) 
        print(" ", end = "") # Apabila fungsi print_optimal_parens pertama dari kondisi ini selesai maka tambahkan space 
        PRINT_OPTIMAL_PARENS(s, s[i][j] + 1, j)
        print(")", end = "")
        
def MCM(p):
    m = [[0 for i in range(len(p))] for i in range(len(p))] # Membuat list m dengan panjang dimensi n + 1 (karena ada n+1 perkalian skalar pada perkalian matrix yang valid)
    s = [[0 for i in range(len(p))] for i in range(len(p))] 
    n = len(p) - 1 # Karena ada n+1 maka dikurangi karena hanya ingin memiliki panjang sesungguhnya yaitu n 

    for i in range(1, n+1):
        m[i-1][i-1] = 0 # Membuat nol seluruh elemen pada diagonal matrix, karena perkalian dengan dirinya sendiri M[i, i] bernilai nol
    
    for L in range(2, n+1): # L = panjang dari MC (Matrix chain)
        for i in range(1, n - L + 2): # Membatasi nilai baris sesuai dengan batasan pada L
            j = i + L - 1  # Mendapatkan nilai kolom dari batasan nilai i diatas
            m[i][j] = MAX_VALUE
            for k in range(i, j):
                q = m[i][k] + m[k+1][j] + p[i-1]*p[k]*p[j] # Mmebagi matrix menjadi 2 bagian dengan batasan k karena 2 submatrix yang optimal pasti menhasilkan matrix yang optimal. P[i-1]*p[k]*p[j] adalah biaya mengalikan kedua submatrix tersebut
                if(q < m[i][j]): # Ingin mencari cheapest cost 
                    m[i][j] = q
                    s[i][j] = k
    return m, s
lst = []
matrixInput = []
while True:
    lstPenampung = []
    penampungInp = input()
    lst.append(penampungInp)
    if(penampungInp == 'EXIT'):
        break
    x = input().split(" ") # Memeotong list sesuai dengan spasi yang ada
    lstPenampung += x
    matrixInput.append(lstPenampung)

for k in range(len(lst)):
    # inp = input() # Mengambil input

    if(lst[k] == 'EXIT'): # Apabila perintah exit
        sys.exit()
    else:
        try:
            n = int(lst[k])
            p = [] # Membuat list baru untuk menyimpan dimensi-dimensi skalar matrix perkalian
            matrixExclude = [] # membuat list untuk memisahkan setiap kombinasi matrix menjadi 2 bagian
            validasiMatrix = [] # membuat list untuk memmbandingkan setiap ordo kolom matrix sekarang dengan baris matrix selanjutnya 
            validated = True # Coutner Untuk mengetahui apakah matrix tersebut valid atau tidak
            for i in range(n):
                matrixExclude = matrixInput[k][i].replace("(", "").replace(")", "").split(",")
                if(validasiMatrix == []):
                    validasiMatrix.append(int(matrixExclude[1]))
                else:
                    if(validasiMatrix[len(validasiMatrix) - 1] != int(matrixExclude[0])): # Apabiila tidak valid
                        print("Invalid Size\n")
                        validated = False
                        break; 
                    else: # Apabila masih valid
                        validasiMatrix.append(int(matrixExclude[1])) 
            
                p.append(int(matrixExclude[0]))
                if(i == n-1): # Apabila akhir-akhir maka masukkan juga nilai akhir dari matrix tersebut, inilah yang menyebabkan panjang p menjadi n+1
                    p.append(int(matrixExclude[1]))
            
            if(not validated): # Apabila tidak validated
                continue

            m, s = MCM(p) # Cari nilai m dan s
            print(m[1][n]) # Print minimum cost
            PRINT_OPTIMAL_PARENS(s, 1, n) # Print kombinasi matrix paling optimal
            print("\n")
            # print("Tabel M:")
            # showTable(m) # Print tabel m

            # print("Tabel S:")
            # showTable(s) # Print tabel s
        except ValueError: # Apabila error
            print("Invalid Input\n")
            continue
        except TypeError:
            print("Invalid Input\n")
            continue