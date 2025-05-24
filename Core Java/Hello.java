// Hello.java
public class Hello {
    public static void main(String[] args) {
        System.out.println("Hello from compiled class!");
    }
}


//Steps to Decompile:
//Save the above code as Hello.java.
//Compile it:
javac Hello.java


//Decompile using one of the following:
//JD-GUI: Open the generated Hello.class file in JD-GUI.
//CFR tool:
java -jar cfr.jar Hello.class
