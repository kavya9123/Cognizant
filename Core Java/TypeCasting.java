public class TypeCasting {
    public static void main(String[] args) {
        double d = 9.78;
        int i = (int) d;
        System.out.println("Double: " + d);
        System.out.println("Cast to int: " + i);
        i = 10;
        d = i;
        System.out.println("Int to double: " + d);
    }
}
