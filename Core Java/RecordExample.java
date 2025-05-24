record Person(String name, int age) {}

import java.util.*;
import java.util.stream.Collectors;

public class RecordExample {
    public static void main(String[] args) {
        List<Person> people = List.of(
            new Person("Alice", 30),
            new Person("Bob", 20),
            new Person("Charlie", 25)
        );
        List<Person> filtered = people.stream().filter(p -> p.age() > 21).collect(Collectors.toList());
        filtered.forEach(System.out::println);
    }
}
