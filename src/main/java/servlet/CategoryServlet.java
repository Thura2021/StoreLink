package servlet;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet(urlPatterns = {
    "/CategoryServlet",
    "/GetCategoryCodeServlet",
    "/GetCategoryNameServlet"
})
public class CategoryServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private static final String URL  = "jdbc:mysql://localhost:3306/storelink?characterEncoding=UTF-8";
    private static final String USER = "root";
    private static final String PASS = "";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String servletPath = request.getServletPath();

        if ("/GetCategoryCodeServlet".equals(servletPath)) {
            handleGetCategoryCode(request, response);
            return;
        }

        if ("/GetCategoryNameServlet".equals(servletPath)) {
            handleGetCategoryName(request, response);
            return;
        }

        // "/CategoryServlet" GET access -> redirect to drawer page
        response.sendRedirect("drawer.jsp?page=category_add");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String code      = request.getParameter("code");
        String groupCode = request.getParameter("group_code");
        String name      = request.getParameter("name");
        String note      = request.getParameter("note");

        // ✅ redirect target (stay here by default)
        String returnTo = request.getParameter("returnTo");
        if (returnTo == null || returnTo.trim().isEmpty()) {
            returnTo = "drawer.jsp?page=category_add";
        }

        Connection con = null;
        PreparedStatement ps = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(URL, USER, PASS);

            String sql = "INSERT INTO categories (code, group_code, name, note) VALUES (?, ?, ?, ?)";
            ps = con.prepareStatement(sql);
            ps.setString(1, code);
            ps.setString(2, groupCode);
            ps.setString(3, name);
            ps.setString(4, note);

            ps.executeUpdate();

            // ✅ Save -> stay on category_add (drawer)
            response.sendRedirect(returnTo);

        } catch (Exception e) {
            throw new ServletException(e);

        } finally {
            try { if (ps != null) ps.close(); } catch (Exception e) {}
            try { if (con != null) con.close(); } catch (Exception e) {}
        }
    }

    private void handleGetCategoryCode(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String name = request.getParameter("name");

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        response.setContentType("text/plain; charset=UTF-8");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(URL, USER, PASS);

            String sql = "SELECT code FROM categories WHERE name = ? LIMIT 1";
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

    private void handleGetCategoryName(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String code = request.getParameter("code");

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        response.setContentType("text/plain; charset=UTF-8");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(URL, USER, PASS);

            String sql = "SELECT name FROM categories WHERE code = ? LIMIT 1";
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
