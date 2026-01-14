package products;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
public class Dbase {
	
	public Connection initailizeDatabase() throws SQLException {
		String dbURL = "jdbc:mysql://localhost:3306/mscart?useSSL=false&allowPublicKeyRetrieval=true&autoReconnect=true";
		String dbUsername = "root"; 
		String dbPassword = "123456";
		
		Connection con = DriverManager.getConnection(dbURL, dbUsername, dbPassword);
		return con;
	}
	

}