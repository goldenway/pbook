# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  email           :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  password_digest :string(255)
#  remember_token  :string(255)
#  admin           :boolean          default(FALSE)
#

class User < ActiveRecord::Base
	attr_accessible :name, :email, :password, :password_confirmation, :first_name, 
					:second_name, :sex, :date_of_birth, :country, :city, :start_inv_date,
					:social_vk, :social_fb, :about_info

	has_many :portfolios

	has_secure_password

	# before_save { name.downcase! }
	before_save :create_remember_token

	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :name,  presence: true, length: { maximum: 20 },
					  uniqueness: true # { case_sensitive: false }
	validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }
	validates :password, presence: true, length: { minimum: 6 }
	validates :password_confirmation, presence: true

	private

		def create_remember_token
			# SecureRandom.urlsafe_base64 возвращает случайную строку длиной в
			# 16 символов составленную из знаков A–Z, a–z, 0–9, “-” и “_”
			self.remember_token = SecureRandom.urlsafe_base64
		end
end
