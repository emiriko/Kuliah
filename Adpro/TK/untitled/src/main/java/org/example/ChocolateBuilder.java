package org.example;

public class ChocolateBuilder {
    private static ChocolateBuilder instance = null;
    private boolean empty;
    private boolean boiled;
    private ChocolateBuilder() {
        empty = true;
        boiled = false;
    }
    public void fill() {
        if (isEmpty()) {
            empty = false;
            boiled = false;
            // fi ll the boiler with a milk/chocolate mixture
        }
    }
    public void drain() {
        if (!isEmpty() && isBoiled()) {
            // drain the boiled milk and chocolate
            empty = true;
        }
    }
    public void boil() {
        if (!isEmpty() && !isBoiled()) {
            // bring the contents to a boil
            boiled = true;
        }
    }
    public boolean isEmpty() {
        return empty;
    }
    public boolean isBoiled() {
        return boiled;
    }

    public static ChocolateBuilder getInstance() {
        if(instance == null) {
            instance = new ChocolateBuilder();
        }

        return instance;
    }
}