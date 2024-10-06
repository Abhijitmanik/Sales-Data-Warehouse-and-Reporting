# Sales Data Warehouse and Reporting System

## Overview

The **Sales Data Warehouse and Reporting System** is a comprehensive project designed to analyze sales data for a retail business. This project involves creating a data warehouse schema, populating it with sample data, and implementing SQL queries to derive meaningful insights from the data.

## Features

- **Data Warehouse Design**: Implementation of a star schema with dimension and fact tables.
- **Sample Data Generation**: Insertion of realistic sample data for customers, products, sales, and time.
- **Analytical Queries**: A collection of SQL queries to analyze sales performance, customer behavior, and product trends.
- **Segmentation**: Customer segmentation based on spending behavior.
- **Reporting**: Generate reports on average sales, total sales, and customer retention.

## Tables

### 1. `DimCustomers`
- **CustomerID**: Unique identifier for each customer
- **FirstName**: Customer's first name
- **LastName**: Customer's last name
- **Email**: Customer's email address
- **City**: City where the customer resides
- **State**: State where the customer resides
- **JoinDate**: Date when the customer joined

### 2. `DimProducts`
- **ProductID**: Unique identifier for each product
- **ProductName**: Name of the product
- **Category**: Product category (e.g., Electronics, Accessories)
- **UnitPrice**: Price per unit of the product

### 3. `DimSalesChannel`
- **SalesChannelID**: Unique identifier for each sales channel
- **ChannelName**: Name of the sales channel (e.g., Online, In-Store)

### 4. `DimTime`
- **DateKey**: Unique key for each date
- **FullDate**: Full date (YYYY-MM-DD)
- **Year**: Year of the date
- **Month**: Month of the date
- **Day**: Day of the date
- **DayOfWeek**: Day of the week (e.g., Monday, Tuesday)

### 5. `FactSales`
- **SaleID**: Unique identifier for each sale
- **CustomerID**: Foreign key referencing DimCustomers
- **ProductID**: Foreign key referencing DimProducts
- **SalesChannelID**: Foreign key referencing DimSalesChannel
- **DateKey**: Foreign key referencing DimTime
- **Quantity**: Quantity sold
- **TotalAmount**: Total sale amount

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/sales-data-warehouse.git
   cd sales-data-warehouse

# Usage

- You can execute the SQL queries provided in the `queries.sql` file to analyze the sales data and gain insights into customer behavior, sales performance, and trends.

## Example Queries
- Average sales by day of the week.
  
- Customer segmentation based on spending.
  
- Total sales on the busiest day of the year.

- Customer retention rate.


## Contributing

Contributions are welcome! If you have suggestions for improvements or additional features, please open an issue or submit a pull request.

## Acknowledgments
- PostgreSQL for being an excellent relational database management system.
- The data modeling and analysis concepts from various data warehousing resources.














   
