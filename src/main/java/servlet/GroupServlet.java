package servlet;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet(urlPatterns = {
    "/GroupServlet",
    "/GetGroupCodeServlet",
    "/GetGroupNameServlet"
})
public class GroupServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private static final String URL  = "jdbc:mysql://localhost:3306/storelink?characterEncoding=UTF-8";
    private static final String USER = "root";
    private static final String PASS = "";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String servletPath = request.getServletPath();

        if ("/GetGroupCodeServlet".equals(servletPath)) {
            handleGetGroupCode(request, response);
            return;
        }

        if ("/GetGroupNameServlet".equals(servletPath)) {
            handleGetGroupName(request, response);
            return;
        }

        // "/GroupServlet" GET access -> just redirect to drawer page
        response.sendRedirect("drawer.jsp?page=group_add");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String code = request.getParameter("code");
        String name = request.getParameter("name");
        String note = request.getParameter("note");

        // ✅ redirect target (stay here by default)
        String returnTo = request.getParameter("returnTo");
        if (returnTo == null || returnTo.trim().isEmpty()) {
            returnTo = "drawer.jsp?page=group_add";
        }

        Connection con = null;
        PreparedStatement ps = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(URL, USER, PASS);

            String sql = "INSERT INTO groups (code, name, note) VALUES (?, ?, ?)";
            ps = con.prepareStatement(sql);
            ps.setString(1, code);
            ps.setString(2, name);
            ps.setString(3, note);

            ps.executeUpdate();

            // ✅ Save -> stay on group_add (drawer)
            response.sendRedirect(returnTo);

        } catch (Exception e) {
            throw new ServletException(e);

        } finally {
            try { if (ps != null) ps.close(); } catch (Exception e) {}
            try { if (con != null) con.close(); } catch (Exception e) {}
        }
    }

    private void handleGetGroupCode(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String name = request.getParameter("name");

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        response.setContentType("text/plain; charset=UTF-8");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(URL, USER, PASS);

            String sql = "SELECT code FROM groups WHERE name = ? LIMIT 1";
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

    private void handleGetGroupName(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String code = request.getParameter("code");

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        response.setContentType("text/plain; charset=UTF-8");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(URL, USER, PASS);

            String sql = "SELECT name FROM groups WHERE code = ? LIMIT 1";
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
