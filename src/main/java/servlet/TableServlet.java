package servlet;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet(urlPatterns = {
    "/TableServlet",
    "/GetTableCodeServlet",
    "/GetTableNameServlet"
})
public class TableServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private static final String URL  = "jdbc:mysql://localhost:3306/storelink?characterEncoding=UTF-8";
    private static final String USER = "root";
    private static final String PASS = "";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String servletPath = request.getServletPath();

        if ("/GetTableCodeServlet".equals(servletPath)) {
            handleGetTableCode(request, response);
            return;
        }

        if ("/GetTableNameServlet".equals(servletPath)) {
            handleGetTableName(request, response);
            return;
        }

        // "/TableServlet" GET access -> drawer page
        response.sendRedirect("drawer.jsp?page=table_add");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String code      = request.getParameter("code");
        String groupCode = request.getParameter("group_code");
        String name      = request.getParameter("name");
        String note      = request.getParameter("note");

        // (optional columns in your DB)
        String photo    = request.getParameter("photo");     // not used in form
        String location = request.getParameter("location");  // not used in form

        // ✅ redirect target (stay here by default)
        String returnTo = request.getParameter("returnTo");
        if (returnTo == null || returnTo.trim().isEmpty()) {
            returnTo = "drawer.jsp?page=table_add";
        }

        Connection con = null;
        PreparedStatement ps = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(URL, USER, PASS);

            String sql = "INSERT INTO `tables` (code, group_code, photo, name, location, note) VALUES (?, ?, ?, ?, ?, ?)";
            ps = con.prepareStatement(sql);
            ps.setString(1, code);
            ps.setString(2, groupCode);
            ps.setString(3, photo);     // null ok
            ps.setString(4, name);
            ps.setString(5, location);  // null ok
            ps.setString(6, note);

            ps.executeUpdate();

            // ✅ Save -> stay on table_add (drawer)
            response.sendRedirect(returnTo);

        } catch (Exception e) {
            throw new ServletException(e);

        } finally {
            try { if (ps != null) ps.close(); } catch (Exception e) {}
            try { if (con != null) con.close(); } catch (Exception e) {}
        }
    }

    private void handleGetTableCode(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String name = request.getParameter("name");
        response.setContentType("text/plain; charset=UTF-8");

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(URL, USER, PASS);

            String sql = "SELECT code FROM `tables` WHERE name = ? LIMIT 1";
            ps = con.prepareStatement(sql);
            ps.setString(1, name);
            rs = ps.executeQuery();

            if (rs.next()) {
                response.getWriter().write(rs.getString("code"));
            } else {
                response.getWriter().write("");
            }

        } catch (Exception e) {
            response.getWriter().write("");

        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (ps != null) ps.close(); } catch (Exception e) {}
            try { if (con != null) con.close(); } catch (Exception e) {}
        }
    }

    private void handleGetTableName(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String code = request.getParameter("code");
        response.setContentType("text/plain; charset=UTF-8");

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(URL, USER, PASS);

            String sql = "SELECT name FROM `tables` WHERE code = ? LIMIT 1";
            ps = con.prepareStatement(sql);
            ps.setString(1, code);
            rs = ps.executeQuery();

            if (rs.next()) {
                response.getWriter().write(rs.getString("name"));
            } else {
                response.getWriter().write("");
            }

        } catch (Exception e) {
            response.getWriter().write("");

        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (ps != null) ps.close(); } catch (Exception e) {}
            try { if (con != null) con.close(); } catch (Exception e) {}
        }
    }
}
