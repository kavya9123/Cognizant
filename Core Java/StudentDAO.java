import java.sql.*;

class StudentDAO {
    Connection conn;
    public StudentDAO() throws SQLException {
        conn = DriverManager.getConnection("jdbc:sqlite:students.db");
    }

    public void insertStudent(int id, String name) throws SQLException {
        String sql = "INSERT INTO students (id, name) VALUES (?, ?)";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, id);
        pstmt.setString(2, name);
        pstmt.executeUpdate();
    }

    public void updateStudent(int id, String name) throws SQLException {
        String sql = "UPDATE students SET name = ? WHERE id = ?";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, name);
        pstmt.setInt(2, id);
        pstmt.executeUpdate();
    }
}
