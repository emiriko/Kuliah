package main

import (
	"compnetcsui/a06/cryptohelper"
	"fmt"
	"net"
	"os"
	"time"
)

const (
	SERVER_HOST = "34.171.69.179" // VM 1 External IP Address
	SERVER_PORT = "2180"
	SERVER_TYPE = "tcp"
	BUFFER_SIZE = 4096
)

func main() {
	cipherKey, cipherBlock, err := cryptohelper.NewSymmetricKey()

	if err != nil {
		fmt.Println("Error message:", err.Error())
		os.Exit(1)
	}

	// Open TCP Connection to the server
	tcpAddr, err := net.ResolveTCPAddr(SERVER_TYPE, SERVER_HOST+":"+SERVER_PORT)
	if err != nil {
		fmt.Println("Error message:", err.Error())
		os.Exit(1)
	}

	conn, err := net.DialTCP(SERVER_TYPE, nil, tcpAddr)
	if err != nil {
		fmt.Println("Error message:", err.Error())
		os.Exit(1)
	}

	defer conn.Close()

	// Send message "Hello Server!"
	firstMessage := "Hello Server!"

	_, err = conn.Write([]byte(firstMessage))

	if err != nil {
		fmt.Println("Error message:", err.Error())
	}

	// Received message "Hey there Client"
	buffer := make([]byte, BUFFER_SIZE)
	bufLen, err := conn.Read(buffer)
	if err != nil {
		fmt.Println("Error message:", err.Error())
		os.Exit(1)
	}

	recvMsg := string(buffer[:bufLen])
	fmt.Println(recvMsg) // Print the received message

	defer conn.Close()

	// Reading the Here's our Public Key
	buffer = make([]byte, BUFFER_SIZE)
	bufLen, err = conn.Read(buffer)
	time.Sleep(time.Second)
	if err != nil {
		fmt.Println("Error message:", err.Error())
		return
	}

	recvMsg = string(buffer[:bufLen])

	// Handle getting the public key received from the server
	buffer = make([]byte, BUFFER_SIZE)
	bufLen, err = conn.Read(buffer)
	time.Sleep(time.Second)
	if err != nil {
		fmt.Println("Error message:", err.Error())
		return
	}

	exportedKey := buffer[:bufLen]

	pubKey, err := cryptohelper.ImportAsymmetricPublicKey(exportedKey)

	if err != nil {
		fmt.Println("Error message:", err.Error())
		return
	}

	fmt.Println(recvMsg + " " + pubKey.N.String())

	encryptedMessage, err := cryptohelper.AsymmetricEncrypt(pubKey, "Public Key received. Here’s the Symmetric Key")

	if err != nil {
		fmt.Println("error message:", err.Error())
		return
	}

	_, err = conn.Write(encryptedMessage)
	time.Sleep(time.Second)

	if err != nil {
		fmt.Println("error message:", err.Error())
		return
	}

	encryptedCipherKey, err := cryptohelper.AsymmetricEncrypt(pubKey, string(cipherKey))

	if err != nil {
		fmt.Println("error message:", err.Error())
		return
	}

	_, err = conn.Write(encryptedCipherKey)
	time.Sleep(time.Second)

	if err != nil {
		fmt.Println("error message:", err.Error())
		return
	}

	// Read the symmetric key received
	buffer = make([]byte, BUFFER_SIZE)
	bufLen, err = conn.Read(buffer)
	time.Sleep(time.Second)

	if err != nil {
		fmt.Println("Error message:", err.Error())
		os.Exit(1)
	}

	encryptedMessage = buffer[:bufLen]

	// Decrypting encrypted message
	fmt.Println(string(cryptohelper.SymmetricDecrypt(cipherBlock, encryptedMessage)))

	// Send message Testing Message [your NPM here]

	// Encrypting message of "Testing Message 2106752180"
	encryptedMessage, err = cryptohelper.SymmetricEncrypt(cipherBlock, "Testing Message 2106752180")

	if err != nil {
		fmt.Println("Error message:", err.Error())
		os.Exit(1)
	}

	// Send the encrypted message of "Testing Message 2106752180"
	_, err = conn.Write(encryptedMessage)
	time.Sleep(time.Second)

	if err != nil {
		fmt.Println("Error message:", err.Error())
	}

	// Read the encrypted "Received Message 2106752180"
	buffer = make([]byte, BUFFER_SIZE)
	bufLen, err = conn.Read(buffer)
	time.Sleep(time.Second)

	if err != nil {
		fmt.Println("Error message:", err.Error())
		os.Exit(1)
	}

	// This message is the encrypted "Received Message 2106752180" message
	encryptedMessage = buffer[:bufLen]

	// Decrypting encrypted message
	fmt.Println(string(cryptohelper.SymmetricDecrypt(cipherBlock, encryptedMessage)))

	conn.Close()
}

// -- DEPRECATED --

// // This part will send the message of "Here’s the Symmetric Key"
// _, err = conn.Write([]byte("Here’s the Symmetric Key"))

// if err != nil {
// 	fmt.Println("Error message:", err.Error())
// }

// // This part will send the symmetric key to the server
// _, err = conn.Write(cipherKey)

// if err != nil {
// 	fmt.Println("Error message:", err.Error())
// }

// This part will read the encrypted "Here’s the Symmetric Key"
// buffer = make([]byte, BUFFER_SIZE)
// bufLen, err = conn.Read(buffer)
// if err != nil {
// 	fmt.Println("Error message:", err.Error())
// 	os.Exit(1)
// }

// // This message is the encrypted "Symmetric Key received" message
// encryptedMessage := buffer[:bufLen]

// // Decrypting encrypted message
// fmt.Println(string(cryptohelper.SymmetricDecrypt(cipherBlock, encryptedMessage)))

// // Encrypting message of "Testing Message 2106752180"
// encryptedMessage, err = cryptohelper.SymmetricEncrypt(cipherBlock, "Testing Message 2106752180")

// if err != nil {
// 	fmt.Println("Error message:", err.Error())
// 	os.Exit(1)
// }

// // Send the encrypted message of "Testing Message 2106752180"
// _, err = conn.Write(encryptedMessage)

// if err != nil {
// 	fmt.Println("Error message:", err.Error())
// }

// // Read the encrypted "Received Message 2106752180"
// buffer = make([]byte, BUFFER_SIZE)
// bufLen, err = conn.Read(buffer)
// if err != nil {
// 	fmt.Println("Error message:", err.Error())
// 	os.Exit(1)
// }

// // This message is the encrypted "Received Message 2106752180" message
// encryptedMessage = buffer[:bufLen]

// // Decrypting encrypted message
// fmt.Println(string(cryptohelper.SymmetricDecrypt(cipherBlock, encryptedMessage)))

// conn.Close()
