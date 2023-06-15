package main

import (
	"fmt"
	"net"
	"os"
)

const (
	SERVER_HOST = ""
	SERVER_PORT = "2180"
	SERVER_TYPE = "udp"
	BUFFER_SIZE = 4096
)

func main() {
	fmt.Println("This is example program for UDP Server")
	fmt.Println("Press Ctrl/CMD+C to stop the program")

	udpAddr, err := net.ResolveUDPAddr(SERVER_TYPE, SERVER_HOST+":"+SERVER_PORT)
	if err != nil {
		fmt.Println("Error message: ", err.Error())
		os.Exit(1)
	}

	udpConn, err := net.ListenUDP(SERVER_TYPE, udpAddr)
	if err != nil {
		fmt.Println("Error message:", err.Error())
		os.Exit(1)
	}

	defer udpConn.Close()

	fmt.Println("Listening on", udpAddr.String())
	fmt.Println("Waiting for client...")

	for {
		buffer := make([]byte, BUFFER_SIZE)
		bufLen, addr, err := udpConn.ReadFromUDP(buffer)
		if err != nil {
			fmt.Println("Error message:", err.Error())
		}

		fmt.Println("Received connection from: ", addr.String())
		go processClient(udpConn, addr, bufLen, buffer)
	}
}

func processClient(conn *net.UDPConn, addr *net.UDPAddr, bufLen int, buffer []byte) {
	recvMsg := string(buffer[:bufLen])
	fmt.Printf("Received input from %s: %s", addr.String(), recvMsg)

	_, err := conn.WriteToUDP([]byte("Thanks! Got your message: "+recvMsg), addr)
	if err != nil {
		fmt.Println("Error message: ", err.Error())
		return
	}
}
