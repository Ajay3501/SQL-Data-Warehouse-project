# Data Dictionary for Gold layer 
<br>


## Overview

The Gold layer is the busniess-Level data representation structured to support analytical and reporting use cases. It consists of **dimension
table** and **fact tables** for specific business metrics.


### 1.  gold.dim_customers
  * Purpose: Stores custoer details enriched with demographics abd geographic data.
  * Columns:

    | **Column name** | **Data Type** |**Description**|
    | ----------------|---------------|---------------|
    |customer_key     | BIGINT UN     | Surrogate key uniquely identifying each customer record in the dimention table.          |
    |customer_id      | INT           | Unique numerical identifier assign to each customer.                                     |
    |customer_number  | VARCHAR(50)   | Alphanumeric identifier representing the customer,used for tracking and referring.       |
    |first_name       | VARCHAR(50)   |The Customer's firstname,as recorded in the system.                                       |
    |last_name        | VARCHAR(50)   | The Customer's lastname or family name.                                                  |
    |country          | VARCHAR(50)   | The Country of residence for the customer (e.g.'Australia').                              |
    |marital_status   | VARCHAR(50)   | The marital status of the Customer (e.g. 'Married','Single').                             |
    |gender           | VARCHAR(50)   | The gender of the customer (e.g.'Male','Female','n/a') .                                  |
    |birth_date       | DATE          | The date of birth of the customer,formatted as YYYY-MM-DD (e.g. 2002-05-15).              |
    |create_date      |DATE           | The date and time when the customer record eas created int the system.                     |

### 2. gold.dim_products
  * Purpose: Provides information about th eproducts and their attributes.
  * Columns:

     | **Column name** | **Data Type** |**Description**|
    | ----------------|---------------|---------------|
    |product_key        | BIGINT UN     | Surrogate key uniquely identifying each customer record in the dimention table. |
    |product_id         | INT           | Unique identifier assign to product  for internal tracking and refrencing.                                      |
    |product_number     | VARCHAR(50)   | A structured Alphanumeric identifier representing the product, often used for categorization or inventory.      |
    |product_name       | VARCHAR(50)   |Descriptive name of the product, including key detais such as type,color and size.                               |
    |category_id        | VARCHAR(50)   | A unique identifier for the product's category,linkingits high-level clasificaiton.                             |
    |category           | VARCHAR(50)   | The broder classification of the product (e.g. Bikes,Components) to group related items.                        |
    |subcategory        | VARCHAR(50)   | A more detailed classification of the poduct within the category such as product types.                         |
    |maintenance_required | VARCHAR(50) |Indicates wheather the product requires maintenance (e.g. 'Yes','No').                                           |
    |cost               | INT           | The cost or base price of the product,measures in monetry units.                                                |
    |product_line       |VARCHAR(50)    | The specific products line or series to which the product belongs (e.g. Road,Mountain etc).                     |
    |start_date         | DATE          | The date when the product became available for sale or use,stored in .                                          |



### 2. gold.fact_sales
  * Purpose: Stores transactional sales data for analytical purposes.
  * Columns:

    | **Column name** | **Data Type**    |**Description**                                                                      |
    |-----------------|------------------|-------------------------------------------------------------------------------------|
    |order_number     | VARCHAR(50)      |A Unique alphanumerical identifier for each sales order (e.g. 'S054496'). .          |
    |product_key      |  BIGINT UN       |Surrogate key linking the order to the product dimension table.                      |
    |customer_key     |  BIGINT UN       | Surrogate key linking the order to the customer dimension table.                    |
    |order_date       |  DATE            |The date when the order was placed.                                                  |
    |shipping_date    |  DATE            |The date when the order was shipped to the customer.                                 |
    |due_date         |  DATE            | The date when the order payment was due.                                            |
    |sales_amount     | INT              | The total monetry value of the sale for the line item,in whole currency units(e.g.,25). |
    |quantity         | INT              | The number of units of the products ordered for the line irwm(e.g.,1) .                 |
    |price            | INT              | The price per unit of the product for the line item, in whole currency units(e.g., 25). |
    
