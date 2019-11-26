package edu.polytechnique.inf553;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebInitParam;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;



/**
 * Servlet implementation class QueryServlet
 */
@WebServlet(
		urlPatterns = { "/HandleServlet" }, 
		initParams = { 
				@WebInitParam(name = "countryname", value = "", description = "Country name"), 
				@WebInitParam(name = "year", value = "", description = "Borning year")
		})
public class HandleServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public HandleServlet() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		System.out.println(this.getClass().getName() + " doGet method called with path " + request.getRequestURI() + " and parameters " + request.getQueryString()); 
		response.setContentType("text/html");
		response.setCharacterEncoding("charset=UTF-8");
		PrintWriter out = response.getWriter();
		
		// First we get the parameters from the URL
		
		String artistname = request.getParameter("artistname");
		if (artistname==null) {
			throw new ServletException("Expected countryname and year parameters but did not get both, URL malformed"); 
		}
		
		String query = "SELECT A.gender, A.type, A.syear, " + 
				"    CASE" + 
				"        WHEN A.area is null THEN null " + 
				"        WHEN A.area is not null THEN " + 
				"            ( " + 
				"                SELECT C.name " + 
				"                FROM country C " + 
				"                WHERE C.id = A.area" + 
				"            ) " + 
				"    END as country " + 
				" FROM artist A " + 
				" WHERE A.name = \'"+ artistname+"\';";
		
		try (
				Connection con = DataBaseConnection.connect_db();
				PreparedStatement pst = con.prepareStatement(query);
				ResultSet rs = pst.executeQuery()
			){
				rs.next();
				//[Mr./Mrs.] <ARTIST NAME> born in <YEAR>, <COUNTRY_NAME>
				Integer gender = rs.getInt("gender");
				Integer born_year = rs.getInt("syear");
				Integer type = rs.getInt("type");
				String country = rs.getString("country");
				String message = "";
				if (gender == 1) {
					message += "Mr. ";
				}
				else if(gender == 2) {
					message += "Mrs. ";
				}
				message += artistname;
				if (type == 1 && born_year != null) {
					message += " born in "+ born_year + "";
				}
				if (country != null) {
					message += ", " + country + "";
				}
				out.append("<div> "+ message + " </div>");
				
			} 
		catch (SQLException ex) {
            Logger lgr = Logger.getLogger(
            		DataBaseConnection.class.getName());
            lgr.log(Level.SEVERE, ex.getMessage(), ex);
		}
	}

}
