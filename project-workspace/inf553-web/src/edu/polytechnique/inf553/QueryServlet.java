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
		urlPatterns = { "/QueryServlet" }, 
		initParams = { 
				@WebInitParam(name = "countryname", value = "", description = "Country name"), 
				@WebInitParam(name = "year", value = "", description = "Borning year")
		})
public class QueryServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public QueryServlet() {
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
		
		String countryname = request.getParameter("countryname");
		String string_year = request.getParameter("year");
		if (countryname==null || string_year == null) {
			throw new ServletException("Expected countryname and year parameters but did not get both, URL malformed"); 
		}
		int year = 0;
		try {
			year = Integer.parseInt(string_year);
		} catch(NumberFormatException e) {
			System.out.println("Expected an integer, got " + year);
		}
		if (year > 2050) {
			throw new IllegalStateException("Expected year smaller than 2050, got " + year);
		}
				
		// Then we try to connect to the DB and do the queries
		
		String query = "WITH validPubAtCountry AS ( "
				+ " SELECT rha.artist "
				+ " FROM release_country rc, release_has_artist rha, country c "
				+ " WHERE c.id = rc.country AND c.name = \'"+ countryname +"\' AND rc.year > " + year + " AND rha.release = rc.release "
						+ ")"
				+ " SELECT A.id, A.name, count(1) AS cc " + 
				" FROM validPubAtCountry r, artist A " + 
				" WHERE r.artist = A.id " + 
				" GROUP BY (A.id) " + 
				" ORDER BY A.id; ";
		
		try (
				Connection con = DataBaseConnection.connect_db();
				PreparedStatement pst = con.prepareStatement(query);
				ResultSet rs = pst.executeQuery()
			){
				out.append("<style type=\"text/css\">" + 
						"        td { text-align: center; }" + 
						"    </style>");
				out.append("<table class=\"output\">");
				out.append("<tr><th>Artist Id</th><th>Artist Name</th><th>Count</th></tr>");
				while (rs.next()) {
					out.append("<tr>");
					out.append("<td>" + rs.getInt("id") + "</td>");
					out.append("<td> <a href=\"http://localhost:8080/inf553-web/HandleServlet?artistname=" + rs.getString("name")+"\" >" + rs.getString("name") + "</a></td>");
					out.append("<td>" + rs.getString("cc")+ "</td>");
					out.append("</tr>");
	                System.out.print(rs.getInt("id"));
	                System.out.print(": ");
	                System.out.println(rs.getString("name"));
	            }
				out.append("</table>");

			} 
		catch (SQLException ex) {
            Logger lgr = Logger.getLogger(
            		DataBaseConnection.class.getName());
            lgr.log(Level.SEVERE, ex.getMessage(), ex);
		}
	}

}
