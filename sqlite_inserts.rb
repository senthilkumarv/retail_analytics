require 'sqlite3'

def by_description(name, db)
	row = db.get_first_row("select * from spree_products where name='#{name}'")
	product = {:id => row[0], :name => row[1]}
	variant = db.get_first_row("select id, price from spree_variants where product_id=#{product[:id]} and is_master='t'")
	product[:variant_id] = variant[0]
	product[:price] = variant[1]
	product
end

def users(db)
	row = db.execute("select id from spree_users").map {|c| c[0]}
end

db = SQLite3::Database.new( "/home/avishek/Code/mystore/db/development.sqlite3" )

phone = by_description("Zen Full Touch Dual Sim Phone - M28", db)
sdcard = by_description("Sandisk 32 GB Micro SD Ultra Card (Class 10)", db)
s3 = by_description("Samsung Galaxy S3 i9300 Mobile Phone - 16GB", db)
kurti = by_description("De Marca Kurti Code - 1009b", db)
lehenga = by_description("Designer Red Lehenga by Aakriti", db)
bracelet = by_description("The Pari Multicoloured Bracelet - Sdbr-23", db)
watch = by_description("Joan Rivers Shimmering Croco Pattern Leather Strap Watch", db)
tikkis = by_description("Kebabs & Tikkis - Tarla Dalal", db)
skewers = by_description("Fox Run Brands Bamboo Skewers, 6-Inch", db)
biography = by_description("Steve Jobs: The Exclusive Biography", db)


puts users(db).inspect
puts phone.inspect
puts sdcard.inspect
puts s3.inspect
puts kurti.inspect
puts lehenga.inspect
puts bracelet.inspect
puts watch.inspect
puts tikkis.inspect
puts skewers.inspect
puts biography.inspect



