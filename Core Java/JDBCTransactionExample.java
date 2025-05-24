import java.sql.*;

public class JDBCTransactionExample {
    public static void main(String[] args) {
        try {
            Connection conn = DriverManager.getConnection("jdbc:sqlite:bank.db");
            conn.setAutoCommit(false);
            Statement stmt = conn.createStatement();
            stmt.executeUpdate("UPDATE accounts SET balance = balance - 100 WHERE id = 1");
            stmt.executeUpdate("UPDATE accounts SET balance = balance + 100 WHERE id = 2");
            conn.commit();
            conn.close();
        } catch (SQLException e) {
            System.out.println("Transaction failed: " + e.getMessage());
        }
    }
}
