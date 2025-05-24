
import java.util.HashMap;
import java.util.Scanner;

public class HashMapExample {
    public static void main(String[] args) {
        HashMap<Integer, String> map = new HashMap<>();
        Scanner scanner = new Scanner(System.in);
        System.out.println("Enter student ID and name (ID -1 to stop):");
        while (true) {
            System.out.print("ID: ");
            int id = scanner.nextInt();
            if (id == -1) break;
            scanner.nextLine(); // consume newline
            System.out.print("Name: ");
            String name = scanner.nextLine();
            map.put(id, name);
        }
        System.out.print("Enter ID to retrieve name: ");
        int searchId = scanner.nextInt();
        System.out.println("Name: " + map.getOrDefault(searchId, "Not found"));
    }
}
