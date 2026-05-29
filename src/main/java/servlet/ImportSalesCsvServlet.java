package servlet;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

@WebServlet(name="ImportSalesCsvServlet", urlPatterns={"/ImportSalesCsvServlet"})
@MultipartConfig
public class ImportSalesCsvServlet extends HttpServlet {

  private static final long serialVersionUID = 1L;

  private static final String URL =
      "jdbc:mysql://localhost:3306/storelink?characterEncoding=UTF-8";
  private static final String USER = "root";
  private static final String PASS = "";

  @Override
  protected void doPost(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, java.io.IOException {

    request.setCharacterEncoding("UTF-8");

    Part filePart = request.getPart("csvFile"); // ← JSP側 name="csvFile" にしてね
    if (filePart == null || filePart.getSize() == 0) {
      renderError(response, "CSVファイルがありません。", request.getContextPath());
      return;
    }

    Connection con = null;
    BufferedReader br = null;

    try {
      Class.forName("com.mysql.cj.jdbc.Driver");
      con = DriverManager.getConnection(URL, USER, PASS);
      con.setAutoCommit(false);

      br = new BufferedReader(new InputStreamReader(filePart.getInputStream(), "UTF-8"));

      String line;
      int lineNo = 0;

      while ((line = br.readLine()) != null) {
        lineNo++;
        line = line.trim();
        if (line.isEmpty()) continue;

        // split
        String[] cols = line.split(",", -1);
        if (cols.length < 2) {
          throw new Exception("CSV形式エラー（行 " + lineNo + "）：item_code,qty,note");
        }

        // ===== item_code =====
        String itemCode = cols[0].trim();

        // ✅ BOM 제거 (Excel UTF-8 BOM)
        if (itemCode.startsWith("\uFEFF")) {
          itemCode = itemCode.substring(1);
        }
        // ✅ “﻿” が混ざるケースもあるので全置換
        itemCode = itemCode.replace("\uFEFF", "").replace("\u200B", "").trim();

        // ✅ 先頭ゼロ除去（DBが 1871991 形式なら安全）
        itemCode = itemCode.replaceFirst("^0+(?!$)", "");

        // ===== qty =====
        String qtyStr = cols[1].trim();
        int qty;
        try {
          qty = Integer.parseInt(qtyStr);
        } catch (Exception e) {
          throw new Exception("qty が不正です（行 " + lineNo + "）: " + qtyStr);
        }
        if (qty <= 0) {
          throw new Exception("qty は 1 以上にしてください（行 " + lineNo + "）");
        }

        // ===== note =====
        String note = (cols.length >= 3 && cols[2] != null && !cols[2].trim().isEmpty())
            ? cols[2].trim()
            : "POS販売";

        // ① 在庫を減らす
        updateStock(con, itemCode, qty, lineNo);

        // ② 履歴を必ず残す
        insertHistory(con, itemCode, -qty, note);
      }

      con.commit();
      response.sendRedirect("drawer.jsp?page=item_list&ok=sales_csv");

    } catch (Exception e) {
      try { if (con != null) con.rollback(); } catch (Exception ex) {}

      String msg = "CSV取込エラー：\n" + e.getMessage();
      renderError(response, msg, request.getContextPath());

    } finally {
      try { if (br != null) br.close(); } catch (Exception e) {}
      try { if (con != null) con.close(); } catch (Exception e) {}
    }
  }

  private void updateStock(Connection con, String code, int soldQty, int lineNo) throws Exception {
    String sql = "UPDATE items SET qty = qty - ? WHERE code = ?";
    PreparedStatement ps = con.prepareStatement(sql);
    ps.setInt(1, soldQty);
    ps.setString(2, code);

    int updated = ps.executeUpdate();
    ps.close();

    if (updated != 1) {
      throw new Exception("商品コードが存在しません（行 " + lineNo + "）: [" + code + "]");
    }
  }

  private void insertHistory(Connection con, String code, int diff, String note) throws Exception {
    String sql = "INSERT INTO item_history (item_code, diff, note) VALUES (?,?,?)";
    PreparedStatement ps = con.prepareStatement(sql);
    ps.setString(1, code);
    ps.setInt(2, diff);
    ps.setString(3, note);
    ps.executeUpdate();
    ps.close();
  }

  // ✅ Pretty error page with Back button
  private void renderError(HttpServletResponse response, String message, String ctx) throws java.io.IOException {
    response.setContentType("text/html; charset=UTF-8");

    String safe = message == null ? "" : message
        .replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;");

    response.getWriter().println(
      "<!DOCTYPE html><html><head><meta charset='UTF-8'>" +
      "<meta name='viewport' content='width=device-width, initial-scale=1.0'>" +
      "<title>CSV取込エラー</title>" +
      "<style>" +
      "body{margin:0;background:#f2f1ef;font-family:'Segoe UI',sans-serif;}" +
      ".wrap{max-width:720px;margin:40px auto;padding:0 16px;}" +
      ".card{background:#fff;border-radius:16px;box-shadow:0 10px 24px rgba(0,0,0,.10);" +
      "border:1px solid rgba(0,0,0,.10);overflow:hidden;}" +
      ".head{background:#01074A;color:#fff;padding:14px 16px;font-weight:900;}" +
      ".body{padding:16px;}" +
      ".msg{white-space:pre-wrap;background:rgba(255,0,0,.06);" +
      "border:1px solid rgba(255,0,0,.20);padding:12px;border-radius:12px;" +
      "font-weight:800;color:#7a0000;}" +
      ".actions{display:flex;gap:10px;flex-wrap:wrap;margin-top:14px;}" +
      ".btn{display:inline-block;text-decoration:none;font-weight:900;" +
      "padding:10px 12px;border-radius:12px;border:1px solid rgba(0,0,0,.12);}"+
      ".btn-back{background:#01074A;color:#fff;border-color:#01074A;}" +
      ".btn-list{background:rgba(227,251,167,.70);color:#01074A;border-color:rgba(227,251,167,.95);}" +
      ".hint{margin-top:10px;color:rgba(0,0,0,.55);font-size:12px;line-height:1.5;}" +
      "</style></head><body>" +
      "<div class='wrap'><div class='card'>" +
      "<div class='head'>CSV取込エラー</div>" +
      "<div class='body'>" +
      "<div class='msg'>" + safe + "</div>" +
      "<div class='actions'>" +
      "<a class='btn btn-back' href='javascript:history.back()'>戻る</a>" +
      "<a class='btn btn-list' href='" + ctx + "/drawer.jsp?page=item_list'>商品一覧へ</a>" +
      "</div>" +
      "<div class='hint'>※ ExcelのCSVは先頭にBOM（見えない文字）が付くことがあります。今回の修正で自動除去します。</div>" +
      "</div></div></div></body></html>"
    );
  }
}
