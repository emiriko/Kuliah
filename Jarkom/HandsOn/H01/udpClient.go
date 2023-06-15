package main

import (
	"bufio"
	"fmt"
	"net"
	"os"
)

const (
	SERVER_HOST = "34.171.69.179" // VM 1 External IP Address
	SERVER_PORT = "2180"
	SERVER_TYPE = "udp"
	BUFFER_SIZE = 4096
)

func main() {
	fmt.Println("This is example program for UDP Client")
	fmt.Println("Press Ctrl/CMD+C to stop the program")

	udpAddr, err := net.ResolveUDPAddr(SERVER_TYPE, SERVER_HOST+":"+SERVER_PORT)
	if err != nil {
		fmt.Println("Error message:", err.Error())
		os.Exit(1)
	}

	conn, err := net.DialUDP(SERVER_TYPE, nil, udpAddr)
	if err != nil {
		fmt.Println("Error message:", err.Error())
		os.Exit(1)
	}

	defer conn.Close()

	fmt.Print("Enter a string to send to the server: ")
	SendMsg, err := bufio.NewReader(os.Stdin).ReadString('\n')
	_, err = conn.Write([]byte(SendMsg))
	if err != nil {
		fmt.Println("Error message:", err.Error())
		os.Exit(1)
	}

	buffer := make([]byte, BUFFER_SIZE)
	bufLen, err := conn.Read(buffer)
	if err != nil {
		fmt.Println("Error message:", err.Error())
		os.Exit(1)
	}

	recvMsg := string(buffer[:bufLen])
	fmt.Printf("Answer from server %s: %s\n",
		conn.RemoteAddr().String(), recvMsg)
}
