package com.greetings;

import com.utils.StringUtils;

public class Main {
    public static void main(String[] args) {
        String name = "world";
        String capitalizedName = StringUtils.capitalize(name);

        System.out.println("Hello, " + capitalizedName + "!");

        String message = "java modules are great!";
        String capitalizedMessage = StringUtils.capitalize(message);
        System.out.println("Message: " + capitalizedMessage);
    }
}
