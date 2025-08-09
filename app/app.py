import getpass
import mysql.connector as mysql

DB = "ecommerce_lite"

def connect():
    host = input("MySQL host [localhost]: ").strip() or "localhost"
    user = input("MySQL user [root]: ").strip() or "root"
    pwd = getpass.getpass("MySQL password: ")
    return mysql.connect(host=host, user=user, password=pwd, database=DB)

def list_products(cur):
    cur.execute("SELECT product_id,name,category,price,inventory_qty,is_active FROM Product ORDER BY product_id")
    for r in cur.fetchall():
        print(f"#{r[0]} {r[1]} ${r[3]} stock={r[4]} active={bool(r[5])}")

def add_product(cur):
    name = input("name: ").strip()
    category = input("category: ").strip()
    price = float(input("price: ").strip())
    qty = int(input("inventory_qty: ").strip())
    active = input("active? [y/N]: ").lower().startswith("y")
    cur.execute("INSERT INTO Product(name,category,price,inventory_qty,is_active,created_by_staff_id) VALUES(%s,%s,%s,%s,%s,%s)", (name,category,price,qty,active,1))
    print("added product id", cur.lastrowid)

def add_card(cur):
    customer_id = int(input("customer_id: ").strip())
    label = input("label: ").strip()
    last4 = input("last4 (4 digits): ").strip()[-4:].zfill(4)
    cur.execute("INSERT INTO CreditCard(customer_id,label,last4) VALUES(%s,%s,%s)", (customer_id,label,last4))
    print("added card id", cur.lastrowid)

def make_purchase(cur):
    customer_id = int(input("customer_id: ").strip())
    product_id = int(input("product_id: ").strip())
    card_id = int(input("card_id: ").strip())
    qty = int(input("qty: ").strip())
    cur.execute("SELECT 1 FROM CreditCard WHERE card_id=%s AND customer_id=%s", (card_id,customer_id))
    if cur.fetchone() is None:
        print("card does not belong to customer"); return
    cur.execute("SELECT name,price,inventory_qty,is_active FROM Product WHERE product_id=%s", (product_id,))
    row = cur.fetchone()
    if row is None:
        print("product not found"); return
    name, price, stock, active = row
    if not active:
        print("product is inactive"); return
    if stock < qty:
        print("not enough stock"); return
    cur.execute("INSERT INTO Purchase(customer_id,product_id,card_id,qty,unit_price_at_purchase) VALUES(%s,%s,%s,%s,%s)", (customer_id,product_id,card_id,qty,price))
    cur.execute("UPDATE Product SET inventory_qty=inventory_qty-%s WHERE product_id=%s", (qty,product_id))
    print(f"purchased {qty} x {name} @ ${price:.2f}")

def report_over_75(cur):
    cur.execute("""
        SELECT c.name,p.name,pu.qty,pu.unit_price_at_purchase,pu.purchased_at
        FROM Purchase pu
        JOIN Customer c ON c.customer_id=pu.customer_id
        JOIN Product p ON p.product_id=pu.product_id
        WHERE pu.unit_price_at_purchase>75
        ORDER BY pu.purchased_at DESC
    """)
    for r in cur.fetchall():
        print(f"{r[0]} -> {r[1]} x{r[2]} @ ${r[3]} on {r[4]}")

def low_stock(cur):
    cur.execute("SELECT product_id,name,inventory_qty FROM Product WHERE inventory_qty<5 ORDER BY inventory_qty ASC, product_id")
    for r in cur.fetchall():
        print(f"#{r[0]} {r[1]} stock={r[2]}")

def main():
    conn = connect()
    conn.autocommit = False
    cur = conn.cursor()
    while True:
        print("""
1) List products
2) Add product
3) Add credit card
4) Make purchase
5) Report: purchases > $75
6) Report: low stock (<5)
0) Exit
""")
        x = input("select: ").strip()
        if x == "1": list_products(cur)
        elif x == "2": add_product(cur)
        elif x == "3": add_card(cur)
        elif x == "4": make_purchase(cur)
        elif x == "5": report_over_75(cur)
        elif x == "6": low_stock(cur)
        elif x == "0": break
        else: print("invalid")
        conn.commit()
    cur.close(); conn.close()

if __name__ == "__main__":
    main()
