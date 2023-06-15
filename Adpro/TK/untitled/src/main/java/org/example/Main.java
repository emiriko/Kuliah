package org.example;

public class Main {
    public static void main(String[] args) {
        ChocolateBuilder instance = ChocolateBuilder.getInstance();
        System.out.println(instance.isBoiled());
    }
}