package cryptohelper

import (
	"bytes"
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"crypto/rsa"
	"crypto/sha256"
	"crypto/x509"
	"errors"
	"math/big"
)

const (
	AES_KEY_SIZE = 32
	RSA_KEY_SIZE = 2048
	RUNE_POOL    = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
)

// A simple test function which returns "Pong" as a reply
func Ping() (pong string) {
	return "Pong"
}

// This function is used to generate a random string with length as argument.
// Returns the random string and an error (if any).
func GenerateRandomString(length int) (randomString []byte, err error) {
	randomString = make([]byte, length)
	for index := 0; index < length; index++ {
		randomIndex, err := rand.Int(rand.Reader, big.NewInt(int64(length)))
		if err != nil {
			return nil, err
		}
		randomString[index] = RUNE_POOL[randomIndex.Int64()]
	}

	return randomString, nil
}

// This function pads an input string provided through inputString argument such that
// the length is aligned with the size specified in blockSize (its length will be a
// multiplication of blockSize). It uses the PKCS#7 padding method.
// Returns the padded string and an error (if any).
//
// Reference for PKCS#7 Padding Method:  https://datatracker.ietf.org/doc/html/rfc5652#section-6.3
func PadPKCS7(inputString []byte, blockSize int) (paddedString []byte, err error) {
	if blockSize >= 256 {
		return nil, errors.New("block size must not be equal to or larger than 256")
	}

	padSize := blockSize - (len(inputString) % blockSize)
	padString := bytes.Repeat([]byte{byte(padSize)}, padSize)

	return append(inputString, padString...), nil
}

// This function reverses the PCKS#7 padding process such that the string provided
// through the paddedString is restored to its original length and content.
// Returns the unpadded string.
//
// Reference for PKCS#7 Padding Method:  https://datatracker.ietf.org/doc/html/rfc5652#section-6.3
func UnpadPKCS7(paddedString []byte) (unpaddedString []byte) {
	padSize := int(paddedString[len(paddedString)-1])
	return paddedString[:len(paddedString)-padSize]
}

// This function creates a new AES symmetric key through a generated random string. No arguments
// are to be passed in this function.
// Returns the random string used as the cipher key, the AES cipher block, and an error (if any).
func NewSymmetricKey() (cipherKey []byte, cipherBlock cipher.Block, err error) {
	cipherKey, err = GenerateRandomString(AES_KEY_SIZE)
	if err != nil {
		return nil, nil, err
	}

	cipherBlock, err = aes.NewCipher(cipherKey)
	if err != nil {
		return nil, nil, err
	}

	return cipherKey, cipherBlock, nil
}

// This function creates a new RSA asymmetric key. No arguments are to be passed in this function.
// Returns the RSA private key (which also includes its public key) and an error (if any).
func NewAsymmetricKey() (privateKey *rsa.PrivateKey, err error) {
	privateKey, err = rsa.GenerateKey(rand.Reader, RSA_KEY_SIZE)
	if err != nil {
		return nil, err
	}

	return privateKey, nil
}

// This function creates an AES cipher block using the cipher key specified in the cipherKey
// argument. Returns the associated AES cipher block and an error (if any).
func ImportSymmetricKey(cipherKey []byte) (cipherBlock cipher.Block, err error) {
	cipherBlock, err = aes.NewCipher(cipherKey)
	if err != nil {
		return nil, err
	}

	return cipherBlock, nil
}

// This function creates an RSA public key representation by using an exported key string (DER-formatted)
// specified in the exportedKey argument. Returns the RSA public key representation and an error (if any).
func ImportAsymmetricPublicKey(exportedKey []byte) (publicKey *rsa.PublicKey, err error) {
	return x509.ParsePKCS1PublicKey(exportedKey)
}

// This function exports an RSA public key specified through the publicKey argument
// to its DER-formatted string formation. Returns the exported key string.
func ExportAsymmetricPublicKey(publicKey *rsa.PublicKey) (exportedKey []byte) {
	return x509.MarshalPKCS1PublicKey(publicKey)
}

// This function uses the symmetric key encryption through the block specified in cipherBlock argument
// to encrypt a message specified in message argument.
// Returns the cipher text and an error (if any).
func SymmetricEncrypt(cipherBlock cipher.Block, message string) (cipherText []byte, err error) {
	paddedMessage, err := PadPKCS7([]byte(message), aes.BlockSize)
	if err != nil {
		return nil, err
	}

	cipherText = make([]byte, len(paddedMessage))
	for index := 0; index < len(paddedMessage); index = index + aes.BlockSize {
		cipherBlock.Encrypt(cipherText[index:index+aes.BlockSize], paddedMessage[index:index+aes.BlockSize])
	}

	return cipherText, nil
}

// This function decrypts a cipher text specified in cipherText argument using symmetric key encryption
// through the block specified in cipherBlock argument
// Returns the resulting plain text message.
func SymmetricDecrypt(cipherBlock cipher.Block, cipherText []byte) (plainText []byte) {
	paddedMessage := make([]byte, len(cipherText))
	for index := 0; index < len(cipherText); index = index + aes.BlockSize {
		cipherBlock.Decrypt(paddedMessage[index:index+aes.BlockSize], cipherText[index:index+aes.BlockSize])
	}
	return UnpadPKCS7(paddedMessage)
}

// This function uses the asymmetric key encryption through the RSA public key
// specified in publicKey argument to encrypt a message specified in message argument.
// Returns the cipher text and an error (if any).
func AsymmetricEncrypt(publicKey *rsa.PublicKey, message string) (cipherText []byte, err error) {
	cipherText, err = rsa.EncryptOAEP(sha256.New(), rand.Reader, publicKey, []byte(message), nil)
	if err != nil {
		return nil, err
	}

	return cipherText, nil
}

// This function decrypts a cipher text specified in cipherText argument using asymmetric key encryption
// through the RSA private key specified in privateKey argument
// Returns the resulting plain text message and an error (if any).
func AsymmetricDecrypt(privateKey *rsa.PrivateKey, cipherText []byte) (plainText []byte, err error) {
	plainText, err = rsa.DecryptOAEP(sha256.New(), rand.Reader, privateKey, cipherText, nil)
	if err != nil {
		return nil, err
	}

	return plainText, nil
}
