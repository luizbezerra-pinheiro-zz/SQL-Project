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

import org.apache.commons.text.StringEscapeUtils;


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
		String query = "SELECT DISTINCT A.id, A.name FROM artist A, release_has_artist RhA, release_country RC, country C "
				+ "WHERE RhA.artist = A.id AND RhA.release = RC.release AND RC.country = C.id AND "
				+ "C.name = '" + countryname + "' AND RC.year > " + year +  ";";
		
		try (
				Connection con = DataBaseConnection.connect_db();
				PreparedStatement pst = con.prepareStatement(query);
				ResultSet rs = pst.executeQuery()
			){
				out.append("<div class=\"output\">");
				while (rs.next()) {
					out.append("<p>");
					out.append(Integer.toString(rs.getInt("id")) + ": " + rs.getString("name"));
					out.append("</p>");
	                System.out.print(rs.getInt("id"));
	                System.out.print(": ");
	                System.out.println(rs.getString("name"));
	            }
				out.append("</div>");

			} 
		catch (SQLException ex) {
            Logger lgr = Logger.getLogger(
            		DataBaseConnection.class.getName());
            lgr.log(Level.SEVERE, ex.getMessage(), ex);
		}
		
//		String split[] = name.split("\\.");
//		response.getWriter().append("<result>");
//		if(split.length!=2) {
//			response.getWriter().append("The specified name must be of the form firstname.lastname");
//		}else {
//			response.getWriter().append("<row>");
//			response.getWriter().append("<firstname>");
//			response.getWriter().append(StringEscapeUtils.escapeXml11(split[0]));
//			response.getWriter().append("</firstname>");
//			response.getWriter().append("<lastname>");
//			response.getWriter().append(StringEscapeUtils.escapeXml11(split[1]));
//			response.getWriter().append("</lastname>");
//			response.getWriter().append("</row>");
//		}
//		response.getWriter().append("</result>");
//	}
	}

}
