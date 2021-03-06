require './database'
require 'sqlite3'

class SpreeRepository
    def self.create
        new(Database.create)
    end

    def initialize(connection)
        @connection = connection
    end
    def create_search(options)
        @connection.execute("insert into spree_user_behaviors(Session_ID, User_ID, action, created_at, parameters) values(?, ?, ?, datetime(), ?)", options[:session], options[:user], "S", "{\"product\": #{options[:product]}}")
    end

    def add_to_cart(options)
        @connection.execute("insert into spree_user_behaviors(Session_ID, User_ID, action, created_at, parameters) values(?, ?, ?, datetime(), ?)", options[:session], options[:user], "AC", "{\"product\": #{options[:product]}, \"availability\": #{options[:availability]}, \"quantity\": #{options[:quantity]}}")
    end

    def add_to_product_views(variant_id, count)
        @connection.execute("insert into product_views(variant_id, times_viewed) values(#{variant_id},#{count})")
    end

    def delete_from_cart(options)
        @connection.execute("insert into spree_user_behaviors(Session_ID, User_ID, action, created_at, parameters) values(?, ?, ?, datetime(), ?)", options[:session], options[:user], "DC", "{\"product\": #{options[:product]}, \"quantity\": #{options[:quantity]}}")
    end

    def make_payment(options)
        @connection.execute("insert into spree_user_behaviors(Session_ID, User_ID, action, created_at, parameters) values(?, ?, ?, datetime(), ?)", options[:session], options[:user], "P", "{\"order\": #{options[:order]}}")
    end

    def products_bought_in_transaction(order)
        @connection.execute("select variant_id, quantity from spree_line_items where order_id=?", order)
    end

    def random_customers(count)
        @connection.execute("SELECT id FROM spree_users ORDER BY RANDOM() LIMIT #{count}")
    end

    def select_random_product_variant
        @connection.execute("SELECT id FROM spree_variants where is_master='t' ORDER BY RANDOM() LIMIT 1")
    end

    def orders
        @connection.execute("select id, user_id from spree_orders")
    end

    def customers_who_bought_variants_of_a_product(number)
        @connection.execute("select li.order_id, o.user_id, li.variant_id, li.quantity from spree_line_items li, spree_orders o where o.id=li.order_id and variant_id in(select distinct v.id from spree_variants as v where exists(select id from spree_variants where id <> v.id and product_id in (select product_id from spree_products_taxons where taxon_id  in(select id from spree_taxons where id in (select taxon_id from spree_products_taxons where product_id in (select product_id from spree_variants where id=v.id)) and taxonomy_id='854451430')))) order by RANDOM() limit #{number}")
    end

    def variant_of_a_product(variant)
        @connection.execute("select id from spree_variants where id <> #{variant} and is_master='t' and product_id in (select product_id from spree_products_taxons where taxon_id  in(select id from spree_taxons where id in (select taxon_id from spree_products_taxons where product_id in (select product_id from spree_variants where id=#{variant})) and taxonomy_id='854451430')) limit 1")
    end

    def session_id_for_substitution(user_id)
        @connection.execute("select session_id from (select session_id, parameters from spree_user_behaviors where user_id like '%#{user_id}%' and action='AC' order by id desc limit 1) where parameters like '%false%'")
    end

    def group_by_product_views
        @connection.execute("select parameters,count(parameters) from spree_user_behaviors where action = 'S' group by parameters")
    end

    def category_for_a_variant(variant)
        @connection.execute("select id from spree_taxons where taxonomy_id='854451430' and id in (select taxon_id from spree_products_taxons where product_id in (select product_id from spree_variants where id=#{variant}))")
    end

    def product_searched_and_bought
        query = <<-HERE
              select buying.session_id, trim(search.variant_id), buying.variant_id
              from (select b.session_id as session_id, li.variant_id as variant_id
                      from spree_line_items li, spree_user_behaviors b
                      where li.order_id=replace(substr(b.parameters, 10, 5), '}', '') and action='P') as buying,
                            (select session_id, replace(substr(parameters, 12, 20), '}', '') as variant_id from spree_user_behaviors where action='S') as search
                                                    where buying.session_id = search.session_id and buying.variant_id <> search.variant_id
        HERE
        @connection.execute(query)
    end

    def persist_substitution_behavior(substitutions)
        substitutions.each { |substitution|
            @connection.execute("insert into substitution_behavior values(?, ?, ?)", substitution[:searched], substitution[:bought], substitution[:session])
        }
    end

    def variant_bought_in_session?(session, variant)
        variants = @connection.execute("select variant_id from spree_line_items where order_id in (select replace(substr(parameters, 10, 5), '}', '') from spree_user_behaviors where action = 'P' and session_id=?) and variant_id=?", session, variant)
        variants.any?
    end

    def delete_all_product_views
        @connection.execute("delete from product_views")
    end

    def delete_all_user_behaviors
        @connection.execute("delete from spree_user_behaviors")
    end

    def delete_all_substitution_behaviors
        @connection.execute("delete from substitution_behavior")
    end

    def all_variants
        @connection.execute("select id from spree_variants").map {|record| record.first }
    end

    def persist_substitutions(substitutions)
        substitutions.each do |substitution|
            insert_substitution = "insert into spree_substitutions(looked_up_variant, substitute_variant, probability) values (#{substitution.looked_up_variant}, #{substitution.substitute_variant}, #{substitution.probability})"
            @connection.execute(insert_substitution)
        end
    end

    def total_number_of_variants
        @connection.execute("select count(*) from spree_variants")[0][0]
    end

    def number_of_variants_purchased
        @connection.execute("select count(*) from spree_user_behaviors where action = 'P'")[0][0]
    end

    def number_of_variants_looked_at
        @connection.execute("select count(*) from spree_user_behaviors where action = 'S'")[0][0]
    end

    def substitution_count(looked_up_variant, substitute_variant)
        @connection.execute("select count(*) from substitution_behavior where looked_for_variant = '#{looked_up_variant}' and bought_variant = '#{substitute_variant}'")[0][0]
    end

    def purchase_count(variant)
        query = <<-HERE
            select count(*) from spree_line_items li
                inner join spree_user_behaviors ub on ub.parameters = '{\"order\": ' || li.order_id || '}'
                and ub.action = 'P' and li.variant_id = #{variant}
        HERE
        @connection.execute(query)[0][0]
    end

    def lookup_count(variant)
        @connection.execute("select count(*) from spree_user_behaviors where parameters = '{\"product\": ' || #{variant} || '}' and action = 'S'")[0][0]
    end
end
