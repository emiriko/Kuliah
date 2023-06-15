package main

import (
	"compnetcsui/a06/cryptohelper"
	"fmt"
	"net"
	"os"
	"time"
)

const (
	SERVER_HOST = ""
	SERVER_PORT = "2180"
	SERVER_TYPE = "tcp"
	BUFFER_SIZE = 4096
)

func main() {
	tcpAddr, err := net.ResolveTCPAddr(SERVER_TYPE, SERVER_HOST+":"+SERVER_PORT)
	if err != nil {
		fmt.Println("Error message:", err.Error())
	}

	server, err := net.ListenTCP(SERVER_TYPE, tcpAddr)
	if err != nil {
		fmt.Println("Error message:", err.Error())
		os.Exit(1)
	}

	defer server.Close()

	// Handle first message received from the client
	conn, err := server.Accept()
	if err != nil {
		fmt.Println("Error message: ", err.Error())
	}

	buffer := make([]byte, BUFFER_SIZE)
	bufLen, err := conn.Read(buffer)
	if err != nil {
		fmt.Println("Error message:", err.Error())
		return
	}

	recvMsg := string(buffer[:bufLen])
	fmt.Println(recvMsg)

	_, err = conn.Write([]byte("Hey there Client"))
	time.Sleep(time.Second)
	if err != nil {
		fmt.Println("error message:", err.Error())
		return
	}

	privateKey, err := cryptohelper.NewAsymmetricKey()

	if err != nil {
		fmt.Println("Error message: ", err.Error())
		return
	}

	// Handle the "Here’s our Public Key" send to the client

	_, err = conn.Write([]byte("Here’s our Public Key"))
	time.Sleep(time.Second)

	if err != nil {
		fmt.Println("Error message:", err.Error())
	}

	// This part will send the public key to the server
	_, err = conn.Write(cryptohelper.ExportAsymmetricPublicKey(&privateKey.PublicKey))
	time.Sleep(time.Second)

	if err != nil {
		fmt.Println("Error message:", err.Error())
	}

	// This part will handle Public Key Received Part

	buffer = make([]byte, BUFFER_SIZE)
	bufLen, err = conn.Read(buffer)
	time.Sleep(time.Second)

	if err != nil {
		fmt.Println("Error message:", err.Error())
		return
	}

	msgAsymEncrypted := buffer[:bufLen]

	plainText, err := cryptohelper.AsymmetricDecrypt(privateKey, msgAsymEncrypted)

	if err != nil {
		fmt.Println("Error message:", err.Error())
		return
	}

	// Handle getting the symmetric key from the server
	buffer = make([]byte, BUFFER_SIZE)
	bufLen, err = conn.Read(buffer)
	time.Sleep(time.Second)

	if err != nil {
		fmt.Println("Error message:", err.Error())
		return
	}

	symmetricKeyEncrypted := buffer[:bufLen]

	symmetricKey, err := cryptohelper.AsymmetricDecrypt(privateKey, symmetricKeyEncrypted)

	if err != nil {
		fmt.Println("Error message:", err.Error())
		return
	}

	fmt.Println(string(plainText) + " " + string(symmetricKey))

	cipherBlock, err := cryptohelper.ImportSymmetricKey(symmetricKey)

	if err != nil {
		fmt.Println("Error message:", err.Error())
		return
	}

	// Sending the symmetric key received to the client
	cipherText, err := cryptohelper.SymmetricEncrypt(cipherBlock, "Symmetric Key received")

	if err != nil {
		fmt.Println("Error message:", err.Error())
		return
	}

	_, err = conn.Write(cipherText)
	time.Sleep(time.Second)

	if err != nil {
		fmt.Println("Error message:", err.Error())
	}

	// Handle the Testing Message 2106752180 encrypted
	buffer = make([]byte, BUFFER_SIZE)
	bufLen, err = conn.Read(buffer)
	time.Sleep(time.Second)

	if err != nil {
		fmt.Println("Error message:", err.Error())
		return
	}

	encryptedMessage := buffer[:bufLen]

	fmt.Println(string(cryptohelper.SymmetricDecrypt(cipherBlock, encryptedMessage)))

	receivedMessage, err := cryptohelper.SymmetricEncrypt(cipherBlock, "Received Message 2106752180")

	if err != nil {
		fmt.Println("error message:", err.Error())
		return
	}

	_, err = conn.Write(receivedMessage)
	time.Sleep(time.Second)

	if err != nil {
		fmt.Println("error message:", err.Error())
		return
	}

	defer conn.Close()
}

// --------- Depreceated ----------

// buffer = make([]byte, BUFFER_SIZE)
// bufLen, err = conn.Read(buffer)

// if err != nil {
// 	fmt.Println("Error message:", err.Error())
// 	return
// }

// recvMsg = string(buffer[:bufLen])

// // Handle getting the symmetric key received from the client
// if err != nil {
// 	fmt.Println("Error message: ", err.Error())
// }

// buffer = make([]byte, BUFFER_SIZE)
// bufLen, err = conn.Read(buffer)
// if err != nil {
// 	fmt.Println("Error message:", err.Error())
// 	return
// }

// cipherKey := buffer[:bufLen]

// fmt.Println(recvMsg + " " + string(cipherKey))

// cipherBlock, err := cryptohelper.ImportSymmetricKey(cipherKey)

// if err != nil {
// 	fmt.Println("Error message:", err.Error())
// 	return
// }

// encryptedMessage, err := cryptohelper.SymmetricEncrypt(cipherBlock, "Symmetric Key received")

// if err != nil {
// 	fmt.Println("error message:", err.Error())
// 	return
// }

// _, err = conn.Write(encryptedMessage)
// if err != nil {
// 	fmt.Println("error message:", err.Error())
// 	return
// }
// // Handle the Testing Message 2106752180 encrypted
// if err != nil {
// 	fmt.Println("Error message: ", err.Error())
// }

// buffer = make([]byte, BUFFER_SIZE)
// bufLen, err = conn.Read(buffer)
// if err != nil {
// 	fmt.Println("Error message:", err.Error())
// 	return
// }

// encryptedMessage = buffer[:bufLen]

// fmt.Println(string(cryptohelper.SymmetricDecrypt(cipherBlock, encryptedMessage)))

// receivedMessage, err := cryptohelper.SymmetricEncrypt(cipherBlock, "Received Message 2106752180")

// if err != nil {
// 	fmt.Println("error message:", err.Error())
// 	return
// }

// _, err = conn.Write(receivedMessage)
// if err != nil {
// 	fmt.Println("error message:", err.Error())
// 	return
// }
