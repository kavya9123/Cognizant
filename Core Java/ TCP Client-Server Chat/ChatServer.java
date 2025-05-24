import java.io.*;
import java.net.*;

// Server
class ChatServer {
    public static void main(String[] args) throws IOException {
        ServerSocket serverSocket = new ServerSocket(1234);
        Socket socket = serverSocket.accept();
        BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()));
        PrintWriter out = new PrintWriter(socket.getOutputStream(), true);

        BufferedReader userInput = new BufferedReader(new InputStreamReader(System.in));
        String msg;
        while ((msg = in.readLine()) != null) {
            System.out.println("Client: " + msg);
            System.out.print("You: ");
            out.println(userInput.readLine());
        }
        socket.close();
        serverSocket.close();
    }
}
