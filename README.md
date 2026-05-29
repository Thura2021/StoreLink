# 🏪 StoreLink

<p align="center">
<img src="images/DskPn.png" width="1000">
</p>

---

## 📖 Overview

<table>
<tr>
<td width="50%" valign="top">

### 🇺🇸 English

StoreLink is a web-based inventory management system developed using Java Servlet, JSP, and MariaDB.

The system enables users to manage products, categories, groups, shelves, and inventory history efficiently.

It also supports CSV sales import, low-stock alerts, and responsive design for both desktop and mobile devices.

This project was inspired by inventory management challenges experienced while working at a convenience store.

</td>

<td width="50%" valign="top">

### 🇯🇵 日本語

StoreLinkは、Java Servlet・JSP・MariaDBを利用して開発した在庫管理Webシステムです。

商品、カテゴリー、グループ、棚情報、在庫履歴を効率的に管理できます。

また、CSV売上データ取込、在庫不足アラート、デスクトップ・スマートフォン対応機能を備えています。

コンビニエンスストアでのアルバイト経験の中で感じた在庫管理の課題を解決するために開発しました。

</td>
</tr>
</table>
---

## 🛠 Technology Stack

- Java
- Servlet / JSP
- JDBC
- MariaDB / MySQL
- HTML5
- CSS3
- JavaScript
- Apache Tomcat 9

---

## ✨ Features

### Dashboard
- Product count
- Category count
- Group count
- Table count
- Low stock alerts
- Recently added products

### Product Management
- Add products
- Edit products
- Delete products
- Product detail panel
- Product image support

### Category Management
- Create categories
- Edit categories
- Delete categories

### Group Management
- Create groups
- Edit groups
- Delete groups

### Table Management
- Shelf/Table management
- View products by shelf

### CSV Import
- Import sales CSV
- Automatic stock reduction

### Excel Export
- Export product list to Excel

### User Management
- Create users
- Permission settings
- Role-based access control

---

# 🖥 Desktop Version

<p align="center">
<img src="images/pcV1.png" width="900">
</p>

<br>

<p align="center">
<img src="images/pcV2.png" width="900">
</p>


---

# 📱 Mobile Version

<p align="center">
<img src="images/mobileV1.png" width="220">
<img src="images/mobileV2.png" width="220">
<img src="images/mobileV3.png" width="220">
</p>

<p align="center">
<img src="images/mobileV4.png" width="220">
<img src="images/mobileV5.png" width="220">
<img src="images/mobileV6.png" width="220">
</p>

---

## 🗄 Database

Database file included:

```sql
storelink.sql
```

Import:

```sql
CREATE DATABASE storelink;
USE storelink;
SOURCE storelink.sql;
```

---

## 👨‍💻 Developer

**Thura Hlaing Ko**

HAL Osaka  
Department of Information Technology

GitHub:
https://github.com/Thura2021

---

## 🇯🇵 日本語

StoreLinkはJava Servlet・JSP・MariaDBを利用して開発した在庫管理Webシステムです。

主な機能：

- 商品管理
- グループ管理
- カテゴリ管理
- テーブル管理
- CSV販売データ取込
- Excel出力
- 在庫不足アラート
- 権限管理
- ダッシュボード表示

コンビニでのアルバイト経験から、商品の場所や在庫状況を簡単に確認できるシステムとして開発しました。
