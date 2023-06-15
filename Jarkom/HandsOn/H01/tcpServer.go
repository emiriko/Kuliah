package main

import (
	"fmt"
	"net"
	"os"
)

const (
	SERVER_HOST = ""
	SERVER_PORT = "2180"
	SERVER_TYPE = "tcp"
	BUFFER_SIZE = 4096
)

func main() {
	fmt.Println("This is example program for TCP Server")
	fmt.Println("Press Ctrl/CMD+C to stop the program")

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

	fmt.Println("Listening on", tcpAddr.String())
	fmt.Println("Waiting for client...")

	for {
		conn, err := server.Accept()
		if err != nil {
			fmt.Println("Error message: ", err.Error())
		}

		fmt.Println("Accept connection from: ", conn.RemoteAddr().String())
		processClient(conn)
	}
}

func processClient(conn net.Conn) {
	buffer := make([]byte, BUFFER_SIZE)
	bufLen, err := conn.Read(buffer)
	if err != nil {
		fmt.Println("Error message:", err.Error())
		return
	}

	recvMsg := string(buffer[:bufLen])
	fmt.Printf("Received input from %s: %s\n", conn.RemoteAddr().String(), recvMsg)

	_, err = conn.Write([]byte("Thanks! Got your message: " + recvMsg))
	if err != nil {
		fmt.Println("error message:", err.Error())
		return
	}

	defer conn.Close()
}
