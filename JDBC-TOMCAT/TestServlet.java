package edu.polytechnique.inf553;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebInitParam;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.text.StringEscapeUtils;

/**
 * This is a test servlet used only to verify that the webserver is running correctly.
 */
@WebServlet(urlPatterns = { "/test" }, initParams = {
		@WebInitParam(name = "studentname", value = "", description = "The name of the student") })
public final class TestServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public TestServlet() {
		super();
	}

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		System.out.println(this.getClass().getName() + " doGet method called with path " + request.getRequestURI() + " and parameters " + request.getQueryString()); 
		response.setContentType("application/xml;charset=UTF-8");
		String name = request.getParameter("name");
		if (name==null) {
			throw new ServletException("Expected name parameter but did not get one, URL malformed"); 
		}
		String split[] = name.split("\\.");
		response.getWriter().append("<result>");
		if(split.length!=2) {
			response.getWriter().append("The specified name must be of the form firstname.lastname");
		}else {
			response.getWriter().append("<row>");
			response.getWriter().append("<firstname>");
			response.getWriter().append(StringEscapeUtils.escapeXml11(split[0]));
			response.getWriter().append("</firstname>");
			response.getWriter().append("<lastname>");
			response.getWriter().append(StringEscapeUtils.escapeXml11(split[1]));
			response.getWriter().append("</lastname>");
			response.getWriter().append("</row>");
		}
		response.getWriter().append("</result>");
	}

}
