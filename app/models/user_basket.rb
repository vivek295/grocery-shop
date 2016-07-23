class UserBasket < ActiveRecord::Base
	belongs_to :user
	has_many :shop_products
	validate :check_unit_type
	validates :quantity, numericality: { greater_than_or_equal_to: 0 }

	# Increases the qunatity of the product by 1
	def self.item_increment item
		item.increment!(:quantity, 1.0)
	end

	private
		def check_unit_type
			if unit_type == 'packet' || unit_type == 'pcs'
				if quantity.to_f - quantity.to_i != 0.0
					errors.add(:quantity, 'Must be an integer')
				end	
			end
		end

		# Adding the shop product details to user basket
		def self.new_user_basket(user_basket, user, shop_product)
			user_basket.quantity = 1
			user_basket.shop_product_id = shop_product.id
			user_basket.unit_type = shop_product.unit_type
			user_basket.shop_profile_id = shop_product.shop_profile.id
		end

		# Method for updating quantity in user basket
		def self.updating_quantity_in_user_basket(shop_product, user_basket, flash, user_baskets_params, params)
			user_basket.quantity = params[:user_basket][:quantity].to_f
			
			# For checking quantity exists in shop_inventory
		  if shop_product.shop_inventory.quantity - user_basket.quantity < 0
				flash[:danger] = 'Insufficient Quantity'
				return
			end

			# For checking unit type of shop product for updating quantity
			if (shop_product.unit_type == 'packet' or shop_product.unit_type == 'pcs') and 
				user_basket.quantity % 1 != 0
				flash[:danger] = 'Please enter whole numbers for packed products'
				return
			end

			# For changing quantity of a shop product in user basket
			if user_basket.update_attributes(user_baskets_params)
				flash[:success] = 'Quantity Updated'
			else
			  flash[:danger] = 'Not Updated'
			end
		end
		
end