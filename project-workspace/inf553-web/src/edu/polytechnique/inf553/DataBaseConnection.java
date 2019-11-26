package edu.polytechnique.inf553;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DataBaseConnection {
    
    public static Connection connect_db() throws SQLException {        
    	// Must be set according to database
    	String url = "jdbc:postgresql://localhost:5432/musicbrainz";
    	String user = "user_db"; 
    	String passwd = "pwd";
   
        try {
			Class.forName("org.postgresql.Driver");
		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return DriverManager.getConnection(url, user, passwd);
    }
}