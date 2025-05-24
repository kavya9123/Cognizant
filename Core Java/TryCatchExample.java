import java.util.Scanner;

public class TryCatchExample {
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        try {
            System.out.print("Enter dividend: ");
            int a = scanner.nextInt();
            System.out.print("Enter divisor: ");
            int b = scanner.nextInt();
            int result = a / b;
            System.out.println("Result: " + result);
        } catch (ArithmeticException e) {
            System.out.println("Cannot divide by zero.");
        }
    }
}
